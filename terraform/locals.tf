locals {
  name_prefix = "sarthi"
  env         = var.environment

  keycloak_hostname = "keycloak.${var.environment}.${var.domain_name}"

  sa_keycloak_name    = "${local.name_prefix}-sa-keycloak-${local.env}-01"
  sa_keycloak_display = "Keycloak Service Account - ${local.env}"

  secret_admin_password_name = "${local.name_prefix}-sec-keycloak-admin-password-${local.env}-01"
  secret_db_password_name    = "${local.name_prefix}-sec-keycloak-db-password-${local.env}-01"

  sql_instance_name           = "${var.cloud_sql_instance_name}-${local.env}-01"
  sql_peering_address_name    = "${local.name_prefix}-${var.sql_networking_peering_address_name}-${local.env}-01"

  network_name             = "${local.name_prefix}-vpc-${local.env}-01"
  subnet_name              = "${local.name_prefix}-subnet-keycloak-${local.env}-01"
  firewall_lb_name         = "${local.name_prefix}-fw-keycloak-lb-${local.env}-01"
  firewall_iap_name        = "${local.name_prefix}-fw-keycloak-iap-${local.env}-01"
  firewall_infinispan_name = "${local.name_prefix}-fw-keycloak-ispn-${local.env}-01"

  data_disk_name = "${local.name_prefix}-disk-keycloak-data-${local.env}-01"

  instance_template_name = "${local.name_prefix}-tmpl-keycloak-${local.env}-01"
  mig_name               = "${local.name_prefix}-mig-keycloak-${local.env}-01"
  vm_tags                = ["keycloak-vm-${local.env}"]

  lb_name       = "${local.name_prefix}-lb-keycloak-${local.env}-01"
  lb_ip_name    = "${local.name_prefix}-lb-keycloak-ip-${local.env}-01"
  lb_hc_name    = "${local.name_prefix}-lb-keycloak-hc-${local.env}-01"
  ssl_cert_name = "${local.name_prefix}-ssl-keycloak-${local.env}-01"

  backup_bucket_name = "${local.name_prefix}-gcs-vm-backups-${local.env}-01"

  common_labels = {
    environment = local.env
    managed_by  = "terraform"
    project     = local.name_prefix
    service     = "keycloak"
  }
}