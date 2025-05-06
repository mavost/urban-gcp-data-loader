resource "google_cloudfunctions_function" "ingest_function" {
  name        = "data-ingestion-function"
  description = "Fetch data from API and store in GCS"
  runtime     = "python310"
  entry_point = "ingest_api_data"
  region      = var.region

  source_archive_bucket = var.source_bucket
  source_archive_object = var.bucket_object

  trigger_http = true
  available_memory_mb = 256

  environment_variables = {
    BUCKET_NAME = var.bucket_name
    BASE_URL    = var.base_url
  }
}

output "function_url" {
  value = google_cloudfunctions_function.ingest_function.https_trigger_url
}
