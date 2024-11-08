import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

# Initialize Glue context and job parameters
args = getResolvedOptions(sys.argv, ["JOB_NAME", "project_name"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Retrieve project name from arguments
project_name = args["project_name"]

# Define bucket paths
accelerometer_landing_bucket = f"s3://{project_name}-accelerometer-landing/"
customer_trusted_bucket = f"s3://{project_name}-customer-trusted/"
trusted_accelerometer_bucket = f"s3://{project_name}-accelerometer-trusted/"

# Load data from the customer trusted bucket in S3
customer_trusted_node = glueContext.create_dynamic_frame.from_options(
    format_options={"multiline": False},
    connection_type="s3",
    format="json",
    connection_options={"paths": [customer_trusted_bucket], "recurse": True},
    transformation_ctx="customer_trusted_node",
)

# Load data from the accelerometer landing bucket in S3
accelerometer_landing_node = glueContext.create_dynamic_frame.from_options(
    format_options={"multiline": False},
    connection_type="s3",
    format="json",
    connection_options={"paths": [accelerometer_landing_bucket], "recurse": True},
    transformation_ctx="accelerometer_landing_node",
)

# Join customer and accelerometer data on email and user fields
PrivacyJoin_node = Join.apply(
    frame1=customer_trusted_node,
    frame2=accelerometer_landing_node,
    keys1=["email"],
    keys2=["user"],
    transformation_ctx="PrivacyJoin_node",
)

# Drop unnecessary fields
DropFields_node = DropFields.apply(
    frame=PrivacyJoin_node,
    paths=[
        "serialNumber",
        "shareWithPublicAsOfDate",
        "birthDay",
        "registrationDate",
        "shareWithResearchAsOfDate",
        "customerName",
        "shareWithFriendsAsOfDate",
        "email",
        "lastUpdateDate",
        "phone",
    ],
    transformation_ctx="DropFields_node",
)

# Write output to the trusted accelerometer bucket
output_node = glueContext.write_dynamic_frame.from_options(
    frame=DropFields_node,
    connection_type="s3",
    format="json",
    connection_options={"path": trusted_accelerometer_bucket, "partitionKeys": []},
    transformation_ctx="output_node",
)

job.commit()
