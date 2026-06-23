#!/bin/bash
set -euo pipefail

# ---- terraform template variables ----
KEYCLOAK_VERSION="${keycloak_version}"
KEYCLOAK_PORT="${keycloak_port}"
KEYCLOAK_DB_NAME="${keycloak_db_name}"
KEYCLOAK_DB_USER="${keycloak_db_user}"
CLOUD_SQL_INSTANCE="${cloud_sql_instance}"
PROJECT_ID="${project_id}"
REGION="${region}"
ADMIN_SECRET_NAME="${admin_secret_name}"
DB_SECRET_NAME="${db_secret_name}"
BACKUP_BUCKET="${backup_bucket_name}"
ENVIRONMENT="${environment}"
DOCKER_LOG_MAX_SIZE="${docker_log_max_size}"
DOCKER_LOG_MAX_FILE="${docker_log_max_file}"
KEYCLOAK_HOSTNAME="${keycloak_hostname}"
INFINISPAN_PORT="${infinispan_port}"
SUBNET_CIDR="${subnet_cidr}"

DATA_DIR="/data/keycloak"
COMPOSE_FILE="$DATA_DIR/docker-compose.yml"
DATA_DEVICE_NAME="keycloak-data"
LOG_TAG="keycloak-startup"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LOG_TAG] $1"; }

# ---- step 1: install docker ----
log "Checking Docker"
if ! command -v docker &>/dev/null; then
  log "Installing Docker"
  apt-get update -qq
  apt-get install -y ca-certificates curl gnupg lsb-release
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -qq
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable docker
  systemctl start docker
  log "Docker installed"
else
  log "Docker present — skipping"
fi

# ---- step 2: docker log rotation ----
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "gcplogs",
  "log-opts": {
    "gcp-project": "$PROJECT_ID",
    "gcp-log-cmd": "true"
  }
}
EOF
systemctl reload-or-restart docker || true

# ---- step 3: idempotent data disk handling + restore logic ----
log "Checking data disk"

