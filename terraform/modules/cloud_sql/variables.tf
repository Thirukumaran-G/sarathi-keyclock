variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}

variable "database_version" {
  description = "Postgres version"
  type        = string
}

variable "tier" {
  description = "Cloud SQL machine tier"
  type        = string
}

variable "disk_size" {
  description = "Cloud SQL disk size GB"
  type        = number
}

variable "disk_type" {
  description = "Cloud SQL disk type"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "network_self_link" {
  description = "VPC network self link"
  type        = string
}

variable "peering_address_name" {
  description = "Name for VPC peering address"
  type        = string
}

variable "peering_prefix_length" {
  description = "Prefix length for VPC peering range"
  type        = number
}

variable "peering_purpose" {
  description = "Purpose for VPC peering address"
  type        = string
}

variable "peering_address_type" {
  description = "Address type for VPC peering"
  type        = string
}

variable "peering_service" {
  description = "Service networking service name"
  type        = string
}

variable "backup_start_time" {
  description = "Backup start time"
  type        = string
}

variable "maintenance_day" {
  description = "Maintenance window day"
  type        = number
}

variable "maintenance_hour" {
  description = "Maintenance window hour"
  type        = number
}

variable "maintenance_track" {
  description = "Maintenance update track"
  type        = string
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
}

variable "ipv4_enabled" {
  description = "Enable public IPv4"
  type        = bool
}

variable "private_path_enabled" {
  description = "Enable private path for Google services"
  type        = bool
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
}