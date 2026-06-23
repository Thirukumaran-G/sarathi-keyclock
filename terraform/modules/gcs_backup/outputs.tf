output "bucket_name" {
  description = "GCS backup bucket name"
  value       = google_storage_bucket.vm_backups.name
}

output "bucket_url" {
  description = "GCS backup bucket URL"
  value       = google_storage_bucket.vm_backups.url
}

output "bucket_self_link" {
  description = "GCS backup bucket self link"
  value       = google_storage_bucket.vm_backups.self_link
}