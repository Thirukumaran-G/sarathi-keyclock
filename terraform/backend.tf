terraform {
  backend "gcs" {
    bucket = "sarthi-tfstate-YOUR_PROJECT_ID-dev"
    prefix = "keycloak/dev"
  }
}