import json
from datetime import datetime
from google.cloud import storage
from helper import fetch_paginated_data

def upload_to_gcs(bucket_name, data):
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    date_str = datetime.utcnow().strftime('%Y-%m-%d')
    blob = bucket.blob(f"data/{date_str}.json")
    blob.upload_from_string(json.dumps(data), content_type="application/json")

def main(event, context):
    BASE_URL = "https://api.example.com/data"  # replace with actual
    BUCKET_NAME = "your-data-bucket-name"  # replace with actual

    data = fetch_paginated_data(BASE_URL)
    upload_to_gcs(BUCKET_NAME, data)
