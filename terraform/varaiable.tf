# 各環境で指定する変数を記載
variable "GCP_PROJECT_ID" {
}
variable "GCP_PROJECT_NO" {
}
variable "GOOGLE_APPLICATION_CREDENTIALS" {
  default = "/run/secrets/gcp_secret"
}
variable "REGION" {
  default = "us-central1"
}
variable "cloud_function_roles" {
  default = [
    "roles/cloudfunctions.invoker",
    "roles/datafusion.admin",
    "roles/storage.admin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/iam.serviceAccountUser",
    "roles/dataproc.worker"
  ]
}