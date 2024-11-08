variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name to prefix resources"
  type        = string
  default     = "sensor-data-lakehouse"
}

variable "glue_database" {
  description = "Glue database name"
  type        = string
  default     = "sensor_data_lakehouse_db"
}