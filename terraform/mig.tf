module "mig" {
  source = "./modules/mig"

  project_id             = var.project_id
  region                 = var.region
  mig_name               = local.mig_name
  template_self_link     = module.instance_template.self_link
  min_replicas           = var.mig_min_replicas
  max_replicas           = var.mig_max_replicas
  cooldown_period        = var.mig_cooldown_period
  cpu_target             = var.mig_cpu_target
  initial_delay_sec      = var.mig_initial_delay_sec
  update_type            = var.mig_update_type
  minimal_action         = var.mig_minimal_action
  max_surge              = var.mig_max_surge
  max_unavailable        = var.mig_max_unavailable
  replacement_method     = var.mig_replacement_method
  keycloak_port          = var.keycloak_port
  lb_port_name           = var.lb_port_name
  health_check_port      = var.health_check_port
  health_check_path      = var.health_check_path
  health_check_interval  = var.health_check_interval_sec
  health_check_timeout   = var.health_check_timeout_sec
  health_check_healthy   = var.health_check_healthy_threshold
  health_check_unhealthy = var.health_check_unhealthy_threshold
  labels                 = local.common_labels

  depends_on = [module.instance_template]
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