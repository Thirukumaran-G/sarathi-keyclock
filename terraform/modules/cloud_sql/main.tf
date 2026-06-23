resource "google_compute_global_address" "private_ip_range" {
  project       = var.project_id
  name          = var.peering_address_name
  purpose       = var.peering_purpose
  address_type  = var.peering_address_type
  prefix_length = var.peering_prefix_length
  network       = var.network_self_link
}



resource "google_service_networking_connection" "private_vpc" {
  network                 = var.network_self_link
  service                 = var.peering_service
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

resource "google_sql_database_instance" "main" {
  project          = var.project_id
  name             = var.instance_name
  region           = var.region
  database_version = var.database_version

  settings {
    tier        = var.tier
    disk_size   = var.disk_size
    disk_type   = var.disk_type
    user_labels = var.labels

    backup_configuration {
      enabled    = true
      start_time = var.backup_start_time
    }

    ip_configuration {
      ipv4_enabled                                  = var.ipv4_enabled
      private_network                               = var.network_self_link
      enable_private_path_for_google_cloud_services = var.private_path_enabled
    }

    maintenance_window {
      day          = var.maintenance_day
      hour         = var.maintenance_hour
      update_track = var.maintenance_track
    }
  }

  deletion_protection = var.deletion_protection

  depends_on = [google_service_networking_connection.private_vpc]
}

resource "google_sql_database" "keycloak" {
  project  = var.project_id
  instance = google_sql_database_instance.main.name
  name     = var.db_name
}

resource "google_sql_user" "keycloak" {
  project  = var.project_id
  instance = google_sql_database_instance.main.name
  name     = var.db_user
  password = var.db_password
}