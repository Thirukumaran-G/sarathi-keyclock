locals {
  startup_script = templatefile("${path.root}/../scripts/startup.sh", {
    keycloak_version           = var.keycloak_version
    keycloak_port              = var.keycloak_port
    keycloak_db_name           = var.keycloak_db_name
    keycloak_db_user           = var.keycloak_db_user
    keycloak_admin_user        = var.keycloak_admin_user
    keycloak_cache_mode        = var.keycloak_cache_mode
    keycloak_cache_stack       = var.keycloak_cache_stack
    keycloak_image_repo        = var.keycloak_image_repo
    keycloak_start_command     = var.keycloak_start_command
    cloud_sql_instance         = var.cloud_sql_instance
    project_id                 = var.project_id_for_proxy
    region                     = var.region_for_proxy
    cloud_sql_proxy_image      = var.cloud_sql_proxy_image
    cloud_sql_proxy_log_flag   = var.cloud_sql_proxy_log_flag
    cloud_sql_proxy_port_flag  = var.cloud_sql_proxy_port_flag
    compose_version            = var.compose_version
    admin_secret_name          = var.admin_secret_name
    db_secret_name             = var.db_secret_name
    backup_bucket_name         = var.backup_bucket_name
    environment                = var.environment
    docker_log_max_size        = var.docker_log_max_size
    docker_log_max_file        = var.docker_log_max_file
    keycloak_hostname          = var.keycloak_hostname
    infinispan_port            = var.infinispan_port
    subnet_cidr                = var.subnet_cidr
    disk_filesystem_type       = var.disk_filesystem_type
    disk_mount_options         = var.disk_mount_options
    disk_fstab_dump            = var.disk_fstab_dump
    disk_fstab_pass            = var.disk_fstab_pass
    journald_max_use           = var.journald_max_use
    journald_max_file_size     = var.journald_max_file_size
    journald_max_retention_sec = var.journald_max_retention_sec
    health_check_path          = var.health_check_path
    health_check_max_attempts  = var.health_check_max_attempts
    health_check_wait_seconds  = var.health_check_wait_seconds
    backup_cron_schedule       = var.backup_cron_schedule
    backup_log_path            = var.backup_log_path
  })
}


resource "google_compute_instance_template" "keycloak" {
  project      = var.project_id
  name_prefix  = "${var.template_name}-"
  machine_type = var.machine_type
  region       = var.region
  labels       = var.labels
  tags         = var.vm_tags

  disk {
    source_image = var.boot_disk_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.boot_disk_size
    disk_type    = var.boot_disk_type
  }

  disk {
    device_name  = "keycloak-data"
    auto_delete  = true
    boot         = false
    disk_size_gb = var.data_disk_size
    disk_type    = var.data_disk_type
    type         = "PERSISTENT"
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = var.subnet_self_link
  }

  service_account {
    email  = var.sa_email
    scopes = var.vm_scopes
  }

  metadata = {
    startup-script              = local.startup_script
    (var.os_login_metadata_key) = var.os_login_metadata_value
  }

  shielded_instance_config {
    enable_secure_boot          = var.shielded_secure_boot
    enable_vtpm                 = var.shielded_vtpm
    enable_integrity_monitoring = var.shielded_integrity_monitoring
  }

  lifecycle {
    create_before_destroy = true
  }
}