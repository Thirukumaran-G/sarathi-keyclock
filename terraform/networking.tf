module "networking" {
  source = "./modules/networking"

  project_id               = var.project_id
  region                   = var.region
  network_name             = local.network_name
  vpc_auto_create_subnets  = var.vpc_auto_create_subnets
  subnet_name              = local.subnet_name
  subnet_cidr              = var.subnet_cidr
  subnet_private_google_access = var.subnet_private_google_access
  firewall_lb_name         = local.firewall_lb_name
  firewall_iap_name        = local.firewall_iap_name
  firewall_infinispan_name = local.firewall_infinispan_name
  fw_lb_protocol           = var.fw_lb_protocol
  fw_lb_source_ranges      = var.fw_lb_source_ranges
  fw_iap_protocol          = var.fw_iap_protocol
  fw_iap_source_ranges     = var.fw_iap_source_ranges
  fw_iap_port              = var.fw_iap_port
  fw_infinispan_protocol   = var.fw_infinispan_protocol
  health_check_port = var.health_check_port
  keycloak_port            = var.keycloak_port
  infinispan_port          = var.infinispan_port
  vm_target_tags           = local.vm_tags
  labels                   = local.common_labels
}