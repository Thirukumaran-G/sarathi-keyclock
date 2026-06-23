variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone for data disk"
  type        = string
}

variable "environment" {
  description = "Environment name e.g. dev staging prod"
  type        = string
}

variable "domain_name" {
  description = "Base domain name e.g. sarthi.io"
  type        = string
}

variable "dns_managed_zone_name" {
  description = "Existing Cloud DNS managed zone name"
  type        = string
}

variable "dns_record_ttl" {
  description = "TTL for DNS A record in seconds"
  type        = number
}

variable "dns_record_type" {
  description = "DNS record type"
  type        = string
}

variable "vm_machine_type" {
  description = "GCE machine type for Keycloak instances"
  type        = string
}

variable "vm_boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
}

variable "vm_boot_disk_type" {
  description = "Boot disk type"
  type        = string
}

variable "vm_data_disk_size_gb" {
  description = "Data disk size in GB"
  type        = number
}

variable "vm_data_disk_type" {
  description = "Data disk type"
  type        = string
}

variable "vm_image" {
  description = "GCE boot image"
  type        = string
}

variable "vm_os_login_metadata_key" {
  description = "Metadata key to enable OS login"
  type        = string
}

variable "vm_os_login_metadata_value" {
  description = "Metadata value to enable OS login"
  type        = string
}

variable "vm_scopes" {
  description = "OAuth scopes for VM service account"
  type        = list(string)
}

variable "mig_min_replicas" {
  description = "Minimum number of instances in MIG"
  type        = number
}

variable "mig_max_replicas" {
  description = "Maximum number of instances in MIG"
  type        = number
}

variable "mig_cooldown_period" {
  description = "Autoscaler cooldown period in seconds"
  type        = number
}

variable "mig_cpu_target" {
  description = "Target CPU utilization for autoscaling"
  type        = number
}

variable "mig_initial_delay_sec" {
  description = "Initial delay for auto healing in seconds"
  type        = number
}

variable "mig_update_type" {
  description = "MIG update policy type"
  type        = string
}

variable "mig_minimal_action" {
  description = "MIG update minimal action"
  type        = string
}

variable "mig_max_surge" {
  description = "MIG update max surge fixed"
  type        = number
}

variable "mig_max_unavailable" {
  description = "MIG update max unavailable fixed"
  type        = number
}

variable "mig_replacement_method" {
  description = "MIG replacement method"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
}

variable "subnet_private_google_access" {
  description = "Enable private Google access on subnet"
  type        = bool
}

variable "vpc_auto_create_subnets" {
  description = "Auto create subnets in VPC"
  type        = bool
}

variable "fw_lb_source_ranges" {
  description = "Source IP ranges for LB firewall rule"
  type        = list(string)
}

variable "fw_iap_source_ranges" {
  description = "Source IP ranges for IAP SSH firewall rule"
  type        = list(string)
}

variable "fw_lb_protocol" {
  description = "Protocol for LB firewall rule"
  type        = string
}

variable "fw_iap_protocol" {
  description = "Protocol for IAP firewall rule"
  type        = string
}

variable "fw_infinispan_protocol" {
  description = "Protocol for Infinispan firewall rule"
  type        = string
}

variable "fw_iap_port" {
  description = "SSH port for IAP firewall rule"
  type        = string
}

variable "sql_vpc_peering_prefix_length" {
  description = "Prefix length for Cloud SQL VPC peering IP range"
  type        = number
}

variable "sql_vpc_peering_purpose" {
  description = "Purpose for Cloud SQL VPC peering address"
  type        = string
}

variable "sql_vpc_peering_address_type" {
  description = "Address type for Cloud SQL VPC peering"
  type        = string
}

variable "sql_vpc_peering_service" {
  description = "Service networking service for Cloud SQL peering"
  type        = string
}

variable "cloud_sql_tier" {
  description = "Cloud SQL machine tier"
  type        = string
}

variable "cloud_sql_disk_size_gb" {
  description = "Cloud SQL disk size in GB"
  type        = number
}

variable "cloud_sql_disk_type" {
  description = "Cloud SQL disk type"
  type        = string
}

variable "cloud_sql_postgres_version" {
  description = "Postgres version for Cloud SQL"
  type        = string
}

variable "cloud_sql_instance_name" {
  description = "Cloud SQL instance name base"
  type        = string
}

variable "cloud_sql_backup_start_time" {
  description = "Cloud SQL backup start time"
  type        = string
}

variable "cloud_sql_maintenance_day" {
  description = "Cloud SQL maintenance window day"
  type        = number
}

variable "cloud_sql_maintenance_hour" {
  description = "Cloud SQL maintenance window hour"
  type        = number
}

variable "cloud_sql_maintenance_track" {
  description = "Cloud SQL maintenance update track"
  type        = string
}

variable "cloud_sql_deletion_protection" {
  description = "Enable deletion protection on Cloud SQL"
  type        = bool
}

variable "cloud_sql_ipv4_enabled" {
  description = "Enable public IPv4 on Cloud SQL"
  type        = bool
}

variable "cloud_sql_private_path_enabled" {
  description = "Enable private path for Google Cloud services"
  type        = bool
}

variable "keycloak_db_name" {
  description = "Database name for Keycloak"
  type        = string
}

variable "keycloak_db_user" {
  description = "Cloud SQL user for Keycloak"
  type        = string
}

variable "keycloak_version" {
  description = "Keycloak Docker image version"
  type        = string
}

variable "keycloak_port" {
  description = "Port Keycloak listens on"
  type        = number
}

variable "health_check_port" {
  description = "Port for load balancer health check"
  type        = number
}

variable "health_check_interval_sec" {
  description = "Health check interval in seconds"
  type        = number
}

