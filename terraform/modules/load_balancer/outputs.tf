output "lb_ip_address" {
  description = "Load balancer global IP"
  value       = google_compute_global_address.lb_ip.address
}

output "backend_service_id" {
  description = "Backend service ID"
  value       = google_compute_backend_service.keycloak.id
}

output "ssl_cert_id" {
  description = "SSL certificate ID"
  value       = google_compute_managed_ssl_certificate.keycloak.id
}