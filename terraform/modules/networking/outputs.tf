output "network_self_link" {
  description = "VPC network self link"
  value       = google_compute_network.vpc.self_link
}

output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "subnet_self_link" {
  description = "Subnet self link"
  value       = google_compute_subnetwork.keycloak.self_link
}

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.keycloak.name
}

output "subnet_cidr" {
  description = "Subnet CIDR"
  value       = google_compute_subnetwork.keycloak.ip_cidr_range
}