module "gcs_backup" {
  source = "./modules/gcs_backup"

  project_id                      = var.project_id
  bucket_name                     = local.backup_bucket_name
  location                        = var.region
  retention_days                  = var.backup_retention_days
  num_newer_versions              = var.backup_num_newer_versions
  public_access_prevention        = var.bucket_public_access_prevention
  force_destroy                   = var.bucket_force_destroy
  versioning_enabled              = var.gcs_bucket_versioning_enabled
  lifecycle_action_type           = var.gcs_lifecycle_action_type
  writer_role                     = var.gcs_writer_role
  sa_keycloak_email               = module.service_account.email
  labels                          = local.common_labels
}