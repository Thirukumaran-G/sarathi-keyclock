output "self_link" {
  description = "Data disk self link"
  value       = google_compute_disk.keycloak_data.self_link
}

output "name" {
  description = "Data disk name"
  value       = google_compute_disk.keycloak_data.name
}

output "id" {
  description = "Data disk ID"
  value       = google_compute_disk.keycloak_data.id
}