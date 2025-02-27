CREATE OR REPLACE STORAGE INTEGRATION s3_integeration
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = '<your-arn>'
STORAGE_ALLOWED_LOCATIONS = ('s3://your-bucket-name/');

DESC INTEGRATION s3_integeration;

-- Creating Stage
CREATE OR REPLACE STAGE snowflake_stage
url = 's3://your-bucket-name/'
STORAGE_INTEGRATION = s3_integeration;

SHOW STAGES;
LIST @snowflake_stage;

-- Fact_Enrollments_Pipe Pipe
CREATE OR REPLACE PIPE LearningSchema.Fact_Enrollments_Pipe 
AUTO_INGEST = TRUE
AS 
COPY INTO LearningSchema.Fact_Enrollments
FROM @snowflake_stage
PATTERN = '.*enrollments.csv'
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';


--Dim_Courses_Pipe
CREATE OR REPLACE PIPE LearningSchema.Dim_Courses_Pipe
AUTO_INGEST = TRUE
AS 
COPY INTO LearningSchema.Dim_Courses
FROM @snowflake_stage
PATTERN = '.*courses.csv.*'
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Dim_Instructors_Pipe
CREATE OR REPLACE PIPE LearningSchema.Dim_Instructors_Pipe
AUTO_INGEST = TRUE
AS 
COPY INTO LearningSchema.Dim_Instructors
FROM @snowflake_stage
PATTERN = '.*instructors.csv.*'
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';


-- Dim_Skills_Pipe
CREATE OR REPLACE PIPE LearningSchema.Dim_Skills_Pipe
AUTO_INGEST = TRUE
AS 
COPY INTO LearningSchema.Dim_Skills
FROM @snowflake_stage
PATTERN = '.*skills.csv.*'
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';


SHOW PIPES;
select * from dim_skills;
select * from Dim_Instructors;
select * from dim_courses;
select * from fact_enrollments;
truncate table dim_instructors;
SELECT SYSTEM$PIPE_STATUS('LearningSchema.Fact_Enrollments_Pipe');


-- Student Progress
-- Metrics to Track:

-- Total Courses Enrolled vs. Completed
-- Course Completion Rate
-- Average Rating Given by Student
SELECT 
    student_id,
    student_name,
    COUNT(DISTINCT course_id) AS total_courses_enrolled,
    COUNT(DISTINCT CASE WHEN completed = TRUE THEN course_id END) AS total_courses_completed,
    ROUND(100 * COUNT(DISTINCT CASE WHEN completed = TRUE THEN course_id END) / NULLIF(COUNT(DISTINCT course_id), 0), 2) AS completion_rate_percentage,
    ROUND(AVG(rating), 2) AS avg_rating_given
FROM LearningSchema.Fact_Enrollments
GROUP BY student_id, student_name
ORDER BY completion_rate_percentage DESC;


-- Course Enrollment & Completion Rate
-- Metrics to Track:

-- Total Enrollments per Course
-- Completion Rate per Course
SELECT 
    e.course_id,
    c.course_name,
    c.platform,
    COUNT(e.student_id) AS total_enrollments,
    COUNT(CASE WHEN e.completed = TRUE THEN e.student_id END) AS completed_students,
    ROUND(100 * COUNT(CASE WHEN e.completed = TRUE THEN e.student_id END) / NULLIF(COUNT(e.student_id), 0), 2) AS completion_rate_percentage
FROM LearningSchema.Fact_Enrollments e
JOIN LearningSchema.Dim_Courses c ON e.course_id = c.course_id
GROUP BY e.course_id, c.course_name, c.platform
ORDER BY total_enrollments DESC;


-- Instructor Performance
-- Metrics to Track:

-- Total Students Taught by Instructor
-- Average Course Rating
-- Total Courses Taught
SELECT 
    i.instructor_id,
    i.instructor_name,
    i.institution,
    i.experience_years,
    COUNT(DISTINCT e.student_id) AS total_students_taught,
    COUNT(DISTINCT c.course_id) AS total_courses_taught,
    ROUND(AVG(e.rating), 2) AS avg_course_rating
FROM LearningSchema.Fact_Enrollments e
JOIN LearningSchema.Dim_Courses c ON e.course_id = c.course_id
JOIN LearningSchema.Dim_Instructors i ON c.instructor_id = i.instructor_id
GROUP BY i.instructor_id, i.instructor_name, i.institution, i.experience_years
ORDER BY avg_course_rating DESC;

-- Monthly Enrollment Trends
SELECT 
    DATE_TRUNC('month', enrolled_date) AS enrollment_month,
    COUNT(student_id) AS total_enrollments
FROM LearningSchema.Fact_Enrollments
GROUP BY enrollment_month
ORDER BY enrollment_month ASC;