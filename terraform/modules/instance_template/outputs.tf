output "self_link" {
  description = "Instance template self link"
  value       = google_compute_instance_template.keycloak.self_link
}

output "name" {
  description = "Instance template name"
  value       = google_compute_instance_template.keycloak.name
}

output "id" {
  description = "Instance template ID"
  value       = google_compute_instance_template.keycloak.id
}