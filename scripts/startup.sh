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
INFINISPAN_PORT="${infinispan_port}"
JOURNALD_MAX_USE="${journald_max_use}"
JOURNALD_MAX_FILE_SIZE="${journald_max_file_size}"
JOURNALD_MAX_RETENTION_SEC="${journald_max_retention_sec}"
HEALTH_CHECK_PATH="${health_check_path}"
HEALTH_CHECK_MAX_ATTEMPTS="${health_check_max_attempts}"
HEALTH_CHECK_WAIT_SECONDS="${health_check_wait_seconds}"
BACKUP_CRON_SCHEDULE="${backup_cron_schedule}"
BACKUP_LOG_PATH="${backup_log_path}"

DATA_DIR="/data/keycloak"
COMPOSE_FILE="$DATA_DIR/docker-compose.yml"
DATA_DEVICE_NAME="keycloak-data"
LOG_TAG="keycloak-startup"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LOG_TAG] $1"; }

# ---- step 1: install docker + cron ----
log "Checking Docker"
if ! command -v docker >/dev/null 2>&1; then
  log "Installing Docker prerequisites"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y ca-certificates curl gnupg lsb-release cron

  install -m 0755 -d /etc/apt/keyrings
  rm -f /etc/apt/keyrings/docker.gpg
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  rm -f /etc/apt/sources.list.d/docker.list
  printf '%s\n' \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -qq
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  systemctl enable docker
  systemctl start docker
  systemctl enable cron || true
  systemctl start cron || true
  log "Docker installed"
else
  log "Docker present — skipping"
  if ! command -v crontab >/dev/null 2>&1; then
    log "Installing cron"
    apt-get update -qq
    apt-get install -y cron
  fi
  systemctl enable cron || true
  systemctl start cron || true
fi

# ---- step 2: docker logging to cloud logging ----
log "Configuring Docker gcplogs driver"
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "gcplogs",
  "log-opts": {
    "gcp-project": "$PROJECT_ID",
    "gcp-log-cmd": "true"
  }
}
EOF
systemctl restart docker

# ---- step 3: data disk ----
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

if ! blkid "$DATA_DEVICE" | grep -q "TYPE="; then
  log "New blank disk detected -> Formatting with ext4"
  mkfs.ext4 -F "$DATA_DEVICE"
  log "Disk formatted"
fi

DISK_UUID=$(blkid -s UUID -o value "$DATA_DEVICE")
mkdir -p "$DATA_DIR"

if ! grep -q "$DISK_UUID" /etc/fstab; then
  echo "UUID=$DISK_UUID $DATA_DIR ext4 defaults,nofail 0 2" >> /etc/fstab
  log "fstab updated"
fi

if ! mountpoint -q "$DATA_DIR"; then
  mount "$DATA_DIR"
  log "Disk mounted at $DATA_DIR"
fi

# ---- step 4: vm ip ----
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

ADMIN_PASSWORD_ESCAPED=$(printf '%s' "$ADMIN_PASSWORD" | sed 's/\$/$$/g')
DB_PASSWORD_ESCAPED=$(printf '%s' "$DB_PASSWORD" | sed 's/\$/$$/g')

# ---- step 6: write docker-compose.yml ----
log "Writing docker-compose.yml"
CLOUD_SQL_CONNECTION="$PROJECT_ID:$REGION:$CLOUD_SQL_INSTANCE"

cat > "$COMPOSE_FILE" <<ENDDOCKER
services:
  cloudsql-proxy:
    image: gcr.io/cloud-sql-connectors/cloud-sql-proxy:2
    command:
      - "--structured-logs"
      - "--address=0.0.0.0"
      - "--port=5432"
      - "$CLOUD_SQL_CONNECTION"
    restart: unless-stopped

  keycloak:
    image: quay.io/keycloak/keycloak:$KEYCLOAK_VERSION
    command: start
    environment:
      KC_HOSTNAME_STRICT: "false"
      KC_HTTP_ENABLED: "true"
      KC_HEALTH_ENABLED: "true"
      KC_PROXY_HEADERS: "xforwarded"
      KC_DB: "postgres"
      KC_DB_URL: "jdbc:postgresql://cloudsql-proxy:5432/$KEYCLOAK_DB_NAME"
      KC_DB_USERNAME: "$KEYCLOAK_DB_USER"
      KC_DB_PASSWORD: "$DB_PASSWORD_ESCAPED"
      KEYCLOAK_ADMIN: "admin"
      KEYCLOAK_ADMIN_PASSWORD: "$ADMIN_PASSWORD_ESCAPED"
      KC_HTTP_PORT: "$KEYCLOAK_PORT"
      KC_CACHE: "ispn"
      KC_CACHE_STACK: "jdbc-ping"
      JAVA_OPTS_APPEND: >-
        -Djgroups.bind.address=$VM_IP
        -Djgroups.jdbc_ping.connection_url=jdbc:postgresql://cloudsql-proxy:5432/$KEYCLOAK_DB_NAME
        -Djgroups.jdbc_ping.connection_username=$KEYCLOAK_DB_USER
        -Djgroups.jdbc_ping.connection_password=$DB_PASSWORD_ESCAPED
        -Djgroups.tcp.bind_port=$INFINISPAN_PORT
    ports:
      - "$KEYCLOAK_PORT:$KEYCLOAK_PORT"
      - "9000:9000"
    depends_on:
      - cloudsql-proxy
    restart: unless-stopped