variable "health_check_timeout_sec" {
  description = "Health check timeout in seconds"
  type        = number
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold for health check"
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for health check"
  type        = number
}

variable "health_check_path" {
  description = "Health check HTTP path"
  type        = string
}

variable "lb_protocol" {
  description = "Load balancer backend protocol"
  type        = string
}

variable "lb_port_name" {
  description = "Named port for load balancer backend"
  type        = string
}

variable "lb_scheme" {
  description = "Load balancing scheme"
  type        = string
}

variable "lb_timeout_sec" {
  description = "Load balancer backend timeout in seconds"
  type        = number
}

variable "lb_balancing_mode" {
  description = "Backend balancing mode"
  type        = string
}

variable "lb_capacity_scaler" {
  description = "Backend capacity scaler"
  type        = number
}

variable "lb_session_affinity" {
  description = "Session affinity type"
  type        = string
}

variable "lb_session_cookie_name" {
  description = "Session affinity cookie name"
  type        = string
}

variable "lb_session_cookie_ttl_seconds" {
  description = "Session affinity cookie TTL in seconds"
  type        = number
}

variable "lb_log_sample_rate" {
  description = "Load balancer log sample rate"
  type        = number
}

variable "lb_https_port" {
  description = "HTTPS port for forwarding rule"
  type        = string
}

variable "lb_http_port" {
  description = "HTTP port for redirect forwarding rule"
  type        = string
}

variable "lb_http_redirect_response_code" {
  description = "HTTP to HTTPS redirect response code"
  type        = string
}

variable "backup_retention_days" {
  description = "Days to retain GCS backups"
  type        = number
}

variable "backup_num_newer_versions" {
  description = "Number of newer versions to keep in GCS"
  type        = number
}

variable "bucket_public_access_prevention" {
  description = "Public access prevention setting for GCS bucket"
  type        = string
}

variable "bucket_force_destroy" {
  description = "Allow force destroy of GCS bucket"
  type        = bool
}

variable "docker_log_max_size" {
  description = "Max size per Docker log file"
  type        = string
}

variable "docker_log_max_file" {
  description = "Max number of Docker log files"
  type        = string
}

variable "admin_password_length" {
  description = "Length of generated Keycloak admin password"
  type        = number
}

variable "admin_password_special" {
  description = "Use special characters in admin password"
  type        = bool
}

variable "admin_password_override_special" {
  description = "Special characters allowed in admin password"
  type        = string
}

variable "db_password_length" {
  description = "Length of generated Keycloak DB password"
  type        = number
}

variable "db_password_special" {
  description = "Use special characters in DB password"
  type        = bool
}

variable "db_password_override_special" {
  description = "Special characters allowed in DB password"
  type        = string
}

variable "secret_replication_policy" {
  description = "Secret Manager replication policy type"
  type        = string
}

variable "secret_accessor_role" {
  description = "IAM role for secret accessor"
  type        = string
}

variable "sa_roles" {
  description = "IAM roles to grant to Keycloak service account"
  type        = list(string)
}

variable "ssl_cert_domains" {
  description = "Domains for managed SSL certificate"
  type        = list(string)
}

variable "infinispan_port" {
  description = "Infinispan JGroups cluster communication port"
  type        = number
}

variable "shielded_secure_boot" {
  description = "Enable secure boot on shielded VM"
  type        = bool
}

variable "shielded_vtpm" {
  description = "Enable vTPM on shielded VM"
  type        = bool
}

variable "shielded_integrity_monitoring" {
  description = "Enable integrity monitoring on shielded VM"
  type        = bool
}

variable "template_create_before_destroy" {
  description = "Create new template before destroying old one"
  type        = bool
}

variable "disk_filesystem_type" {
  description = "Filesystem type for data disk"
  type        = string
}

variable "disk_mount_options" {
  description = "Mount options for data disk in fstab"
  type        = string
}

variable "disk_fstab_dump" {
  description = "fstab dump value for data disk"
  type        = string
}

variable "disk_fstab_pass" {
  description = "fstab pass value for data disk"
  type        = string
}

variable "journald_max_use" {
  description = "Maximum journal disk usage"
  type        = string
}

variable "journald_max_file_size" {
  description = "Maximum journal file size"
  type        = string
}

variable "journald_max_retention_sec" {
  description = "Maximum journal retention in seconds"
  type        = string
}

variable "health_check_max_attempts" {
  description = "Max attempts in startup health check loop"
  type        = number
}

variable "health_check_wait_seconds" {
  description = "Seconds to wait between health check attempts"
  type        = number
}

variable "backup_cron_schedule" {
  description = "Cron schedule for Keycloak realm backup"
  type        = string
}

variable "backup_log_path" {
  description = "Log file path for backup cron job"
  type        = string
}

variable "keycloak_admin_user" {
  description = "Keycloak admin username"
  type        = string
}

variable "keycloak_cache_mode" {
  description = "Keycloak cache mode ispn for cluster local for single"
  type        = string
}

variable "keycloak_cache_stack" {
  description = "Keycloak cache stack for Infinispan"
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

variable "keycloak_image_repo" {
  description = "Keycloak Docker image repository"
  type        = string
}

variable "keycloak_start_command" {
  description = "Keycloak container start command"
  type        = string
}

variable "compose_version" {
  description = "Docker compose file version"
  type        = string
}

variable "gcs_bucket_versioning_enabled" {
  description = "Enable versioning on GCS bucket"
  type        = bool
}

variable "gcs_lifecycle_action_type" {
  description = "GCS lifecycle rule action type"
  type        = string
}

variable "gcs_writer_role" {
  description = "IAM role for GCS bucket writer"
  type        = string
}

variable "sql_networking_peering_address_name" {
  description = "Name for the Cloud SQL VPC peering address"
  type        = string
}