resource "google_dns_record_set" "keycloak" {
  project      = var.project_id
  managed_zone = var.dns_managed_zone_name
  name         = "${local.keycloak_hostname}."
  type         = var.dns_record_type
  ttl          = var.dns_record_ttl
  rrdatas      = [module.load_balancer.lb_ip_address]

  depends_on = [module.load_balancer]
}