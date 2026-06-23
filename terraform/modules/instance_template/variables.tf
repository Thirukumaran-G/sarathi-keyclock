variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "template_name" {
  description = "Instance template name prefix"
  type        = string
}

variable "machine_type" {
  description = "GCE machine type"
  type        = string
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
}

variable "boot_disk_size" {
  description = "Boot disk size GB"
  type        = number
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
}

variable "network_self_link" {
  description = "VPC network self link"
  type        = string
}

variable "subnet_self_link" {
  description = "Subnet self link"
  type        = string
}

variable "sa_email" {
  description = "Service account email"
  type        = string
}

variable "vm_scopes" {
  description = "OAuth scopes for VM"
  type        = list(string)
}

variable "vm_tags" {
  description = "Network tags"
  type        = list(string)
}

variable "os_login_metadata_key" {
  description = "Metadata key for OS login"
  type        = string
}

variable "os_login_metadata_value" {
  description = "Metadata value for OS login"
  type        = string
}

variable "shielded_secure_boot" {
  description = "Enable secure boot"
  type        = bool
}

variable "shielded_vtpm" {
  description = "Enable vTPM"
  type        = bool
}

variable "shielded_integrity_monitoring" {
  description = "Enable integrity monitoring"
  type        = bool
}

variable "create_before_destroy" {
  description = "Create before destroy lifecycle"
  type        = bool
}

variable "keycloak_version" {
  description = "Keycloak Docker image version"
  type        = string
}

variable "keycloak_port" {
  description = "Keycloak HTTP port"
  type        = number
}

variable "keycloak_db_name" {
  description = "Keycloak database name"
  type        = string
}

variable "keycloak_db_user" {
  description = "Keycloak database user"
  type        = string
}

variable "keycloak_admin_user" {
  description = "Keycloak admin username"
  type        = string
}

variable "keycloak_cache_mode" {
  description = "Keycloak cache mode"
  type        = string
}

variable "keycloak_cache_stack" {
  description = "Keycloak cache stack"
  type        = string
}

variable "keycloak_image_repo" {
  description = "Keycloak Docker image repository"
  type        = string
}

variable "keycloak_start_command" {
  description = "Keycloak start command"
  type        = string
}

variable "cloud_sql_instance" {
  description = "Cloud SQL instance name"
  type        = string
}

variable "project_id_for_proxy" {
  description = "Project ID for Cloud SQL connection string"
  type        = string
}

variable "region_for_proxy" {
  description = "Region for Cloud SQL connection string"
  type        = string
}

variable "cloud_sql_proxy_image" {
  description = "Cloud SQL Auth Proxy Docker image"
  type        = string
}

variable "cloud_sql_proxy_log_flag" {
  description = "Cloud SQL proxy structured logs flag"
  type        = string
}

variable "cloud_sql_proxy_port_flag" {
  description = "Cloud SQL proxy port flag"
  type        = string
}

variable "compose_version" {
  description = "Docker compose file version"
  type        = string
}

variable "admin_secret_name" {
  description = "Secret Manager name for admin password"
  type        = string
}

variable "db_secret_name" {
  description = "Secret Manager name for DB password"
  type        = string
}

variable "backup_bucket_name" {
  description = "GCS backup bucket name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "docker_log_max_size" {
  description = "Docker log max size"
  type        = string
}

variable "docker_log_max_file" {
  description = "Docker log max file count"
  type        = string
}

variable "keycloak_hostname" {
  description = "Keycloak FQDN"
  type        = string
}

variable "infinispan_port" {
  description = "Infinispan JGroups port"
  type        = number
}

variable "subnet_cidr" {
  description = "Subnet CIDR for Infinispan bind"
  type        = string
}

variable "disk_filesystem_type" {
  description = "Filesystem type for data disk"
  type        = string
}

variable "disk_mount_options" {
  description = "Mount options for data disk"
  type        = string
}

variable "disk_fstab_dump" {
  description = "fstab dump value"
  type        = string
}

variable "disk_fstab_pass" {
  description = "fstab pass value"
  type        = string
}

variable "journald_max_use" {
  description = "Max journal disk usage"
  type        = string
}

variable "journald_max_file_size" {
  description = "Max journal file size"
  type        = string
}

variable "journald_max_retention_sec" {
  description = "Max journal retention seconds"
  type        = string
}

variable "health_check_path" {
  description = "Health check HTTP path"
  type        = string
}

variable "health_check_max_attempts" {
  description = "Max health check attempts at startup"
  type        = number
}

variable "health_check_wait_seconds" {
  description = "Seconds between health check attempts"
  type        = number
}

variable "backup_cron_schedule" {
  description = "Cron schedule for realm backup"
  type        = string
}

variable "backup_log_path" {
  description = "Log path for backup cron"
  type        = string
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
}