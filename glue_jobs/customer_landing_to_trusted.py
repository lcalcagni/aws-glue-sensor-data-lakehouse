import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

# Retrieve arguments
args = getResolvedOptions(sys.argv, ["JOB_NAME", "project_name"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Use project_name from args
project_name = args["project_name"]

# Construct bucket paths
landing_bucket_path = f"s3://{project_name}-customer-landing/"
trusted_bucket_path = f"s3://{project_name}-customer-trusted/"

# Load data from the customer landing zone bucket in S3
customer_landing_dyf = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    format="json",
    connection_options={
        "paths": [landing_bucket_path],
        "recurse": True
    },
    transformation_ctx="customer_landing_node"
)

# Filter customers who consented to data sharing
filtered_dyf = Filter.apply(
    frame=customer_landing_dyf, 
    f=lambda row: (not(row["shareWithResearchAsOfDate"] == 0)),
    transformation_ctx="Filter_node"
)

# Drop duplicate records based on 'email' field
unique_customers_dyf = DynamicFrame.fromDF(
    filtered_dyf.toDF().dropDuplicates(["email"]),
    glueContext,
    "DropDuplicates_node"
)

# Write the filtered and deduplicated data to the Trusted Zone with Data Catalog update enabled
glueContext.write_dynamic_frame.from_options(
    frame=unique_customers_dyf,
    connection_type="s3",
    format="json",
    connection_options={
        "path": trusted_bucket_path,
        "partitionKeys": [],
        "useGlueDataCatalog": "true"  # Enable Data Catalog updates
    },
    transformation_ctx="customer_trusted_node"
)

# Commit job
job.commit()
