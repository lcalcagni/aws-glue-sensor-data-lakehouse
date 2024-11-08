import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue import DynamicFrame

# Function to run SQL queries with Spark
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

# Use project_name from args
project_name = args["project_name"]

# Construct bucket paths
trusted_customer_path = f"s3://{project_name}-customer-trusted/"
trusted_accelerometer_path = f"s3://{project_name}-accelerometer-trusted/"
curated_customer_path = f"s3://{project_name}-customer-curated/"

# Load data from S3 as DynamicFrames
customer_trusted_dyf = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    format="json",
    connection_options={"paths": [trusted_customer_path], "recurse": True},
    transformation_ctx="customer_trusted_node"
)

accelerometer_trusted_dyf = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    format="json",
    connection_options={"paths": [trusted_accelerometer_path], "recurse": True},
    transformation_ctx="accelerometer_trusted_node"
)

# Define SQL query for the join operation
sql_query = """
SELECT DISTINCT c.*
FROM customer_trusted AS c
JOIN accelerometer_trusted AS a ON c.email = a.user
"""

# Execute the SQL join operation
join_dyf = sparkSqlQuery(
    glueContext,
    query=sql_query,
    mapping={"customer_trusted": customer_trusted_dyf, "accelerometer_trusted": accelerometer_trusted_dyf},
    transformation_ctx="JOIN_Query_node"
)

# Write the joined data to the curated S3 bucket
glueContext.write_dynamic_frame.from_options(
    frame=join_dyf,
    connection_type="s3",
    format="json",
    connection_options={"path": curated_customer_path},
    transformation_ctx="customer_curated_node"
)

# Commit job
job.commit()
