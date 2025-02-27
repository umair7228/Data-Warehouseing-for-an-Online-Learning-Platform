-- Create database
CREATE DATABASE OnlineLearningDW;

-- Create schema
CREATE SCHEMA LearningSchema;

-- Table Creation
CREATE OR REPLACE TABLE LearningSchema.Dim_Courses (
    course_id STRING PRIMARY KEY,
    course_name STRING,
    instructor_id STRING,
    platform STRING,
    category STRING,
    level STRING,
    language STRING,
    price FLOAT,
    duration_hours FLOAT,
    lecture_count INT,
    certificate_type STRING,
    course_url STRING,
    date_added TIMESTAMP
);

CREATE OR REPLACE TABLE LearningSchema.Dim_Instructors (
    instructor_id STRING PRIMARY KEY,
    instructor_name STRING,
    institution STRING,
    experience_years INT,
    email STRING
);

CREATE OR REPLACE TABLE LearningSchema.Dim_Skills (
    course_id STRING REFERENCES LearningSchema.Dim_Courses(course_id),
    skill_name STRING
);

CREATE OR REPLACE TABLE LearningSchema.Fact_Enrollments (
    enrollment_id STRING PRIMARY KEY,
    course_id STRING REFERENCES LearningSchema.Dim_Courses(course_id),
    student_id STRING,
    student_name STRING,
    student_email STRING,
    enrolled_date TIMESTAMP,
    completed BOOLEAN,
    rating FLOAT,
    review_text STRING
);