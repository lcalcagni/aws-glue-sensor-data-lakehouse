resource "null_resource" "empty_buckets" {
  provisioner "local-exec" {
    command = <<EOT
      aws s3 rm s3://${aws_s3_bucket.customer_landing.bucket} --recursive
      aws s3 rm s3://${aws_s3_bucket.step_trainer_landing.bucket} --recursive
      aws s3 rm s3://${aws_s3_bucket.accelerometer_landing.bucket} --recursive
      
      aws s3 rm s3://${aws_s3_bucket.customer_trusted.bucket} --recursive
      aws s3 rm s3://${aws_s3_bucket.step_trainer_trusted.bucket} --recursive
      aws s3 rm s3://${aws_s3_bucket.accelerometer_trusted.bucket} --recursive

      aws s3 rm s3://${aws_s3_bucket.customer_curated.bucket} --recursive
      aws s3 rm s3://${aws_s3_bucket.machine_learning_curated.bucket} --recursive

      aws s3 rm s3://${aws_s3_bucket.athena_results.bucket} --recursive
      aws s3 rm s3://${aws_s3_bucket.glue_scripts.bucket} --recursive
    EOT
  }
  depends_on = [
    aws_s3_bucket.customer_landing,
    aws_s3_bucket.step_trainer_landing,
    aws_s3_bucket.accelerometer_landing,    
    aws_s3_bucket.customer_trusted,
    aws_s3_bucket.step_trainer_trusted,
    aws_s3_bucket.accelerometer_trusted,
    aws_s3_bucket.customer_curated,
    aws_s3_bucket.machine_learning_curated,
    aws_s3_bucket.athena_results,
    aws_s3_bucket.glue_scripts
  ]
}
