from pyspark.sql import SparkSession
from pyspark.sql.functions import col, lower
import boto3
import os
import shutil

# AWS S3 Configuration
S3_BUCKET = "learning-platform-cleaned-data"

def process_data():
    spark = SparkSession.builder.appName("DataCleaning&Loading").getOrCreate()

    # Read raw CSV files
    df_courses = spark.read.csv("./online-learning-platform/datasets/raw_courses.csv", header=True, inferSchema=True)
    df_enrollments = spark.read.csv("./online-learning-platform/datasets/raw_enrollments.csv", header=True, inferSchema=True)
    df_instructors = spark.read.csv("./online-learning-platform/datasets/raw_instructors.csv", header=True, inferSchema=True)
    df_skills = spark.read.csv("./online-learning-platform/datasets/raw_skills.csv", header=True, inferSchema=True)

    # Data Cleaning
    df_courses = df_courses.fillna({'certificate_type': 'No Certificate'})
    df_courses = df_courses.withColumn("category", lower(df_courses["category"]))
    df_courses = df_courses.withColumn("price", col("price").cast("float"))

    avg_rating = df_enrollments.selectExpr("avg(rating) as avg_rating").collect()[0]["avg_rating"]
    df_enrollments = df_enrollments.fillna({'rating': avg_rating, "completed": False})
    df_enrollments = df_enrollments.withColumn("enrolled_date", col("enrolled_date").cast("date"))
    df_enrollments = df_enrollments.withColumn("rating", col("rating").cast("float"))

    # Ensure local temp directory exists
    os.makedirs("cleaned_data", exist_ok=True)

    # Initialize S3 client
    s3_client = boto3.client("s3", region_name="us-west-2")

    # Save cleaned data as separate CSV files and upload to S3
    dataframes = {
        "courses": df_courses,
        "enrollments": df_enrollments,
        "instructors": df_instructors,
        "skills": df_skills
    }

    for name, df in dataframes.items():
        tmp_folder = f"cleaned_data/{name}_tmp"
        df.coalesce(1).write.mode("overwrite").option("header", "true").csv(tmp_folder)

        # Find the actual CSV file created by Spark
        actual_file = [f for f in os.listdir(tmp_folder) if f.endswith(".csv")][0]
        output_file = f"cleaned_data/{name}.csv"
        os.rename(f"{tmp_folder}/{actual_file}", output_file)

        # Remove temporary Spark output folder
        shutil.rmtree(tmp_folder)

        # Upload CSV file to S3 **without folders**
        s3_client.upload_file(output_file, S3_BUCKET, f"{name}.csv")

        print(f"Uploaded {name}.csv to S3 successfully!")

    print("All files cleaned and uploaded successfully! 🚀")