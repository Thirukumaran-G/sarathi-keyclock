resource "google_compute_global_address" "lb_ip" {
  project = var.project_id
  name    = var.lb_ip_name
}

resource "google_compute_health_check" "keycloak_lb" {
  project = var.project_id
  name    = var.lb_hc_name

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
  }

  check_interval_sec  = var.health_check_interval_sec
  timeout_sec         = var.health_check_timeout_sec
  healthy_threshold   = var.health_check_healthy_threshold
  unhealthy_threshold = var.health_check_unhealthy_threshold
}

resource "google_compute_backend_service" "keycloak" {
  project               = var.project_id
  name                  = "${var.lb_name}-backend"
  protocol              = var.lb_protocol
  port_name             = var.lb_port_name
  load_balancing_scheme = var.lb_scheme
  timeout_sec           = var.lb_timeout_sec
  session_affinity      = var.lb_session_affinity

  backend {
    group           = var.mig_self_link
    balancing_mode  = var.lb_balancing_mode
    capacity_scaler = var.lb_capacity_scaler
  }

  health_checks = [google_compute_health_check.keycloak_lb.id]

  log_config {
    enable      = true
    sample_rate = var.lb_log_sample_rate
  }
}

resource "google_compute_url_map" "keycloak" {
  project         = var.project_id
  name            = "${var.lb_name}-urlmap"
  default_service = google_compute_backend_service.keycloak.id

  host_rule {
    hosts        = [var.keycloak_hostname]
    path_matcher = "keycloak-paths"
  }

  path_matcher {
    name            = "keycloak-paths"
    default_service = google_compute_backend_service.keycloak.id
  }
}

resource "google_compute_managed_ssl_certificate" "keycloak" {
  project = var.project_id
  name    = var.ssl_cert_name

  managed {
    domains = var.ssl_cert_domains
  }
}

resource "google_compute_target_https_proxy" "keycloak" {
  project          = var.project_id
  name             = "${var.lb_name}-https-proxy"
  url_map          = google_compute_url_map.keycloak.id
  ssl_certificates = [google_compute_managed_ssl_certificate.keycloak.id]
}

resource "google_compute_global_forwarding_rule" "keycloak_https" {
  project               = var.project_id
  name                  = "${var.lb_name}-https-fwd"
  target                = google_compute_target_https_proxy.keycloak.id
  port_range            = var.lb_https_port
  ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = var.lb_scheme
}

resource "google_compute_url_map" "http_redirect" {
  project = var.project_id
  name    = "${var.lb_name}-http-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = var.lb_http_redirect_response_code
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  project = var.project_id
  name    = "${var.lb_name}-http-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

resource "google_compute_global_forwarding_rule" "http_redirect" {
  project               = var.project_id
  name                  = "${var.lb_name}-http-fwd"
  target                = google_compute_target_http_proxy.redirect.id
  port_range            = var.lb_http_port
  ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = var.lb_scheme
}