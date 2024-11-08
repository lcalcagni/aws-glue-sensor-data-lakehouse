# Paths and configuration
TFVARS_PATH := $(shell pwd)/terraform/terraform.tfvars
TERRAFORM_DIR := terraform

# Load AWS credentials and project settings
export AWS_ACCESS_KEY_ID := $(shell grep aws_access_key $(TFVARS_PATH) | cut -d '"' -f2)
export AWS_SECRET_ACCESS_KEY := $(shell grep aws_secret_key $(TFVARS_PATH) | cut -d '"' -f2)
export AWS_REGION := $(shell grep aws_region $(TFVARS_PATH) | cut -d '"' -f2)
export PROJECT_NAME := $(shell grep project_name $(TFVARS_PATH) | cut -d '"' -f2)

# Function to wait for a Glue job to complete
define wait_for_job
	@echo "Waiting for job $1 to complete..."
	@job_run_id=$$(aws glue start-job-run --job-name $1 --query 'JobRunId' --output text); \
	while [ "$$(aws glue get-job-run --job-name $1 --run-id $$job_run_id --query 'JobRun.JobRunState' --output text)" = "RUNNING" ]; do \
		sleep 5; \
	done
	@echo "Job $1 completed."
endef

# Function to wait for a crawler to complete
define wait_for_crawler
	@echo "Waiting for crawler $1 to complete..."
	@while [ "$$(aws glue get-crawler --name $1 --query 'Crawler.State' --output text)" = "RUNNING" ]; do \
		sleep 5; \
	done
	@echo "Crawler $1 completed."
endef

# Terraform initialization and apply
init:
	@echo "Initializing Terraform..."
	cd $(TERRAFORM_DIR) && terraform init

apply: init
	@echo "Applying infrastructure with Terraform..."
	cd $(TERRAFORM_DIR) && terraform apply -var-file="$(TFVARS_PATH)" -auto-approve

# Upload initial data to S3 using a Python script
upload:
	@echo "Uploading initial data to S3 buckets..."
	python3 upload_to_S3.py

# Run Glue Jobs to process and move data between S3 buckets
run_glue_jobs:
	@echo "Running trusted jobs..."
	$(call wait_for_job,${PROJECT_NAME}-customer-trusted-job)
	$(call wait_for_job,${PROJECT_NAME}-accelerometer-trusted-job)
	$(call wait_for_job,${PROJECT_NAME}-step-trainer-trusted-job)

	@echo "Running curated jobs..."
	$(call wait_for_job,${PROJECT_NAME}-customer-curated-job)
	$(call wait_for_job,${PROJECT_NAME}-machine-learning-curated-job)

# Run Glue Crawlers to create Glue tables after data processing is complete
run_crawlers:
	@echo "Running all crawlers for Athena tables..."
	aws glue start-crawler --name ${PROJECT_NAME}-customer-landing-crawler
	aws glue start-crawler --name ${PROJECT_NAME}-step-trainer-landing-crawler
	aws glue start-crawler --name ${PROJECT_NAME}-accelerometer-landing-crawler

	$(call wait_for_crawler,${PROJECT_NAME}-customer-landing-crawler)
	$(call wait_for_crawler,${PROJECT_NAME}-step-trainer-landing-crawler)
	$(call wait_for_crawler,${PROJECT_NAME}-accelerometer-landing-crawler)

	aws glue start-crawler --name ${PROJECT_NAME}-customer-trusted-crawler
	aws glue start-crawler --name ${PROJECT_NAME}-step-trainer-trusted-crawler
	aws glue start-crawler --name ${PROJECT_NAME}-accelerometer-trusted-crawler

	$(call wait_for_crawler,${PROJECT_NAME}-customer-trusted-crawler)
	$(call wait_for_crawler,${PROJECT_NAME}-step-trainer-trusted-crawler)
	$(call wait_for_crawler,${PROJECT_NAME}-accelerometer-trusted-crawler)

	aws glue start-crawler --name ${PROJECT_NAME}-customer-curated-crawler
	aws glue start-crawler --name ${PROJECT_NAME}-machine-learning-curated-crawler

	$(call wait_for_crawler,${PROJECT_NAME}-customer-curated-crawler)
	$(call wait_for_crawler,${PROJECT_NAME}-machine-learning-curated-crawler)

# Complete workflow in the correct order
all: apply upload run_glue_jobs run_crawlers

# Empty S3 buckets
empty_buckets:
	@echo "Emptying S3 buckets..."
	cd $(TERRAFORM_DIR) && terraform apply -target=null_resource.empty_buckets -auto-approve

# Destroy Terraform infrastructure
destroy: empty_buckets
	@echo "Destroying infrastructure with Terraform..."
	cd $(TERRAFORM_DIR) && terraform destroy -var-file="$(TFVARS_PATH)" -auto-approve
