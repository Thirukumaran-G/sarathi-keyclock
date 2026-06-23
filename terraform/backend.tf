terraform {
  backend "gcs" {
    bucket = "gs://sarthi-tfstate-gwx-devops-internship-dev"
    prefix = "keycloak/dev"
  }
}