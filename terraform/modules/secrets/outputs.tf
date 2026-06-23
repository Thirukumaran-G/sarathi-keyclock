output "admin_secret_name" {
  description = "Admin password secret name"
  value       = google_secret_manager_secret.admin_password.secret_id
}

output "db_secret_name" {
  description = "DB password secret name"
  value       = google_secret_manager_secret.db_password.secret_id
}

output "db_password_value" {
  description = "Generated DB password value"
  value       = random_password.db.result
  sensitive   = true
}