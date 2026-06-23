resource "random_password" "admin" {
  length           = var.admin_password_length
  special          = var.admin_password_special
  override_special = var.admin_password_override_special
}

resource "random_password" "db" {
  length           = var.db_password_length
  special          = var.db_password_special
  override_special = var.db_password_override_special
}

resource "google_secret_manager_secret" "admin_password" {
  project   = var.project_id
  secret_id = var.admin_secret_name
  labels    = var.labels

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "admin_password" {
  secret      = google_secret_manager_secret.admin_password.id
  secret_data = random_password.admin.result
}

resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = var.db_secret_name
  labels    = var.labels

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db.result
}

resource "google_secret_manager_secret_iam_member" "admin_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.admin_password.secret_id
  role      = var.secret_accessor_role
  member    = "serviceAccount:${var.sa_keycloak_email}"
}

resource "google_secret_manager_secret_iam_member" "db_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = var.secret_accessor_role
  member    = "serviceAccount:${var.sa_keycloak_email}"
}