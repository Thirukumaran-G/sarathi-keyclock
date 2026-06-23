output "mig_name" {
  description = "MIG name"
  value       = google_compute_region_instance_group_manager.keycloak.name
}

output "instance_group_self_link" {
  description = "Instance group self link for LB backend"
  value       = google_compute_region_instance_group_manager.keycloak.instance_group
}

output "mig_id" {
  description = "MIG resource ID"
  value       = google_compute_region_instance_group_manager.keycloak.id
}

output "health_check_id" {
  description = "Health check ID"
  value       = google_compute_health_check.keycloak.id
}