module "secrets" {
  source = "./modules/secrets"

  project_id                      = var.project_id
  admin_secret_name               = local.secret_admin_password_name
  db_secret_name                  = local.secret_db_password_name
  admin_password_length           = var.admin_password_length
  admin_password_special          = var.admin_password_special
  admin_password_override_special = var.admin_password_override_special
  db_password_length              = var.db_password_length
  db_password_special             = var.db_password_special
  db_password_override_special    = var.db_password_override_special
  replication_policy              = var.secret_replication_policy
  secret_accessor_role            = var.secret_accessor_role
  sa_keycloak_email               = module.service_account.email
  labels                          = local.common_labels
}