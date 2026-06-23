output "email" {
  description = "Service account email"
  value       = google_service_account.keycloak.email
}

output "name" {
  description = "Service account name"
  value       = google_service_account.keycloak.name
}

output "unique_id" {
  description = "Service account unique ID"
  value       = google_service_account.keycloak.unique_id
}