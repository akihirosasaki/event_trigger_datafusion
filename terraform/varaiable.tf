# 各環境で指定する変数を記載
variable "GCP_PROJECT_ID" {
  default = "test-asasaki"
}
variable "GOOGLE_APPLICATION_CREDENTIALS" {
  default = "/run/secrets/gcp_secret"
}
variable "REGION" {
  default = "us-central1"
}