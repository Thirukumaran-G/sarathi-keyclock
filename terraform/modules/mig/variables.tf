variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "mig_name" {
  description = "MIG name"
  type        = string
}

variable "template_self_link" {
  description = "Instance template self link"
  type        = string
}

variable "min_replicas" {
  description = "Minimum instances"
  type        = number
}

variable "max_replicas" {
  description = "Maximum instances"
  type        = number
}

variable "cooldown_period" {
  description = "Autoscaler cooldown seconds"
  type        = number
}

variable "cpu_target" {
  description = "Target CPU utilization"
  type        = number
}

variable "initial_delay_sec" {
  description = "Auto healing initial delay seconds"
  type        = number
}

variable "update_type" {
  description = "Update policy type"
  type        = string
}

variable "minimal_action" {
  description = "Update minimal action"
  type        = string
}

variable "max_surge" {
  description = "Max surge fixed"
  type        = number
}

variable "max_unavailable" {
  description = "Max unavailable fixed"
  type        = number
}

variable "replacement_method" {
  description = "Replacement method"
  type        = string
}

variable "keycloak_port" {
  description = "Keycloak port"
  type        = number
}

variable "lb_port_name" {
  description = "Named port name"
  type        = string
}

variable "health_check_port" {
  description = "Health check port"
  type        = number
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
}

variable "health_check_interval" {
  description = "Health check interval seconds"
  type        = number
}

variable "health_check_timeout" {
  description = "Health check timeout seconds"
  type        = number
}

variable "health_check_healthy" {
  description = "Healthy threshold"
  type        = number
}

variable "health_check_unhealthy" {
  description = "Unhealthy threshold"
  type        = number
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
}