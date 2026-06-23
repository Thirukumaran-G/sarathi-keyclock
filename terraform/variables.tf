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
  description = "Target CPU utilization for autoscaling 0.0 to 1.0"
  type        = number
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
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

variable "backup_retention_days" {
  description = "Days to retain GCS backups"
  type        = number
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

variable "db_password_length" {
  description = "Length of generated Keycloak DB password"
  type        = number
}

variable "ssl_cert_domains" {
  description = "Domains for managed SSL certificate"
  type        = list(string)
}

variable "infinispan_port" {
  description = "Infinispan JGroups cluster communication port"
  type        = number
}