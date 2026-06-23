module "disk" {
  source = "./modules/disk"

  project_id = var.project_id
  zone       = var.zone
  disk_name  = local.data_disk_name
  disk_size  = var.vm_data_disk_size_gb
  disk_type  = var.vm_data_disk_type
  labels     = local.common_labels
}