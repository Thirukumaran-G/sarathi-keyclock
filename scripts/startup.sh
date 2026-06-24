#!/bin/bash
set -euo pipefail

# ---- terraform template variables ----
KEYCLOAK_VERSION="${keycloak_version}"
KEYCLOAK_PORT="${keycloak_port}"
KEYCLOAK_DB_NAME="${keycloak_db_name}"
KEYCLOAK_DB_USER="${keycloak_db_user}"
KEYCLOAK_ADMIN_USER="${keycloak_admin_user}"
KEYCLOAK_CACHE_MODE="${keycloak_cache_mode}"
KEYCLOAK_CACHE_STACK="${keycloak_cache_stack}"
KEYCLOAK_IMAGE_REPO="${keycloak_image_repo}"
KEYCLOAK_START_COMMAND="${keycloak_start_command}"
CLOUD_SQL_INSTANCE="${cloud_sql_instance}"
PROJECT_ID="${project_id}"
REGION="${region}"
CLOUD_SQL_PROXY_IMAGE="${cloud_sql_proxy_image}"
CLOUD_SQL_PROXY_LOG_FLAG="${cloud_sql_proxy_log_flag}"
CLOUD_SQL_PROXY_PORT_FLAG="${cloud_sql_proxy_port_flag}"
COMPOSE_VERSION="${compose_version}"
ADMIN_SECRET_NAME="${admin_secret_name}"
DB_SECRET_NAME="${db_secret_name}"
BACKUP_BUCKET="${backup_bucket_name}"
ENVIRONMENT="${environment}"
DOCKER_LOG_MAX_SIZE="${docker_log_max_size}"
DOCKER_LOG_MAX_FILE="${docker_log_max_file}"
INFINISPAN_PORT="${infinispan_port}"
SUBNET_CIDR="${subnet_cidr}"
DISK_FILESYSTEM_TYPE="${disk_filesystem_type}"
DISK_MOUNT_OPTIONS="${disk_mount_options}"
DISK_FSTAB_DUMP="${disk_fstab_dump}"
DISK_FSTAB_PASS="${disk_fstab_pass}"
JOURNALD_MAX_USE="${journald_max_use}"
JOURNALD_MAX_FILE_SIZE="${journald_max_file_size}"
JOURNALD_MAX_RETENTION_SEC="${journald_max_retention_sec}"
HEALTH_CHECK_PATH="${health_check_path}"
HEALTH_CHECK_MAX_ATTEMPTS="${health_check_max_attempts}"
HEALTH_CHECK_WAIT_SECONDS="${health_check_wait_seconds}"
BACKUP_CRON_SCHEDULE="${backup_cron_schedule}"
BACKUP_LOG_PATH="${backup_log_path}"

DATA_DIR="/data/keycloak"
COMPOSE_FILE="$$DATA_DIR/docker-compose.yml"
DATA_DEVICE_NAME="keycloak-data"
LOG_TAG="keycloak-startup"

log() { echo "[$$(date '+%Y-%m-%d %H:%M:%S')] [$$LOG_TAG] $$1"; }

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
  echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -qq
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable docker
  systemctl start docker
  log "Docker installed"
else
  log "Docker present — skipping"
fi

# ---- step 2: docker logging to cloud logging ----
log "Configuring Docker gcplogs driver"
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "gcplogs",
  "log-opts": {
    "gcp-project": "$$PROJECT_ID",
    "gcp-log-cmd": "true",
    "max-size": "$$DOCKER_LOG_MAX_SIZE",
    "max-file": "$$DOCKER_LOG_MAX_FILE"
  }
}
EOF
systemctl reload-or-restart docker || true

