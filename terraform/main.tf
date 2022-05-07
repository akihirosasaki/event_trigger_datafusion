# data fusionの設定
module "data_fusion" "data_fusion_instance"{
  source = "terraform-google-modules/data-fusion/google"
  version = "~> 0.1"

  name = "sasakky_datafusion_instance"
}

module "sandbox" {
  source = "terraform-google-modules/data-fusion/google//modules/namespace"
  version = "~> 0.1"

  name = "sandbox"
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
    source_dir  = "../src/weekly_survey_etl_function"
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

    environment_variables = {
      INSTANCE_ID = data_fusion.data_fusion_instance.name,
      REGION = var.REGION,
      PIPELINE_NAME = "",
      PROJECT_ID = var.GCP_PROJECT_ID,
      NAMESPACE_ID = sandbox.name,
      CDAP_ENDPOINT = ""
    }
    
    # 
    event_trigger {
        event_type = "google.storage.object.finalize"
        resource   = "${var.GCP_PROJECT_ID}-input"
    }

    # Dependencies are automatically inferred so these lines can be deleted
    depends_on            = [
        google_storage_bucket.function_bucket,  # declared in `storage.tf`
        google_storage_bucket_object.zip
    ]
}