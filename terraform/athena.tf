resource "aws_s3_bucket" "athena_query_results" {
  bucket = "${var.project_name}-athena-query-results"
  acl    = "private"
}
