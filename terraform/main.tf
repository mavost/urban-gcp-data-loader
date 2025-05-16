provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "data_bucket" {
  name     = var.bucket_name
  location = var.region
}

resource "google_storage_bucket_object" "function_source" {
  # ToDo: needs to include SHA dependency of zip payload
  name   = "function-source.zip"
  bucket = google_storage_bucket.data_bucket.name
  source = "../cloud_function/function-source.zip"
}

module "cloud_function" {
  source = "./modules/cloud_function"

  region        = var.region
  bucket_name   = var.bucket_name
  base_url      = var.base_url
  bucket_object = google_storage_bucket_object.function_source.name
  source_bucket = google_storage_bucket.data_bucket.name
}

# ToDo: needs permissions to call http cloud run function
resource "google_cloud_scheduler_job" "daily_trigger" {
  name             = "trigger-data-ingestion"
  schedule         = "0 2 * * *"  # 2 AM UTC daily
  time_zone        = "UTC"

  http_target {
    http_method = "GET"
    uri         = module.cloud_function.function_url
  }
}
