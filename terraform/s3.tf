
# Landing Buckets
resource "aws_s3_bucket" "customer_landing" {
  bucket = "${var.project_name}-customer-landing"
  acl    = "private"
}

resource "aws_s3_bucket" "step_trainer_landing" {
  bucket = "${var.project_name}-step-trainer-landing"
  acl    = "private"
}

resource "aws_s3_bucket" "accelerometer_landing" {
  bucket = "${var.project_name}-accelerometer-landing"
  acl    = "private"
}

# Trusted Buckets
resource "aws_s3_bucket" "customer_trusted" {
  bucket = "${var.project_name}-customer-trusted"
  acl    = "private"
}

resource "aws_s3_bucket" "step_trainer_trusted" {
  bucket = "${var.project_name}-step-trainer-trusted"
  acl    = "private"
}

resource "aws_s3_bucket" "accelerometer_trusted" {
  bucket = "${var.project_name}-accelerometer-trusted"
  acl    = "private"
}


# Curated Buckets
resource "aws_s3_bucket" "customer_curated" {
  bucket = "${var.project_name}-customer-curated"
  acl    = "private"
}

resource "aws_s3_bucket" "machine_learning_curated" {
  bucket = "${var.project_name}-machine-learning-curated"
  acl    = "private"
}

resource "aws_s3_bucket" "athena_results" {
  bucket = "${var.project_name}-athena-results"
  acl    = "private"
}

resource "aws_s3_bucket" "glue_scripts" {
  bucket = "${var.project_name}-glue-scripts"
  acl    = "private"
}
