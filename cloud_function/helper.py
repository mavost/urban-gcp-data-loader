import requests

def fetch_paginated_data(base_url):
    all_data = []
    page = 1
    while True:
        response = requests.get(f"{base_url}?page={page}")
        if response.status_code != 200:
            raise Exception(f"Failed to fetch data: {response.text}")
        data = response.json()
        if not data:
            break
        all_data.extend(data)
        page += 1
    return all_data
