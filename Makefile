MAKEFLAGS += --warn-undefined-variables
.SHELLFLAGS := -eu -o pipefail -c
SHELL := bash

all: help
.PHONY: all help zip tf-init tf-plan tf-apply tf-destroy

##@ Helpers
help: ## Display this help
	@echo "GCP Data Ingestion Pipeline"
	@echo "==========================="
	@awk 'BEGIN {FS = ":.*##"; printf "\033[36m\033[0m"} /^[a-zA-Z0-9_%/-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@printf "\n"


objects := $(wildcard cloud_function/*.py cloud_function/requirements.txt)
function-source.zip: $(objects)
	cd cloud_function && rm -rf __pycache__ && zip -r ../cloud_function/function-source.zip *

##@ Packaging
zip: function-source.zip ## Create a zip file for the Cloud Function

##@ Terraform

ENV ?= terraform

tf-init: ## Initialize Terraform
	cd terraform && terraform init

tf-plan: zip ## Verify Terraform config
	cd terraform && terraform plan -var-file=$(ENV).tfvars

tf-apply: zip ## Apply Terraform config
	cd terraform && terraform apply -var-file=$(ENV).tfvars

tf-destroy: ## Destroy Terraform resources
	cd terraform && terraform destroy -var-file=$(ENV).tfvars
