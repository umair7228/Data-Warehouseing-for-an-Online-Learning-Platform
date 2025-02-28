from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.transfers.local_to_s3 import LocalFilesystemToS3Operator
from datetime import datetime, timedelta
import os
from data_processing import process_data

# Airflow default arguments
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2025, 2, 28),
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

# S3 Configurations
S3_BUCKET = "learning-platform-cleaned-data"

# Define Airflow DAG
dag = DAG(
    "learning_platform_etl",
    default_args=default_args,
    description="ETL pipeline for online learning platform",
    schedule_interval="@daily",
    catchup=False,
)

# Task 1: Process Data with Spark
process_data_task = PythonOperator(
    task_id="process_data",
    python_callable=process_data,
    dag=dag,
)

# Task 2: Upload cleaned files to S3
upload_tasks = []
for file_name in ["courses.csv", "enrollments.csv", "instructors.csv", "skills.csv"]:
    upload_task = LocalFilesystemToS3Operator(
        task_id=f"upload_{file_name}",
        filename=f"cleaned_data/{file_name}",  # Local path
        dest_key=file_name,  # Ensure only filename is used
        dest_bucket=S3_BUCKET,  # Upload directly to bucket root
        replace=True,  # Overwrite if file exists
        aws_conn_id="aws_default",
        dag=dag,
    )
    upload_tasks.append(upload_task)


# Define task dependencies
process_data_task >> upload_tasks