provider "google" {
  project     = var.GCP_PROJECT_ID
  region      = var.REGION
  credentials = "${file(var.GOOGLE_APPLICATION_CREDENTIALS)}"
}

terraform {
  required_providers {
    cdap = {
      source = "GoogleCloudPlatform/cdap"
      # Pin to a specific version as 0.x releases are not guaranteed to be backwards compatible.
      version = "0.9.0"
    }
  }
}

data "google_client_config" "current" {}

provider "cdap" {
  host  = "${google_data_fusion_instance.instance.service_endpoint}/api/"
  token = data.google_client_config.current.access_token
}