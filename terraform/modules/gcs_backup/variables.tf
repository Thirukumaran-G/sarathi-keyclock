variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "bucket_name" {
  description = "GCS bucket name"
  type        = string
}

variable "location" {
  description = "GCS bucket location"
  type        = string
}

variable "retention_days" {
  description = "Days before objects are deleted"
  type        = number
}

variable "num_newer_versions" {
  description = "Number of newer versions before deletion"
  type        = number
}

variable "public_access_prevention" {
  description = "Public access prevention setting"
  type        = string
}

variable "force_destroy" {
  description = "Allow force destroy of bucket"
  type        = bool
}

variable "versioning_enabled" {
  description = "Enable object versioning"
  type        = bool
}

variable "lifecycle_action_type" {
  description = "Lifecycle rule action type"
  type        = string
}

variable "writer_role" {
  description = "IAM role for bucket writer"
  type        = string
}

variable "sa_keycloak_email" {
  description = "Keycloak SA email for write access"
  type        = string
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
}