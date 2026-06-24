module "instance_template" {
  source = "./modules/instance_template"

  project_id                    = var.project_id
  region                        = var.region
  template_name                 = local.instance_template_name
  machine_type                  = var.vm_machine_type
  boot_disk_image               = var.vm_image
  boot_disk_size                = var.vm_boot_disk_size_gb
  boot_disk_type                = var.vm_boot_disk_type
  network_self_link             = module.networking.network_self_link
  subnet_self_link              = module.networking.subnet_self_link
  sa_email                      = module.service_account.email
  vm_scopes                     = var.vm_scopes
  vm_tags                       = local.vm_tags
  os_login_metadata_key         = var.vm_os_login_metadata_key
  os_login_metadata_value       = var.vm_os_login_metadata_value
  shielded_secure_boot          = var.shielded_secure_boot
  shielded_vtpm                 = var.shielded_vtpm
  shielded_integrity_monitoring = var.shielded_integrity_monitoring
  create_before_destroy         = var.template_create_before_destroy
  data_disk_size                = var.data_disk_size
  data_disk_type                = var.data_disk_type
  keycloak_version              = var.keycloak_version
  keycloak_port                 = var.keycloak_port
  keycloak_db_name              = var.keycloak_db_name
  keycloak_db_user              = var.keycloak_db_user
  keycloak_admin_user           = var.keycloak_admin_user
  keycloak_cache_mode           = var.keycloak_cache_mode
  keycloak_cache_stack          = var.keycloak_cache_stack
  keycloak_image_repo           = var.keycloak_image_repo
  keycloak_start_command        = var.keycloak_start_command
  cloud_sql_instance            = local.sql_instance_name
  project_id_for_proxy          = var.project_id
  region_for_proxy              = var.region
  cloud_sql_proxy_image         = var.cloud_sql_proxy_image
  cloud_sql_proxy_log_flag      = var.cloud_sql_proxy_log_flag
  cloud_sql_proxy_port_flag     = var.cloud_sql_proxy_port_flag
  compose_version               = var.compose_version
  admin_secret_name             = local.secret_admin_password_name
  db_secret_name                = local.secret_db_password_name
  backup_bucket_name            = local.backup_bucket_name
  environment                   = local.env
  docker_log_max_size           = var.docker_log_max_size
  docker_log_max_file           = var.docker_log_max_file
  infinispan_port               = var.infinispan_port
  subnet_cidr                   = var.subnet_cidr
  disk_filesystem_type          = var.disk_filesystem_type
  disk_mount_options            = var.disk_mount_options
  disk_fstab_dump               = var.disk_fstab_dump
  disk_fstab_pass               = var.disk_fstab_pass
  journald_max_use              = var.journald_max_use
  journald_max_file_size        = var.journald_max_file_size
  journald_max_retention_sec    = var.journald_max_retention_sec
  health_check_path             = var.health_check_path
  health_check_max_attempts     = var.health_check_max_attempts
  health_check_wait_seconds     = var.health_check_wait_seconds
  backup_cron_schedule          = var.backup_cron_schedule
  backup_log_path               = var.backup_log_path
  labels                        = local.common_labels

  depends_on = [
    module.cloud_sql,
    module.secrets,
    module.networking,
    module.gcs_backup
  ]
}