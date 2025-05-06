# GCP Data Ingestion Pipeline

This project deploys a serverless data ingestion pipeline in Google Cloud Platform to fetch paginated data from a REST API daily, store it in Cloud Storage, and optionally extend to BigQuery + Looker.

## 📦 Project Structure

```bash
.
├── cloud_function/         # Python code for Cloud Function
├── terraform/              # Terraform IaC
│   └── modules/
│       └── cloud_function/ # Modular TF for Cloud Function
```

## 🚀 Deployment Steps

### 1. Prerequisites

- Sign up with GCP by creating a new trial account
- Log into the [GCP console](https://cloud.google.com), manually create an empty project and take note of the *Project ID*.
- Install [Terraform](https://www.terraform.io/downloads)
- Install [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- Enable required APIs in the gcloud CLI:

  ```bash
  gcloud services enable cloudfunctions.googleapis.com \
    artifactregistry.googleapis.com \
    cloudscheduler.googleapis.com \
    storage.googleapis.com
  ```

- Navigate to [API Control for you project](https://console.developers.google.com/apis/api/cloudbuild.googleapis.com) and enable the *Cloudbuild* service.

- Authenticate:

  ```bash
  gcloud auth application-default login
  gcloud auth login
  gcloud config set project [PROJECT_ID]
  ```

### 2. Package the Cloud Function

```bash
make zip
```

### 3. Deploy Infrastructure

```bash
make tf-init
make tf-apply PROJECT_ID=your-project-id BUCKET_NAME=your-data-bucket
```

### 4. Test the Function on GCP

Once deployed, get the function URL from Terraform outputs and trigger the endpoint:

```bash
terraform output function_url
curl -m 70 -X POST [FUNCTION_URL]] \
-H "Authorization: bearer $(gcloud auth print-identity-token)" \
-H "Content-Type: application/json" \
-d '{
    "message": "Testing"
}'
```

### 5. Test the Function locally

- Create a local python environment using the `requirements.txt` file:

  ```bash
  python3 -m venv .venv-test
  source .venv-test/bin/activate
  pip install -r cloud_function/requirements.txt
  ```

- Run the framework

  ```bash
  cd cloud_function
  functions-framework --target=ingest_api_data --port=8088
  ```

- Trigger the function

  ```bash
  curl http://localhost:8088/
  ```

### ✅ Success

Each day at 2AM UTC, your Cloud Function will fetch paginated API data and store it in your GCS bucket under `data/YYYY-MM-DD.json`.

---

## 🔜 Next Steps

- Load JSON files to BigQuery via scheduled jobs or trigger
- Add partitioning and schema in BigQuery
- Connect to Looker for analytics
