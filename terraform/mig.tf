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

