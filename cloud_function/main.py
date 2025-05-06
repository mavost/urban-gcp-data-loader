import json
import os

from datetime import datetime, timezone
from google.cloud import storage
import functions_framework
# transitive dependency
from flask import Request
from helper import fetch_offset_data
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.http
def ingest_api_data(request: Request):

  BASE_URL = os.getenv("BASE_URL")
  #BASE_URL = "https://data.ny.gov/resource/xyvi-fbb9.json"
  if not BASE_URL:
    raise ValueError("Environment variable BASE_URL is not set")

  BUCKET_NAME = os.getenv("BUCKET_NAME")
  if not BUCKET_NAME:
    raise ValueError("Environment variable BUCKET_NAME is not set")

  try:
    logger.info("Fetching data...")
    data = fetch_offset_data(BASE_URL)
    upload_to_gcs(BUCKET_NAME, data)
    return ("Data uploaded successfully", 200)
  except Exception as e:
    return (f"Error occurred: {str(e)}", 500)

def upload_to_gcs(bucket_name, data):
  storage_client = storage.Client()
  bucket = storage_client.bucket(bucket_name)
  date_str = datetime.now(timezone.utc).strftime('%Y-%m-%d')
  blob = bucket.blob(f"data/{date_str}.json")
  lines = [json.dumps(item) for item in data]
  file_content = '\n'.join(lines)
  blob.upload_from_string(file_content, content_type="application/json")
