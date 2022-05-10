# サービスアカウント作成とロールの付与
resource "google_service_account" "develop" {
  project = var.GCP_PROJECT_ID
  account_id = "develop"
  display_name = "develop"
}

resource "google_project_iam_member" "develop_cloudfunction_invoker" {
  project = var.GCP_PROJECT_ID
  role = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.develop.email}"
}

resource "google_project_iam_member" "develop_datafusion_admin" {
  project = var.GCP_PROJECT_ID
  role = "roles/datafusion.admin"
  member = "serviceAccount:${google_service_account.develop.email}"
}

resource "google_project_iam_member" "develop_storage_admin" {
  project = var.GCP_PROJECT_ID
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.develop.email}"
}

resource "google_project_iam_member" "develop_bigquery_editer" {
  project = var.GCP_PROJECT_ID
  role = "roles/bigquery.dataEditor"
  member = "serviceAccount:${google_service_account.develop.email}"
}

resource "google_project_iam_member" "develop_bigquery_jobUser" {
  project = var.GCP_PROJECT_ID
  role = "roles/bigquery.jobUser"
  member = "serviceAccount:${google_service_account.develop.email}"
}

resource "google_project_iam_member" "develop_serviceAccountUser" {
  project = var.GCP_PROJECT_ID
  role = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.develop.email}"
}

resource "google_project_iam_member" "develop_dataproc_worker" {
  project = var.GCP_PROJECT_ID
  role = "roles/dataproc.worker"
  member = "serviceAccount:${google_service_account.develop.email}"
}

resource "google_project_iam_member" "sa-datafusion_serviceAccountUser" {
  project = var.GCP_PROJECT_ID
  role = "roles/iam.serviceAccountUser"
  member = "serviceAccount:service-840090550767@gcp-sa-datafusion.iam.gserviceaccount.com"
}


# data fusionの設定
resource "google_data_fusion_instance" "instance" {
  name = "sasakky-datafusion-instance"
  project = var.GCP_PROJECT_ID
  region = var.REGION
  type = "BASIC"
  dataproc_service_account = google_service_account.develop.email
}

resource "cdap_namespace" "namespace" {
  name = "sandbox"
}

resource "cdap_application" "pipeline" {
  name = "weekly_survey_etl"
  namespace = cdap_namespace.namespace.name
  spec = file("../src/data_fusion/weekly_survey_etl-cdap-data-pipeline.json")

  depends_on = [
    cdap_namespace.namespace
  ]
}

# cloud functionsの設定
resource "google_storage_bucket" "function_bucket" {
    name     = "${var.GCP_PROJECT_ID}-function"
    location = var.REGION
}

resource "google_storage_bucket" "input_bucket" {
    name     = "${var.GCP_PROJECT_ID}-input"
    location = var.REGION
}

# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "source" {
    type        = "zip"
    source_dir  = "../src/cloud_function"
    output_path = "/tmp/function.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "zip" {
    source       = data.archive_file.source.output_path
    content_type = "application/zip"

    # Append to the MD5 checksum of the files's content
    # to force the zip to be updated as soon as a change occurs
    name         = "src-${data.archive_file.source.output_md5}.zip"
    bucket       = google_storage_bucket.function_bucket.name

    # Dependencies are automatically inferred so these lines can be deleted
    depends_on   = [
        google_storage_bucket.function_bucket,  # declared in `storage.tf`
        data.archive_file.source
    ]
}

# Create the Cloud function triggered by a `Finalize` event on the bucket
resource "google_cloudfunctions_function" "function" {
    name                  = "weekly_survey_etl_function"
    runtime               = "python37"  # of course changeable

    # Get the source code of the cloud function as a Zip compression
    source_archive_bucket = google_storage_bucket.function_bucket.name
    source_archive_object = google_storage_bucket_object.zip.name

    # Must match the function name in the cloud function `main.py` source code
    entry_point           = "run_job"
    service_account_email = google_service_account.develop.email

    environment_variables = {
      INSTANCE_ID = google_data_fusion_instance.instance.name,
      REGION = var.REGION,
      PIPELINE_NAME = cdap_application.pipeline.name,
      PROJECT_ID = var.GCP_PROJECT_ID,
      NAMESPACE_ID = cdap_namespace.namespace.name,
      CDAP_ENDPOINT = "https://${google_data_fusion_instance.instance.name}-${var.GCP_PROJECT_ID}-dot-usc1.datafusion.googleusercontent.com/api"
    }
    
    # 
    event_trigger {
        event_type = "google.storage.object.finalize"
        resource   = "${var.GCP_PROJECT_ID}-input"
    }

    # Dependencies are automatically inferred so these lines can be deleted
    depends_on            = [
        google_storage_bucket.function_bucket,  # declared in `storage.tf`
        google_storage_bucket_object.zip,
        google_data_fusion_instance.instance,
        cdap_namespace.namespace,
        cdap_application.pipeline,
        google_service_account.develop
    ]
}
