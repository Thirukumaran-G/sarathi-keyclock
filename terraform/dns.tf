resource "google_dns_managed_zone" "sarthi" {
  name        = var.dns_managed_zone_name      
  dns_name    = "${var.environment}.${var.domain_name}."  
  description = "Managed zone for Sarthi ${var.environment} environment"
  project     = var.project_id

  dnssec_config {
    state = "off"
  }
}

resource "google_dns_record_set" "keycloak" {
  project      = var.project_id
  managed_zone = google_dns_managed_zone.sarthi.name
  name         = "${local.keycloak_hostname}."
  type         = var.dns_record_type            
  ttl          = var.dns_record_ttl            
  rrdatas      = [module.load_balancer.lb_ip_address]

  depends_on = [module.load_balancer]
}