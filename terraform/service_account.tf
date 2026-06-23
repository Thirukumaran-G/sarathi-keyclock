module "service_account" {
  source = "./modules/service_account"

  project_id   = var.project_id
  sa_name      = local.sa_keycloak_name
  display_name = local.sa_keycloak_display
  roles        = var.sa_roles
  labels       = local.common_labels
}