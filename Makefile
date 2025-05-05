MAKEFLAGS += --warn-undefined-variables
.SHELLFLAGS := -eu -o pipefail -c
SHELL := bash

all: help
.PHONY: all help zip tf-init tf-plan tf-apply tf-destroy

##@ Helpers
help: ## display this help
	@echo "GCP Data Ingestion Pipeline"
	@echo "==========================="
	@awk 'BEGIN {FS = ":.*##"; printf "\033[36m\033[0m"} /^[a-zA-Z0-9_%/-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@printf "\n"


objects := $(wildcard cloud_function/*.py cloud_function/requirements.txt)
function-source.zip: $(objects)
	cd cloud_function && zip -r ../cloud_function/function-source.zip *

##@ Packaging
zip: function-source.zip ## Create a zip file for the Cloud Function

##@ Terraform

PROJECT_ID ?= your-project-id
BUCKET_NAME ?= your-data-bucket

ENV_VARS := -var="project_id=$(PROJECT_ID)" -var="bucket_name=$(BUCKET_NAME)"

tf-init: ## Initialize Terraform
	cd terraform && terraform init

tf-plan: zip ## Initialize Terraform
	cd terraform && terraform plan $(ENV_VARS)

tf-apply: zip ## Apply Terraform config
	cd terraform && terraform apply $(ENV_VARS)

tf-destroy: ## Destroy Terraform resources
	cd terraform && terraform destroy $(ENV_VARS)
