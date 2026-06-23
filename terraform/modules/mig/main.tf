resource "google_compute_health_check" "keycloak" {
  project = var.project_id
  name    = "${var.mig_name}-hc"

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
  }

  check_interval_sec  = var.health_check_interval
  timeout_sec         = var.health_check_timeout
  healthy_threshold   = var.health_check_healthy
  unhealthy_threshold = var.health_check_unhealthy
}

resource "google_compute_region_instance_group_manager" "keycloak" {
  project            = var.project_id
  name               = var.mig_name
  region             = var.region
  base_instance_name = var.mig_name

  version {
    instance_template = var.template_self_link
  }

  named_port {
    name = var.lb_port_name
    port = var.keycloak_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.keycloak.id
    initial_delay_sec = var.initial_delay_sec
  }

  update_policy {
    type                  = var.update_type
    minimal_action        = var.minimal_action
    max_surge_fixed       = var.max_surge
    max_unavailable_fixed = var.max_unavailable
    replacement_method    = var.replacement_method
  }

  # ←←← ADD THIS BLOCK
  stateful_disk {
    device_name = "keycloak-data"
    delete_rule = "NEVER"
  }
}

resource "google_compute_region_autoscaler" "keycloak" {
  project = var.project_id
  name    = "${var.mig_name}-asc"
  region  = var.region
  target  = google_compute_region_instance_group_manager.keycloak.id

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = var.cooldown_period

    cpu_utilization {
      target = var.cpu_target
    }
  }
}