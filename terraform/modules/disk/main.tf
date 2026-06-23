resource "google_compute_disk" "keycloak_data" {
  project = var.project_id
  name    = var.disk_name
  zone    = var.zone
  type    = var.disk_type
  size    = var.disk_size
  labels  = var.labels
}