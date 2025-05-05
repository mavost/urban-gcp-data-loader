# GCP Data Ingestion Pipeline

This project deploys a serverless data ingestion pipeline in Google Cloud Platform to fetch paginated data from a REST API daily, store it in Cloud Storage, and optionally extend to BigQuery + Looker.

## 📦 Project Structure
```
.
├── cloud_function/         # Python code for Cloud Function
├── terraform/              # Terraform IaC
│   └── modules/
│       └── cloud_function/ # Modular TF for Cloud Function
```

## 🚀 Deployment Steps

### 1. Prerequisites
- Install [Terraform](https://www.terraform.io/downloads)
- Install [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- Enable required APIs:
  ```bash
  gcloud services enable cloudfunctions.googleapis.com \
    cloudscheduler.googleapis.com \
    storage.googleapis.com
  ```
- Authenticate:
  ```bash
  gcloud auth application-default login
  gcloud auth login
  gcloud config set project [PROJECT_ID]
  ```

### 2. Package the Cloud Function
```bash
cd cloud_function
zip -r ../cloud_function/function-source.zip *
```

### 3. Terraform Deploy
```bash
cd terraform
terraform init
terraform apply -var="project_id=your-project-id" -var="bucket_name=your-data-bucket"
```

### 4. Test the Function
Once deployed, get the function URL from Terraform outputs:
```bash
curl [FUNCTION_URL]
```

### ✅ Success
Each day at 2AM UTC, your Cloud Function will fetch paginated API data and store it in your GCS bucket under `data/YYYY-MM-DD.json`.

---

## 🔜 Next Steps
- Load JSON files to BigQuery via scheduled jobs or trigger
- Add partitioning and schema in BigQuery
- Connect to Looker for analytics
