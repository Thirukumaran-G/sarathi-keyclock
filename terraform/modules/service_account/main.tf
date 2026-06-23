resource "google_service_account" "keycloak" {
  project      = var.project_id
  account_id   = var.sa_name
  display_name = var.display_name
}

resource "google_project_iam_member" "roles" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.keycloak.email}"
}