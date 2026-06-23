module "load_balancer" {
  source = "./modules/load_balancer"

  project_id                    = var.project_id
  lb_name                       = local.lb_name
  lb_ip_name                    = local.lb_ip_name
  lb_hc_name                    = local.lb_hc_name
  mig_self_link                 = module.mig.instance_group_self_link
  keycloak_hostname             = local.keycloak_hostname
  keycloak_port                 = var.keycloak_port

  health_check_port             = var.health_check_port
  health_check_path             = var.health_check_path
  health_check_interval_sec     = var.health_check_interval_sec
  health_check_timeout_sec      = var.health_check_timeout_sec
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold

  lb_protocol                   = "HTTP"
  lb_port_name                  = var.lb_port_name
  lb_scheme                     = "EXTERNAL"
  lb_timeout_sec                = var.lb_timeout_sec
  lb_balancing_mode             = var.lb_balancing_mode
  lb_capacity_scaler            = var.lb_capacity_scaler
  lb_session_affinity           = var.lb_session_affinity
  lb_log_sample_rate            = var.lb_log_sample_rate

  lb_http_port                  = 80

  labels                        = local.common_labels

  depends_on = [module.mig]
}