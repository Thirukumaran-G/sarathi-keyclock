variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "sa_name" {
  description = "Service account name"
  type        = string
}

variable "display_name" {
  description = "Service account display name"
  type        = string
}

variable "roles" {
  description = "List of IAM roles to grant to the service account"
  type        = list(string)
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
}