DATA_DEVICE=""
for dev in /dev/disk/by-id/*; do
  if [[ "$dev" == *"$DATA_DEVICE_NAME"* ]] && [[ "$dev" != *"-part"* ]]; then
    DATA_DEVICE=$(readlink -f "$dev")
    break
  fi
done

if [[ -z "$DATA_DEVICE" ]]; then
  log "ERROR: data disk $DATA_DEVICE_NAME not found"
  exit 1
fi

log "Data disk found: $DATA_DEVICE"

# Format ONLY if brand new (idempotent)
if ! blkid "$DATA_DEVICE" | grep -q "TYPE="; then
  log "New blank disk detected → Formatting with ext4"
  mkfs.ext4 -F "$DATA_DEVICE"
  log "Disk formatted"
else
  log "Disk already has filesystem → skipping format"
fi

DISK_UUID=$(blkid -s UUID -o value "$DATA_DEVICE")
mkdir -p "$DATA_DIR"

# Update fstab only if missing
if ! grep -q "$DISK_UUID" /etc/fstab; then
  echo "UUID=$DISK_UUID $DATA_DIR ext4 defaults,nofail 0 2" >> /etc/fstab
  log "fstab updated"
else
  log "fstab entry already exists"
fi

# Mount if not already mounted
if ! mountpoint -q "$DATA_DIR"; then
  mount "$DATA_DIR" || true
  log "Disk mounted at $DATA_DIR"
else
  log "Disk already mounted"
fi

# Check compose file status
if [[ ! -f "$COMPOSE_FILE" ]] || [[ ! -s "$COMPOSE_FILE" ]]; then
  log "docker-compose.yml missing or empty → will be created below"
else
  log "docker-compose.yml already exists on persistent disk"
fi

# ---- step 4: get vm internal ip for infinispan bind ----
VM_IP=$(curl -sf \
  "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" \
  -H "Metadata-Flavor: Google")
log "VM internal IP: $VM_IP"

# ---- step 5: fetch secrets ----
log "Fetching secrets"
ADMIN_PASSWORD=$(gcloud secrets versions access latest \
  --secret="$ADMIN_SECRET_NAME" --project="$PROJECT_ID")
DB_PASSWORD=$(gcloud secrets versions access latest \
  --secret="$DB_SECRET_NAME" --project="$PROJECT_ID")
log "Secrets fetched"

# ---- step 6: write docker-compose.yml ----
log "Writing docker-compose.yml"
CLOUD_SQL_CONNECTION="$${PROJECT_ID}:$${REGION}:$${CLOUD_SQL_INSTANCE}"

cat > "$COMPOSE_FILE" <<EOF
version: "3.8"

services:
  cloudsql-proxy:
    image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:2
    command:
      - "--structured-logs"
      - "--port=5432"
      - "$CLOUD_SQL_CONNECTION"
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: "$DOCKER_LOG_MAX_SIZE"
        max-file: "$DOCKER_LOG_MAX_FILE"

  keycloak:
    image: quay.io/keycloak/keycloak:$KEYCLOAK_VERSION
    command: start
    environment:
      KC_HOSTNAME: "$KEYCLOAK_HOSTNAME"
      KC_HOSTNAME_STRICT: "false"
      KC_HTTP_ENABLED: "true"
      KC_HEALTH_ENABLED: "true"
      KC_PROXY_HEADERS: "xforwarded"
      KC_DB: "postgres"
      KC_DB_URL: "jdbc:postgresql://127.0.0.1:5432/$KEYCLOAK_DB_NAME"
      KC_DB_USERNAME: "$KEYCLOAK_DB_USER"
      KC_DB_PASSWORD: "$DB_PASSWORD"
      KEYCLOAK_ADMIN: "admin"
      KEYCLOAK_ADMIN_PASSWORD: "$ADMIN_PASSWORD"
      KC_HTTP_PORT: "$KEYCLOAK_PORT"
      KC_CACHE: "ispn"
      KC_CACHE_STACK: "jdbc-ping"
      JAVA_OPTS_APPEND: >-
        -Djgroups.bind.address=$VM_IP
        -Djgroups.jdbc_ping.connection_url=jdbc:postgresql://127.0.0.1:5432/$KEYCLOAK_DB_NAME
        -Djgroups.jdbc_ping.connection_username=$KEYCLOAK_DB_USER
        -Djgroups.jdbc_ping.connection_password=$DB_PASSWORD
        -Djgroups.tcp.bind_port=$INFINISPAN_PORT
    ports:
      - "$KEYCLOAK_PORT:$KEYCLOAK_PORT"
    depends_on:
      - cloudsql-proxy
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: "$DOCKER_LOG_MAX_SIZE"
        max-file: "$DOCKER_LOG_MAX_FILE"
EOF

log "docker-compose.yml written"

# ---- step 7: start stack ----
log "Starting Docker Compose stack"
docker compose -f "$COMPOSE_FILE" up -d
log "Stack started"

# ---- step 8: systemd service ----
log "Installing systemd service"
cat > /etc/systemd/system/keycloak-compose.service <<EOF
[Unit]
Description=Keycloak Docker Compose Stack
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$DATA_DIR
ExecStart=/usr/bin/docker compose -f $COMPOSE_FILE up -d
ExecStop=/usr/bin/docker compose -f $COMPOSE_FILE down
TimeoutStartSec=180

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable keycloak-compose.service
log "Systemd service installed"

# ---- step 9: backup cron ----
log "Installing backup cron"
cat > /usr/local/bin/keycloak-backup.sh <<BACKUPEOF
#!/bin/bash
set -euo pipefail
ENVIRONMENT="$ENVIRONMENT"
BACKUP_BUCKET="$BACKUP_BUCKET"
COMPOSE_FILE="$COMPOSE_FILE"
DATE=\$(date +%Y%m%d)
BACKUP_FILE="keycloak-realm-\$$ENVIRONMENT-\$DATE.json"
BACKUP_PATH="/tmp/\$BACKUP_FILE"

docker compose -f "\$COMPOSE_FILE" exec -T keycloak \
  /opt/keycloak/bin/kc.sh export \
  --file /tmp/realm-export.json

CONTAINER_ID=\$(docker compose -f "\$COMPOSE_FILE" ps -q keycloak)
docker cp "\$CONTAINER_ID:/tmp/realm-export.json" "\$BACKUP_PATH"

gcloud storage cp "\$BACKUP_PATH" "gs://\$$BACKUP_BUCKET/\$BACKUP_FILE"
rm -f "\$BACKUP_PATH"
echo "Backup complete: gs://\$$BACKUP_BUCKET/\$BACKUP_FILE"
BACKUPEOF

chmod +x /usr/local/bin/keycloak-backup.sh

if ! crontab -l 2>/dev/null | grep -q "keycloak-backup"; then
  (crontab -l 2>/dev/null; \
    echo "0 2 * * * /usr/local/bin/keycloak-backup.sh >> /var/log/keycloak-backup.log 2>&1") \
    | crontab -
  log "Backup cron installed"
else
  log "Backup cron already present — skipping"
fi

# ---- step 10: journald retention ----
log "Configuring journald retention"
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/keycloak.conf <<EOF
[Journal]
SystemMaxUse=500M
SystemMaxFileSize=100M
MaxRetentionSec=2592000
EOF
systemctl restart systemd-journald || true
log "journald configured"

# ---- step 11: health check ----
log "Waiting for Keycloak health"
MAX_ATTEMPTS=36
ATTEMPT=0
until curl -sf "http://localhost:$KEYCLOAK_PORT/health/started" >/dev/null 2>&1; do
  ATTEMPT=$((ATTEMPT + 1))
  if [[ $ATTEMPT -ge $MAX_ATTEMPTS ]]; then
    log "ERROR: Keycloak did not become healthy"
    exit 1
  fi
  log "Attempt $ATTEMPT/$MAX_ATTEMPTS — waiting 10s"
  sleep 10
done

log "Keycloak healthy — startup complete"