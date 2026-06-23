project_id            = "gwx-devops-internship"
region                = "us-central1"
zone                  = "us-central1-a"
environment           = "dev"
domain_name           = "sarthi.io"
dns_managed_zone_name = "sarthi-io-zone"
dns_record_ttl        = 300
dns_record_type       = "A"

vm_machine_type            = "e2-standard-2"
vm_boot_disk_size_gb       = 50
vm_boot_disk_type          = "pd-balanced"
vm_data_disk_size_gb       = 20
vm_data_disk_type          = "pd-ssd"
vm_image                   = "ubuntu-os-cloud/ubuntu-2204-lts"
vm_os_login_metadata_key   = "enable-oslogin"
vm_os_login_metadata_value = "TRUE"
vm_scopes                  = ["cloud-platform"]

shielded_secure_boot          = true
shielded_vtpm                 = true
shielded_integrity_monitoring = true
template_create_before_destroy = true

mig_min_replicas       = 2
mig_max_replicas       = 5
mig_cooldown_period    = 120
mig_cpu_target         = 0.7
mig_initial_delay_sec  = 300
mig_update_type        = "PROACTIVE"
mig_minimal_action     = "REPLACE"
mig_max_surge          = 1
mig_max_unavailable    = 0
mig_replacement_method = "SUBSTITUTE"

network_name                 = "sarthi-vpc"
subnet_cidr                  = "10.10.0.0/24"
subnet_private_google_access = true
vpc_auto_create_subnets      = false

fw_lb_source_ranges    = ["130.211.0.0/22", "35.191.0.0/16"]
fw_iap_source_ranges   = ["35.235.240.0/20"]
fw_lb_protocol         = "tcp"
fw_iap_protocol        = "tcp"
fw_infinispan_protocol = "tcp"
fw_iap_port            = "22"

sql_vpc_peering_prefix_length  = 16
sql_vpc_peering_purpose        = "VPC_PEERING"
sql_vpc_peering_address_type   = "INTERNAL"
sql_vpc_peering_service        = "servicenetworking.googleapis.com"
sql_networking_peering_address_name = "sql-private-ip-range"

cloud_sql_tier                 = "db-g1-small"
cloud_sql_disk_size_gb         = 20
cloud_sql_disk_type            = "PD_SSD"
cloud_sql_postgres_version     = "POSTGRES_15"
cloud_sql_instance_name        = "sarthi-keycloak-main"
cloud_sql_backup_start_time    = "02:00"
cloud_sql_maintenance_day      = 7
cloud_sql_maintenance_hour     = 3
cloud_sql_maintenance_track    = "stable"
cloud_sql_deletion_protection  = true
cloud_sql_ipv4_enabled         = false
cloud_sql_private_path_enabled = true

keycloak_db_name = "keycloak"
keycloak_db_user = "keycloak"

keycloak_version      = "26.0"
keycloak_port         = 8080
keycloak_admin_user   = "admin"
keycloak_cache_mode   = "ispn"
keycloak_cache_stack  = "jdbc-ping"
keycloak_image_repo   = "quay.io/keycloak/keycloak"
keycloak_start_command = "start"

cloud_sql_proxy_image     = "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2"
cloud_sql_proxy_log_flag  = "--structured-logs"
cloud_sql_proxy_port_flag = "--port=5432"

compose_version = "3.8"

health_check_port                = 8080
health_check_interval_sec        = 10
health_check_timeout_sec         = 5
health_check_healthy_threshold   = 2
health_check_unhealthy_threshold = 3
health_check_path                = "/health/started"
health_check_max_attempts        = 36
health_check_wait_seconds        = 10

lb_protocol                    = "HTTP"
lb_port_name                   = "http"
lb_scheme                      = "EXTERNAL_MANAGED"
lb_timeout_sec                 = 30
lb_balancing_mode              = "UTILIZATION"
lb_capacity_scaler             = 1.0
lb_session_affinity            = "GENERATED_COOKIE"
lb_session_cookie_name         = "KEYCLOAK_SESSION"
lb_session_cookie_ttl_seconds  = 3600
lb_log_sample_rate             = 1.0
lb_https_port                  = "443"
lb_http_port                   = "80"
lb_http_redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"

backup_retention_days     = 30
backup_num_newer_versions = 3
backup_cron_schedule      = "0 2 * * *"
backup_log_path           = "/var/log/keycloak-backup.log"

bucket_public_access_prevention = "enforced"
bucket_force_destroy            = false
gcs_bucket_versioning_enabled   = true
gcs_lifecycle_action_type       = "Delete"
gcs_writer_role                 = "roles/storage.objectCreator"

docker_log_max_size = "100m"
docker_log_max_file = "3"

admin_password_length          = 32
admin_password_special         = true
admin_password_override_special = "!#$%&*()-_=+[]{}:?"
db_password_length             = 32
db_password_special            = true
db_password_override_special   = "!#$%&*()-_=+[]{}:?"

secret_replication_policy = "auto"
secret_accessor_role      = "roles/secretmanager.secretAccessor"

sa_roles = [
  "roles/secretmanager.secretAccessor",
  "roles/cloudsql.client",
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/storage.objectViewer"
]

infinispan_port = 7800

disk_filesystem_type = "ext4"
disk_mount_options   = "defaults,nofail"
disk_fstab_dump      = "0"
disk_fstab_pass      = "2"

journald_max_use           = "500M"
journald_max_file_size     = "100M"
journald_max_retention_sec = "2592000"

ssl_cert_domains = ["keycloak.dev.sarthi.io"]