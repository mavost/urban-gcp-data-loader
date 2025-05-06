import requests
import logging
from datetime import datetime, timezone

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# def fetch_paginated_data(base_url):
#   all_data = []
#   page = 1
#   while True:
#     response = requests.get(f"{base_url}?page={page}")
#     if response.status_code != 200:
#       raise Exception(f"Failed to fetch data: {response.text}")
#     data = response.json()
#     if not data:
#       break
#     all_data.extend(data)
#     page += 1
#   return all_data

def fetch_offset_data(base_url):
  all_data = []
  limit = 100
  offset = 0
  max = 500

  current_ts = datetime.now(timezone.utc).strftime('%Y%m%d000000')
  logger.info(f"Fetching data for {current_ts}")
  while offset < max:
    response = requests.get(f"{base_url}?$limit={limit}&$offset={offset}")
    if response.status_code != 200:
      raise Exception(f"Failed to fetch data: {response.text}")
    logger.info(f"Fetching offset: {offset}")
    data = response.json()
    if not data:
      break
    all_data.extend(data)
    offset += limit
  return all_data
