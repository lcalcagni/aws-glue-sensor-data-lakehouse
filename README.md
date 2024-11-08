"""
# AWS - Glue Sensor Data Lakehouse Project

This project builds a data lakehouse solution to process and analyze sensor data collected from IoT devices and a mobile app. The data lakehouse architecture on AWS facilitates the use of curated datasets to train machine learning models for activity detection and user behavior analysis.

## Project Overview

The solution leverages AWS Glue, AWS S3, and AWS Athena to manage and process data through various stages:
- **Landing Zone**: Raw data ingested from different sources.
- **Trusted Zone**: Filtered data with records from users who consented to data sharing.
- **Curated Zone**: Final datasets, prepared for machine learning analysis.

## Architecture and Technology Stack

The main components of the project include:
- **AWS Glue**: For ETL (Extract, Transform, Load) jobs that move data between zones and prepare it for analysis.
- **AWS S3**: To store data at each processing stage.
- **AWS Athena**: To query and analyze data from the curated datasets.
- **Terraform**: To provision all AWS resources (S3 buckets, Glue jobs, IAM roles).
- **Makefile**: To automate commands and simplify execution.

## Project Structure

```plaintext
├── Makefile                   # Automation script
├── README.md                  # Project documentation
├── athena_queries             # SQL queries for Athena analysis
├── data                       # Data source folders for initial data ingestion
├── glue_jobs                  # Python scripts for Glue jobs
├── requirements.txt           # Dependencies for Glue jobs
├── screenshots                # Screenshots of results
├── terraform                  # Terraform configurations for AWS resources
│   ├── main.tf                # Main Terraform file
│   ├── s3.tf                  # S3 bucket definitions
│   ├── glue.tf                # Glue jobs and database definitions
│   ├── variables.tf           # Variables for customization
│   └── outputs.tf             # Output definitions for Terraform
└── upload_to_S3.py            # Python script to upload local data to S3
```
## Setup Instructions

### Prerequisites

- **AWS Account**: You need an AWS account to provision resources.
- **AWS CLI**: Set up AWS CLI and configure it with appropriate permissions.
- **Terraform**: Ensure Terraform is installed (version 0.14+ recommended).
- **Python**: Python 3.x to run the `upload_to_S3.py` script.

### Configuration

1. **Terraform Variables**: Define your AWS credentials and region in `terraform/terraform.tfvars`:
```    
    aws_access_key = "YOUR_ACCESS_KEY"
    aws_secret_key = "YOUR_SECRET_KEY"
    aws_region     = "YOUR_AWS_REGION"
    project_name   = "sensor-data-lakehouse"
    glue_database  = "sensor_data_lakehouse_db"
```
   
2. **Environment Variables**: The Makefile automatically loads AWS credentials and project settings from `terraform.tfvars`.

### Usage

#### 1. Initialize and Apply Terraform

To set up all required AWS resources, run the following:

    make all

This command:
- Initializes Terraform and applies configurations to create S3 buckets, Glue database, crawlers, and jobs.
- Uploads data and scripts to S3.
- Runs Glue crawlers to set up tables in Glue Catalog.
- Executes Glue jobs to process data through each zone.

#### 2. Run Individual Steps (Optional)

You can run individual steps using the following commands:
- **Initialize Terraform**: `make init`
- **Apply Infrastructure**: `make apply`
- **Upload Data**: `make upload`
- **Run Crawlers**: `make run_crawlers`
- **Run Glue Jobs**: `make run_glue_jobs`

#### 3. Clean Up

To destroy all resources created by this project:

    make destroy

### Data Flow

The data flow through the lakehouse solution is as follows:

1. **Landing Zone**:
    - Data is initially loaded into S3 buckets (`customer_landing`, `step_trainer_landing`, `accelerometer_landing`).

2. **Trusted Zone**:
    - Glue jobs filter out records for users who have consented to data sharing and store these in the `trusted` buckets.

3. **Curated Zone**:
    - Final datasets are created by joining trusted records from multiple sources and stored in the `curated` buckets, ready for machine learning.

### Glue Jobs

Each Glue job processes data for different zones:

- **Customer Trusted Job**: Filters customer records based on consent.
- **Accelerometer Trusted Job**: Filters accelerometer data for users who provided consent.
- **Step Trainer Trusted Job**: Filters step trainer data for customers in `customer_trusted`.
- **Curated Jobs**: Joins data from different sources for machine learning purposes.

### Querying Data in Athena

Once the data is in the Curated Zone, you can use the SQL scripts in `athena_queries` to perform analysis. Example queries:

    SELECT * FROM "sensor_data_lakehouse_db"."customer_trusted";
    SELECT * FROM "sensor_data_lakehouse_db"."machine_learning_curated";