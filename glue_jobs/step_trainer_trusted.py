import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue import DynamicFrame

# Define SQL execution function
def sparkSqlQuery(glueContext, query, mapping, transformation_ctx) -> DynamicFrame:
    for alias, frame in mapping.items():
        frame.toDF().createOrReplaceTempView(alias)
    result = spark.sql(query)
    return DynamicFrame.fromDF(result, glueContext, transformation_ctx)

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
landing_step_trainer_path = f"s3://{project_name}-step-trainer-landing/"
trusted_customer_path = f"s3://{project_name}-customer-trusted/"
trusted_step_trainer_path = f"s3://{project_name}-step-trainer-trusted/"

# Load data from S3 into DynamicFrames
step_trainer_landing_dyf = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    format="json",
    connection_options={"paths": [landing_step_trainer_path], "recurse": True},
    transformation_ctx="step_trainer_landing_node"
)

customer_trusted_dyf = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    format="json",
    connection_options={"paths": [trusted_customer_path], "recurse": True},
    transformation_ctx="customer_trusted_node"
)

# Define SQL query for joining data
sql_query = """
SELECT *
FROM step_trainer AS s
JOIN customer AS c ON c.serialNumber = s.serialNumber
"""

# Execute the SQL query join operation
step_trainer_trusted_dyf = sparkSqlQuery(
    glueContext,
    query=sql_query,
    mapping={
        "step_trainer": step_trainer_landing_dyf,
        "customer": customer_trusted_dyf
    },
    transformation_ctx="SQLQuery_node"
)

# Write the joined data to the trusted S3 bucket with Data Catalog update enabled
glueContext.write_dynamic_frame.from_options(
    frame=step_trainer_trusted_dyf,
    connection_type="s3",
    format="json",
    format_options={
        "updateBehavior": "UPDATE_IN_DATABASE",
        "partitionKeys": [],
        "enableUpdateCatalog": True
    },
    connection_options={
        "path": trusted_step_trainer_path,
        "useGlueDataCatalog": "true"
    },
    transformation_ctx="step_trainer_trusted_node"
)

# Commit the job
job.commit()
