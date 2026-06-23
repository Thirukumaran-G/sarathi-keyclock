variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "admin_secret_name" {
  description = "Secret name for admin password"
  type        = string
}

variable "db_secret_name" {
  description = "Secret name for DB password"
  type        = string
}

variable "admin_password_length" {
  description = "Length of admin password"
  type        = number
}

variable "admin_password_special" {
  description = "Use special characters in admin password"
  type        = bool
}

variable "admin_password_override_special" {
  description = "Allowed special characters in admin password"
  type        = string
}

variable "db_password_length" {
  description = "Length of DB password"
  type        = number
}

variable "db_password_special" {
  description = "Use special characters in DB password"
  type        = bool
}

variable "db_password_override_special" {
  description = "Allowed special characters in DB password"
  type        = string
}

variable "replication_policy" {
  description = "Secret Manager replication policy"
  type        = string
}

variable "secret_accessor_role" {
  description = "IAM role for secret accessor"
  type        = string
}

variable "sa_keycloak_email" {
  description = "Keycloak SA email to grant access"
  type        = string
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
}