# ---- step 3: data disk ----
log "Checking data disk"
DATA_DEVICE=""
for dev in /dev/disk/by-id/*; do
  if [[ "$$dev" == *"$$DATA_DEVICE_NAME"* ]] && [[ "$$dev" != *"-part"* ]]; then
    DATA_DEVICE=$$(readlink -f "$$dev")
    break
  fi
done

if [[ -z "$$DATA_DEVICE" ]]; then
  log "ERROR: data disk $$DATA_DEVICE_NAME not found"
  exit 1
fi

log "Data disk found: $$DATA_DEVICE"

if ! blkid "$$DATA_DEVICE" | grep -q "TYPE="; then
  log "New blank disk detected -> Formatting with $$DISK_FILESYSTEM_TYPE"
  mkfs.$$DISK_FILESYSTEM_TYPE -F "$$DATA_DEVICE"
  log "Disk formatted"
else
  log "Disk already has filesystem -> skipping format"
fi

DISK_UUID=$$(blkid -s UUID -o value "$$DATA_DEVICE")
mkdir -p "$$DATA_DIR"

if ! grep -q "$$DISK_UUID" /etc/fstab; then
  echo "UUID=$$DISK_UUID $$DATA_DIR $$DISK_FILESYSTEM_TYPE $$DISK_MOUNT_OPTIONS $$DISK_FSTAB_DUMP $$DISK_FSTAB_PASS" >> /etc/fstab
  log "fstab updated"
else
  log "fstab entry already exists"
fi

if ! mountpoint -q "$$DATA_DIR"; then
  mount "$$DATA_DIR"
  log "Disk mounted at $$DATA_DIR"
else
  log "Disk already mounted"
fi

# ---- step 4: vm ip ----
VM_IP=$$(curl -sf \
  "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" \
  -H "Metadata-Flavor: Google")
log "VM internal IP: $$VM_IP"

# ---- step 5: fetch secrets ----
log "Fetching secrets"
ADMIN_PASSWORD=$$(gcloud secrets versions access latest \
  --secret="$$ADMIN_SECRET_NAME" --project="$$PROJECT_ID")
DB_PASSWORD=$$(gcloud secrets versions access latest \
  --secret="$$DB_SECRET_NAME" --project="$$PROJECT_ID")
log "Secrets fetched"

# Escape literal $ for Docker Compose interpolation
ADMIN_PASSWORD_ESCAPED=$$(printf '%s' "$$ADMIN_PASSWORD" | sed 's/\$/$$/g')
DB_PASSWORD_ESCAPED=$$(printf '%s' "$$DB_PASSWORD" | sed 's/\$/$$/g')

# ---- step 6: write docker-compose.yml ----
log "Writing docker-compose.yml"
CLOUD_SQL_CONNECTION="$$PROJECT_ID:$$REGION:$$CLOUD_SQL_INSTANCE"

cat > "$$COMPOSE_FILE" <<ENDDOCKER
services:
  cloudsql-proxy:
    image: $$CLOUD_SQL_PROXY_IMAGE
    command:
      - "$$CLOUD_SQL_PROXY_LOG_FLAG"
      - "$$CLOUD_SQL_PROXY_PORT_FLAG"
      - "$$CLOUD_SQL_CONNECTION"
    restart: unless-stopped

  keycloak:
    image: $$KEYCLOAK_IMAGE_REPO:$$KEYCLOAK_VERSION
    command: $$KEYCLOAK_START_COMMAND
    environment:
      KC_HOSTNAME_STRICT: "false"
      KC_HTTP_ENABLED: "true"
      KC_HEALTH_ENABLED: "true"
      KC_PROXY_HEADERS: "xforwarded"
      KC_DB: "postgres"
      KC_DB_URL: "jdbc:postgresql://cloudsql-proxy:5432/$$KEYCLOAK_DB_NAME"
      KC_DB_USERNAME: "$$KEYCLOAK_DB_USER"
      KC_DB_PASSWORD: "$$DB_PASSWORD_ESCAPED"
      KEYCLOAK_ADMIN: "$$KEYCLOAK_ADMIN_USER"
      KEYCLOAK_ADMIN_PASSWORD: "$$ADMIN_PASSWORD_ESCAPED"
      KC_HTTP_PORT: "$$KEYCLOAK_PORT"
      KC_CACHE: "$$KEYCLOAK_CACHE_MODE"
      KC_CACHE_STACK: "$$KEYCLOAK_CACHE_STACK"
      JAVA_OPTS_APPEND: >-
        -Djgroups.bind.address=$$VM_IP
        -Djgroups.jdbc_ping.connection_url=jdbc:postgresql://cloudsql-proxy:5432/$$KEYCLOAK_DB_NAME
        -Djgroups.jdbc_ping.connection_username=$$KEYCLOAK_DB_USER
        -Djgroups.jdbc_ping.connection_password=$$DB_PASSWORD_ESCAPED
        -Djgroups.tcp.bind_port=$$INFINISPAN_PORT
    ports:
      - "$$KEYCLOAK_PORT:$$KEYCLOAK_PORT"
      - "9000:9000"
    depends_on:
      - cloudsql-proxy
    restart: unless-stopped
ENDDOCKER

log "docker-compose.yml written"

# ---- step 7: start stack ----
log "Starting Docker Compose stack"
docker compose -f "$$COMPOSE_FILE" up -d
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
WorkingDirectory=$$DATA_DIR
ExecStart=/usr/bin/docker compose -f $$COMPOSE_FILE up -d
ExecStop=/usr/bin/docker compose -f $$COMPOSE_FILE down
TimeoutStartSec=180

[Install]
WantedBy=multi-user.target
SYSTEMDEOF

systemctl daemon-reload
systemctl enable keycloak-compose.service
log "Systemd service installed"

# ---- step 9: backup cron ----
log "Installing backup cron"
cat > /usr/local/bin/keycloak-backup.sh <<BACKUPEOF
#!/bin/bash
set -euo pipefail
COMPOSE_FILE="/data/keycloak/docker-compose.yml"
BDATE=$$(date +%Y%m%d)
BACKUP_FILE="keycloak-realm-$$(hostname)-\$$BDATE.json"
BACKUP_PATH="/tmp/\$$BACKUP_FILE"
BACKUP_BUCKET="$$BACKUP_BUCKET"

docker compose -f "\$$COMPOSE_FILE" exec -T keycloak \
  /opt/keycloak/bin/kc.sh export \
  --file /tmp/realm-export.json

CONTAINER_ID=\$$(docker compose -f "\$$COMPOSE_FILE" ps -q keycloak)
docker cp "\$$CONTAINER_ID:/tmp/realm-export.json" "\$$BACKUP_PATH"

gcloud storage cp "\$$BACKUP_PATH" "gs://\$$BACKUP_BUCKET/\$$BACKUP_FILE"
rm -f "\$$BACKUP_PATH"
echo "Backup complete: gs://\$$BACKUP_BUCKET/\$$BACKUP_FILE"
BACKUPEOF

chmod +x /usr/local/bin/keycloak-backup.sh

EXISTING_CRON=$$(crontab -l 2>/dev/null || true)
if ! echo "$$EXISTING_CRON" | grep -q "/usr/local/bin/keycloak-backup.sh"; then
  (
    echo "$$EXISTING_CRON"
    echo "$$BACKUP_CRON_SCHEDULE /usr/local/bin/keycloak-backup.sh >> $$BACKUP_LOG_PATH 2>&1"
  ) | crontab -
  log "Backup cron installed"
else
  log "Backup cron already present — skipping"
fi

# ---- step 10: journald retention ----
log "Configuring journald retention"
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/keycloak.conf <<JOURNALEOF
[Journal]
SystemMaxUse=$$JOURNALD_MAX_USE
SystemMaxFileSize=$$JOURNALD_MAX_FILE_SIZE
MaxRetentionSec=$$JOURNALD_MAX_RETENTION_SEC
JOURNALEOF
systemctl restart systemd-journald || true
log "journald configured"

# ---- step 11: health check ----
log "Waiting for Keycloak health"
MAX_ATTEMPTS=$$HEALTH_CHECK_MAX_ATTEMPTS
ATTEMPT=0
until curl -sf "http://localhost:9000$$HEALTH_CHECK_PATH" >/dev/null 2>&1; do
  ATTEMPT=$$((ATTEMPT + 1))
  if [[ $$ATTEMPT -ge $$MAX_ATTEMPTS ]]; then
    log "ERROR: Keycloak did not become healthy after $$((MAX_ATTEMPTS * HEALTH_CHECK_WAIT_SECONDS))s"
    log "--- Last docker compose logs ---"
    docker compose -f "$$COMPOSE_FILE" logs --tail=50 || true
    exit 1
  fi
  log "Attempt $$ATTEMPT/$$MAX_ATTEMPTS — waiting $${HEALTH_CHECK_WAIT_SECONDS}s"
  sleep $$HEALTH_CHECK_WAIT_SECONDS
done

log "Keycloak healthy — startup complete"