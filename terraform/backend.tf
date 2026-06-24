terraform {
  backend "gcs" {
    bucket = "sarthi-tfstate-gwx-devops-internship-dev"
    prefix = "keycloak/dev"
  }
}