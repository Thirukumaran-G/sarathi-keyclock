module "cloud_sql" {
  source = "./modules/cloud_sql"

  project_id                  = var.project_id
  region                      = var.region
  instance_name               = local.sql_instance_name
  database_version            = var.cloud_sql_postgres_version
  tier                        = var.cloud_sql_tier
  disk_size                   = var.cloud_sql_disk_size_gb
  disk_type                   = var.cloud_sql_disk_type
  db_name                     = var.keycloak_db_name
  db_user                     = var.keycloak_db_user
  db_password                 = module.secrets.db_password_value
  network_self_link           = module.networking.network_self_linkjdbc:postgresql://cloudsql-proxy:5432/keycloak?sslmode=disable
  peering_address_name        = local.sql_peering_address_name
  peering_prefix_length       = var.sql_vpc_peering_prefix_length
  peering_purpose             = var.sql_vpc_peering_purpose
  peering_address_type        = var.sql_vpc_peering_address_type
  peering_service             = var.sql_vpc_peering_service
  backup_start_time           = var.cloud_sql_backup_start_time
  maintenance_day             = var.cloud_sql_maintenance_day
  maintenance_hour            = var.cloud_sql_maintenance_hour
  maintenance_track           = var.cloud_sql_maintenance_track
  deletion_protection         = var.cloud_sql_deletion_protection
  ipv4_enabled                = var.cloud_sql_ipv4_enabled
  private_path_enabled        = var.cloud_sql_private_path_enabled
  labels                      = local.common_labels

  depends_on = [module.networking]
}