ENDDOCKER

log "docker-compose.yml written"

# ---- step 7: start stack ----
log "Starting Docker Compose stack"
docker compose -f "$COMPOSE_FILE" up -d
log "Stack started"

# ---- step 8: systemd service ----
log "Installing systemd service"
cat > /etc/systemd/system/keycloak-compose.service <<SYSTEMDEOF
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
SYSTEMDEOF

systemctl daemon-reload
systemctl enable keycloak-compose.service
log "Systemd service installed"

# ---- step 9: backup cron ----
log "Installing backup cron"

cat > /usr/local/bin/keycloak-backup.sh <<'BACKUPEOF'
#!/bin/bash
set -euo pipefail

COMPOSE_FILE="/data/keycloak/docker-compose.yml"
BDATE=$(date +%Y%m%d)
BACKUP_FILE="keycloak-realm-$(hostname)-$${BDATE}.json"
BACKUP_PATH="/tmp/$${BACKUP_FILE}"
BACKUP_BUCKET="__BACKUP_BUCKET__"

docker compose -f "$COMPOSE_FILE" exec -T keycloak \
  /opt/keycloak/bin/kc.sh export \
  --file /tmp/realm-export.json

CONTAINER_ID=$(docker compose -f "$COMPOSE_FILE" ps -q keycloak)
docker cp "$${CONTAINER_ID}:/tmp/realm-export.json" "$${BACKUP_PATH}"

gcloud storage cp "$${BACKUP_PATH}" "gs://$${BACKUP_BUCKET}/$${BACKUP_FILE}"
rm -f "$${BACKUP_PATH}"
echo "Backup complete: gs://$${BACKUP_BUCKET}/$${BACKUP_FILE}"
BACKUPEOF

sed -i "s|__BACKUP_BUCKET__|$BACKUP_BUCKET|g" /usr/local/bin/keycloak-backup.sh
chmod +x /usr/local/bin/keycloak-backup.sh

# ---- step 10: journald retention ----
log "Configuring journald retention"
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/keycloak.conf <<JOURNALEOF
[Journal]
SystemMaxUse=$JOURNALD_MAX_USE
SystemMaxFileSize=$JOURNALD_MAX_FILE_SIZE
MaxRetentionSec=$JOURNALD_MAX_RETENTION_SEC
JOURNALEOF
systemctl restart systemd-journald || true
log "journald configured"

# ---- step 11: health check ----
log "Waiting for Keycloak health"
MAX_ATTEMPTS=$HEALTH_CHECK_MAX_ATTEMPTS
ATTEMPT=0
until curl -sf "http://localhost:9000$HEALTH_CHECK_PATH" >/dev/null 2>&1; do
  ATTEMPT=$((ATTEMPT + 1))
  if [[ $ATTEMPT -ge $MAX_ATTEMPTS ]]; then
    log "ERROR: Keycloak did not become healthy after $((MAX_ATTEMPTS * HEALTH_CHECK_WAIT_SECONDS))s"
    log "--- Last docker compose logs ---"
    docker compose -f "$COMPOSE_FILE" logs --tail=50 || true
    exit 1
  fi
  log "Attempt $ATTEMPT/$MAX_ATTEMPTS — waiting $${HEALTH_CHECK_WAIT_SECONDS}s"
  sleep "$HEALTH_CHECK_WAIT_SECONDS"
done

log "Keycloak healthy — startup complete"