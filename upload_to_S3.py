import boto3
import os

# Configuration for S3 buckets and local data paths
BUCKETS = {
    "customer": {
        "bucket_name": "sensor-data-lakehouse-customer-landing",
        "local_path": "data/customer/landing"
    },
    "step_trainer": {
        "bucket_name": "sensor-data-lakehouse-step-trainer-landing",
        "local_path": "data/step_trainer/landing"
    },
    "accelerometer": {
        "bucket_name": "sensor-data-lakehouse-accelerometer-landing",
        "local_path": "data/accelerometer/landing"
    },
    "glue_jobs": {
        "bucket_name": "sensor-data-lakehouse-glue-scripts",
        "local_path": "glue_jobs"
    }
}

# Initialize the S3 client with environment variables
s3_client = boto3.client(
    's3',
    aws_access_key_id=os.getenv('AWS_ACCESS_KEY'),
    aws_secret_access_key=os.getenv('AWS_SECRET_KEY'),
    region_name=os.getenv('AWS_REGION')
)

def upload_files(bucket_name, local_path):
    """
    Uploads all files from a local folder to an S3 bucket.
    """
    for root, _, files in os.walk(local_path):
        for file_name in files:
            file_path = os.path.join(root, file_name)
            s3_key = os.path.relpath(file_path, local_path)  # Maintain folder structure in S3
            try:
                print(f"Uploading {file_path} to s3://{bucket_name}/{s3_key}")
                s3_client.upload_file(file_path, bucket_name, s3_key)
                print(f"Uploaded {file_name} successfully.")
            except Exception as e:
                print(f"Failed to upload {file_name}: {e}")

def main():
    for dataset, config in BUCKETS.items():
        print(f"Uploading data for {dataset}...")
        upload_files(config["bucket_name"], config["local_path"])
    print("Data upload complete.")

if __name__ == "__main__":
    main()
