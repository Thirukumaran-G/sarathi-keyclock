variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "disk_name" {
  description = "Data disk name"
  type        = string
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
}

variable "disk_type" {
  description = "Disk type"
  type        = string
}

variable "labels" {
  description = "Labels to apply"
  type        = map(string)
}