variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "vpc_auto_create_subnets" {
  description = "Auto create subnets"
  type        = bool
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
}

variable "subnet_private_google_access" {
  description = "Enable private Google access"
  type        = bool
}

variable "firewall_lb_name" {
  description = "Firewall rule name for LB traffic"
  type        = string
}

variable "firewall_iap_name" {
  description = "Firewall rule name for IAP SSH"
  type        = string
}

variable "firewall_infinispan_name" {
  description = "Firewall rule name for Infinispan"
  type        = string
}

variable "fw_lb_protocol" {
  description = "Protocol for LB firewall rule"
  type        = string
}

variable "fw_lb_source_ranges" {
  description = "Source ranges for LB firewall rule"
  type        = list(string)
}

variable "fw_iap_protocol" {
  description = "Protocol for IAP firewall rule"
  type        = string
}

variable "fw_iap_source_ranges" {
  description = "Source ranges for IAP firewall rule"
  type        = list(string)
}

variable "fw_iap_port" {
  description = "SSH port for IAP firewall rule"
  type        = string
}

variable "fw_infinispan_protocol" {
  description = "Protocol for Infinispan firewall rule"
  type        = string
}

variable "keycloak_port" {
  description = "Keycloak HTTP port"
  type        = number
}

variable "infinispan_port" {
  description = "Infinispan JGroups port"
  type        = number
}

variable "vm_target_tags" {
  description = "Network tags on Keycloak VMs"
  type        = list(string)
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
}