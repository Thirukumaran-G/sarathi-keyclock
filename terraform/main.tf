module "service_account" {
  source = "./modules/service_account"

  project_id   = var.project_id
  sa_name      = local.sa_keycloak_name
  display_name = local.sa_keycloak_display
  labels       = local.common_labels
}

module "secrets" {
  source = "./modules/secrets"

  project_id            = var.project_id
  admin_secret_name     = local.secret_admin_password_name
  db_secret_name        = local.secret_db_password_name
  admin_password_length = var.admin_password_length
  db_password_length    = var.db_password_length
  labels                = local.common_labels
  sa_keycloak_email     = module.service_account.email
}

module "networking" {
  source = "./modules/networking"

  project_id               = var.project_id
  region                   = var.region
  network_name             = local.network_name
  subnet_name              = local.subnet_name
  subnet_cidr              = var.subnet_cidr
  firewall_lb_name         = local.firewall_lb_name
  firewall_iap_name        = local.firewall_iap_name
  firewall_infinispan_name = local.firewall_infinispan_name
  keycloak_port            = var.keycloak_port
  infinispan_port          = var.infinispan_port
  vm_target_tags           = local.vm_tags
  labels                   = local.common_labels
}

module "cloud_sql" {
  source = "./modules/cloud_sql"

  project_id        = var.project_id
  region            = var.region
  instance_name     = local.sql_instance_name
  database_version  = var.cloud_sql_postgres_version
  tier              = var.cloud_sql_tier
  disk_size         = var.cloud_sql_disk_size_gb
  disk_type         = var.cloud_sql_disk_type
  db_name           = var.keycloak_db_name
  db_user           = var.keycloak_db_user
  db_password       = module.secrets.db_password_value
  network_self_link = module.networking.network_self_link
  labels            = local.common_labels

  depends_on = [module.networking]
}

module "disk" {
  source = "./modules/disk"

  project_id = var.project_id
  zone       = var.zone
  disk_name  = local.data_disk_name
  disk_size  = var.vm_data_disk_size_gb
  disk_type  = var.vm_data_disk_type
  labels     = local.common_labels
}

module "gcs_backup" {
  source = "./modules/gcs_backup"

  project_id        = var.project_id
  bucket_name       = local.backup_bucket_name
  location          = var.region
  retention_days    = var.backup_retention_days
  sa_keycloak_email = module.service_account.email
  labels            = local.common_labels
}

module "instance_template" {
  source = "./modules/instance_template"

  project_id           = var.project_id
  region               = var.region
  template_name        = local.instance_template_name
  machine_type         = var.vm_machine_type
  boot_disk_image      = var.vm_image
  boot_disk_size       = var.vm_boot_disk_size_gb
  boot_disk_type       = var.vm_boot_disk_type
  network_self_link    = module.networking.network_self_link
  subnet_self_link     = module.networking.subnet_self_link
  sa_email             = module.service_account.email
  vm_tags              = local.vm_tags
  keycloak_version     = var.keycloak_version
  keycloak_port        = var.keycloak_port
  keycloak_db_name     = var.keycloak_db_name
  keycloak_db_user     = var.keycloak_db_user
  cloud_sql_instance   = local.sql_instance_name
  project_id_for_proxy = var.project_id
  region_for_proxy     = var.region
  admin_secret_name    = local.secret_admin_password_name
  db_secret_name       = local.secret_db_password_name
  backup_bucket_name   = local.backup_bucket_name
  environment          = local.env
  docker_log_max_size  = var.docker_log_max_size
  docker_log_max_file  = var.docker_log_max_file
  keycloak_hostname    = local.keycloak_hostname
  infinispan_port      = var.infinispan_port
  subnet_cidr          = var.subnet_cidr
  labels               = local.common_labels

  depends_on = [
    module.cloud_sql,
    module.secrets,
    module.networking,
    module.gcs_backup
  ]
}

module "mig" {
  source = "./modules/mig"

  project_id         = var.project_id
  region             = var.region
  mig_name           = local.mig_name
  template_self_link = module.instance_template.self_link
  min_replicas       = var.mig_min_replicas
  max_replicas       = var.mig_max_replicas
  cooldown_period    = var.mig_cooldown_period
  cpu_target         = var.mig_cpu_target
  keycloak_port      = var.keycloak_port
  health_check_port  = var.health_check_port
  labels             = local.common_labels

  depends_on = [module.instance_template]
}

module "load_balancer" {
  source = "./modules/load_balancer"

  project_id        = var.project_id
  region            = var.region
  lb_name           = local.lb_name
  ssl_cert_name     = local.ssl_cert_name
  ssl_cert_domains  = var.ssl_cert_domains
  mig_self_link     = module.mig.instance_group_self_link
  keycloak_port     = var.keycloak_port
  health_check_port = var.health_check_port
  keycloak_hostname = local.keycloak_hostname
  labels            = local.common_labels

  depends_on = [module.mig]
}

module "dns" {
  source = "./modules/dns"

  project_id        = var.project_id
  managed_zone_name = var.dns_managed_zone_name
  keycloak_hostname = local.keycloak_hostname
  lb_ip_address     = module.load_balancer.lb_ip_address

  depends_on = [module.load_balancer]
}