output "keycloak_url" {
  description = "Keycloak public URL"
  value       = "https://${local.keycloak_hostname}"
}

output "lb_ip_address" {
  description = "Load balancer IP address"
  value       = module.load_balancer.lb_ip_address
}

output "mig_name" {
  description = "Managed instance group name"
  value       = module.mig.mig_name
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL connection name"
  value       = module.cloud_sql.connection_name
}

output "backup_bucket_name" {
  description = "GCS backup bucket name"
  value       = module.gcs_backup.bucket_name
}

output "sa_keycloak_email" {
  description = "Keycloak service account email"
  value       = module.service_account.email
}

output "admin_secret_name" {
  description = "Secret Manager name for admin password"
  value       = module.secrets.admin_secret_name
}

output "dns_fqdn" {
  description = "Keycloak DNS record FQDN"
  value       = "${local.keycloak_hostname}."
}