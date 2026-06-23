resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = var.vpc_auto_create_subnets
}

resource "google_compute_subnetwork" "keycloak" {
  project                  = var.project_id
  name                     = var.subnet_name
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = var.subnet_private_google_access
}

resource "google_compute_firewall" "allow_lb_to_keycloak" {
  project     = var.project_id
  name        = var.firewall_lb_name
  network     = google_compute_network.vpc.name
  description = "Allow GCP load balancer to reach Keycloak"

  allow {
    protocol = var.fw_lb_protocol
    ports    = [tostring(var.keycloak_port)]
  }

  source_ranges = var.fw_lb_source_ranges
  target_tags   = var.vm_target_tags
}

resource "google_compute_firewall" "allow_iap_ssh" {
  project     = var.project_id
  name        = var.firewall_iap_name
  network     = google_compute_network.vpc.name
  description = "Allow SSH via IAP only"

  allow {
    protocol = var.fw_iap_protocol
    ports    = [var.fw_iap_port]
  }

  source_ranges = var.fw_iap_source_ranges
  target_tags   = var.vm_target_tags
}

resource "google_compute_firewall" "allow_infinispan" {
  project     = var.project_id
  name        = var.firewall_infinispan_name
  network     = google_compute_network.vpc.name
  description = "Allow Infinispan clustering between Keycloak nodes"

  allow {
    protocol = var.fw_infinispan_protocol
    ports    = [tostring(var.infinispan_port)]
  }

  source_tags = var.vm_target_tags
  target_tags = var.vm_target_tags
}

resource "google_compute_router" "nat_router" {
  name    = "sarthi-router-dev-01"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "sarthi-nat-dev-01"
  project                            = var.project_id
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}