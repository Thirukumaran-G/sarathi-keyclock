resource "google_storage_bucket" "vm_backups" {
  project                     = var.project_id
  name                        = var.bucket_name
  location                    = var.location
  uniform_bucket_level_access = true
  public_access_prevention    = var.public_access_prevention
  force_destroy               = var.force_destroy
  labels                      = var.labels

  versioning {
    enabled = var.versioning_enabled
  }

  lifecycle_rule {
    condition {
      age = var.retention_days
    }
    action {
      type = var.lifecycle_action_type
    }
  }

  lifecycle_rule {
    condition {
      num_newer_versions = var.num_newer_versions
    }
    action {
      type = var.lifecycle_action_type
    }
  }
}

resource "google_storage_bucket_iam_member" "keycloak_writer" {
  bucket = google_storage_bucket.vm_backups.name
  role   = var.writer_role
  member = "serviceAccount:${var.sa_keycloak_email}"
}