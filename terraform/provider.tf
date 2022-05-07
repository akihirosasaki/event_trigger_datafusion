provider "google" {
  project     = var.GCP_PROJECT_ID
  region      = var.REGION
  credentials = "${file(var.GOOGLE_APPLICATION_CREDENTIALS)}"
}