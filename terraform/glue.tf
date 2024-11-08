# Glue Database
resource "aws_glue_catalog_database" "glue_database" {
  name        = var.glue_database
  description = "Database for storing sensor data tables in Glue, used for Athena queries"
}

# Landing Crawlers
resource "aws_glue_crawler" "customer_landing_crawler" {
  name          = "${var.project_name}-customer-landing-crawler"
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_role.arn
  s3_target {
    path = "s3://${aws_s3_bucket.customer_landing.bucket}"
  }
  depends_on = [aws_s3_bucket.customer_landing]
}

resource "aws_glue_crawler" "step_trainer_landing_crawler" {
  name          = "${var.project_name}-step-trainer-landing-crawler"
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_role.arn
  s3_target {
    path = "s3://${aws_s3_bucket.step_trainer_landing.bucket}"
  }
  depends_on = [aws_s3_bucket.step_trainer_landing]
}

resource "aws_glue_crawler" "accelerometer_landing_crawler" {
  name          = "${var.project_name}-accelerometer-landing-crawler"
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_role.arn
  s3_target {
    path = "s3://${aws_s3_bucket.accelerometer_landing.bucket}"
  }
  depends_on = [aws_s3_bucket.accelerometer_landing]
}

# Trusted Crawlers
resource "aws_glue_crawler" "customer_trusted_crawler" {
  name          = "${var.project_name}-customer-trusted-crawler"
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_role.arn
  s3_target {
    path = "s3://${aws_s3_bucket.customer_trusted.bucket}"
  }
  depends_on = [aws_s3_bucket.customer_trusted]
}

resource "aws_glue_crawler" "step_trainer_trusted_crawler" {
  name          = "${var.project_name}-step-trainer-trusted-crawler"
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_role.arn
  s3_target {
    path = "s3://${aws_s3_bucket.step_trainer_trusted.bucket}"
  }
  depends_on = [aws_s3_bucket.step_trainer_trusted]
}

resource "aws_glue_crawler" "accelerometer_trusted_crawler" {
  name          = "${var.project_name}-accelerometer-trusted-crawler"
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_role.arn
  s3_target {
    path = "s3://${aws_s3_bucket.accelerometer_trusted.bucket}"
  }
  depends_on = [aws_s3_bucket.accelerometer_trusted]
}

# Curated Crawlers
resource "aws_glue_crawler" "customer_curated_crawler" {
  name          = "${var.project_name}-customer-curated-crawler"
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_role.arn
  s3_target {
    path = "s3://${aws_s3_bucket.customer_curated.bucket}"
  }
  depends_on = [aws_s3_bucket.customer_curated]
}

resource "aws_glue_crawler" "machine_learning_curated_crawler" {
  name          = "${var.project_name}-machine-learning-curated-crawler"
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_role.arn
  s3_target {
    path = "s3://${aws_s3_bucket.machine_learning_curated.bucket}"
  }
  depends_on = [aws_s3_bucket.machine_learning_curated]
}

# Glue Jobs
resource "aws_glue_job" "customer_trusted_job" {
  name             = "${var.project_name}-customer-trusted-job"
  role_arn         = aws_iam_role.glue_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/customer_landing_to_trusted.py"
    python_version  = "3"
  }
  max_capacity     = 2.0
  glue_version     = "3.0"
  default_arguments = {
    "--TempDir"               = "s3://${aws_s3_bucket.athena_results.bucket}/temp/"
    "--enable-continuous-log-filter" = "true"
    "--enable-metrics"        = "true"
    "--project_name"          = var.project_name
    "--enable-glue-datacatalog" = "true"
  }
}

resource "aws_glue_job" "customer_curated_job" {
  name             = "${var.project_name}-customer-curated-job"
  role_arn         = aws_iam_role.glue_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/customer_trusted_to_curated.py"
    python_version  = "3"
  }
  max_capacity     = 2.0
  glue_version     = "3.0"
  default_arguments = {
    "--TempDir"               = "s3://${aws_s3_bucket.athena_results.bucket}/temp/"
    "--enable-continuous-log-filter" = "true"
    "--enable-metrics"        = "true"
    "--project_name"          = var.project_name
    "--enable-glue-datacatalog" = "true"
  }
}

resource "aws_glue_job" "accelerometer_trusted_job" {
  name             = "${var.project_name}-accelerometer-trusted-job"
  role_arn         = aws_iam_role.glue_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/accelerometer_landing_to_trusted.py"
    python_version  = "3"
  }
  max_capacity     = 2.0
  glue_version     = "3.0"
  default_arguments = {
    "--TempDir"               = "s3://${aws_s3_bucket.athena_results.bucket}/temp/"
    "--enable-continuous-log-filter" = "true"
    "--enable-metrics"        = "true"
    "--project_name"          = var.project_name
    "--enable-glue-datacatalog" = "true"
  }
}

resource "aws_glue_job" "step_trainer_trusted_job" {
  name             = "${var.project_name}-step-trainer-trusted-job"
  role_arn         = aws_iam_role.glue_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/step_trainer_trusted.py"
    python_version  = "3"
  }
  max_capacity     = 2.0
  glue_version     = "3.0"
  default_arguments = {
    "--TempDir"               = "s3://${aws_s3_bucket.athena_results.bucket}/temp/"
    "--enable-continuous-log-filter" = "true"
    "--enable-metrics"        = "true"
    "--project_name"          = var.project_name
    "--enable-glue-datacatalog" = "true"
  }
}

resource "aws_glue_job" "machine_learning_curated_job" {
  name             = "${var.project_name}-machine-learning-curated-job"
  role_arn         = aws_iam_role.glue_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/machine_learning_curated.py"
    python_version  = "3"
  }
  max_capacity     = 2.0
  glue_version     = "3.0"
  default_arguments = {
    "--TempDir"               = "s3://${aws_s3_bucket.athena_results.bucket}/temp/"
    "--enable-continuous-log-filter" = "true"
    "--enable-metrics"        = "true"
    "--project_name"          = var.project_name
    "--enable-glue-datacatalog" = "true"
  }
}
