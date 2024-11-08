# Glue Role
resource "aws_iam_role" "glue_role" {
  name               = "${var.project_name}_glue_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "glue.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Attach S3 Full Access to Glue Role
resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach Glue Service Role Policy to Glue Role
resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Attach CloudWatch Logs Access
resource "aws_iam_role_policy_attachment" "glue_cloudwatch_logs_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Additional Custom Policy for Glue Role (Optional for fine-grained permissions)
resource "aws_iam_policy" "glue_additional_permissions" {
  name   = "${var.project_name}_glue_additional_permissions"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        "Resource": [
          "arn:aws:s3:::sensor-data-lakehouse-*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "glue:GetTable",
          "glue:GetDatabase",
          "glue:GetTableVersion",
          "glue:GetTableVersions"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_additional_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_additional_permissions.arn
}
