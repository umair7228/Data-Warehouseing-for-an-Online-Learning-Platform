# 📚 Data Warehouseing for an Online Learning Platform

## 📌 **Project Overview**  
This **Online Learning Analytics Data Warehouse** is designed to **track student progress, analyze enrollments, and monitor instructor performance** using real-time data processing and cloud technologies.  

With this data warehouse, educators and decision-makers can gain **deep insights** into course completion rates, student engagement, and enrollment trends to **enhance the e-learning experience.**  

---

## 🏢 **Architecture Overview**  

🔹 **Data Sources:** Student enrollments, course completion logs and more (CSV files)  
🔹 **Storage:** Amazon S3  
🔹 **Ingestion:** Snowpipe with auto-ingest  
🔹 **Data Warehouse:** Snowflake  
🔹 **Transformation:** spark
🔹 **Visualization:** Power BI  

### **📊 Data Flow**  
![Architecture Diagram](https://raw.githubusercontent.com/umair7228/Data-Warehouseing-for-an-Online-Learning-Platform/main/Architecture-Diagram.png)

---

## 🎯 **Key Features**  

👉 **Real-time Data Ingestion** – Automated Snowpipe triggers upon new file uploads  
👉 **Optimized Data Modeling** – Implemented **Star Schema** for fast and efficient queries  
👉 **Advanced ETL Pipeline** – Built using **dbt** for transformations and **Apache Airflow** for automation  
👉 **Interactive Power BI Dashboard** – Visual insights on **course completion rates, enrollments, and student performance**  

---

## 🌍 **Schema Design**  

The data warehouse follows a **Star Schema** with the following tables:  

### **📂 Dimension Tables**  
- **DIM_COURSES:** Course details  
- **DIM_INSTRUCTORS:** Instructor information  
- **DIM_SKILLS:** Course-related skills  

### **📂 Fact Table**  
- **FACT_ENROLLMENTS:** Contains enrollment transactions, student progress, and completion status  

**Schema Diagram:**  
```mermaid
erDiagram
    FACT_ENROLLMENTS {
        INT enrollment_id
        INT student_id
        INT course_id
        INT instructor_id
        BOOLEAN completed
        DATE enrolled_date
    }
    DIM_COURSES {
        INT course_id
        STRING course_name
        STRING category
        FLOAT price
    }
    DIM_INSTRUCTORS {
        INT instructor_id
        STRING instructor_name
        STRING expertise
    }
    DIM_SKILLS {
        INT skill_id
        STRING skill_name
        INT course_id
    }
    FACT_ENROLLMENTS ||--o{ DIM_COURSES : "Enrolled in"
    FACT_ENROLLMENTS ||--o{ DIM_INSTRUCTORS : "Taught by"
    FACT_ENROLLMENTS ||--o{ DIM_SKILLS : "Includes skill"
```

---

## 🔍 **Dashboard Insights**  

### **📈 Course Completion Rate**  
**Definition:** Percentage of students who completed a course.  
📊 **Chart Type:** pie Chart  
🔖 **Fields:**  
- **Category:** Course Name  
- **Values:** COUNT(Completed = True)

![Pie Chart](https://drive.google.com/uc?export=view&id=1gsVOHuLGbNqKKMwgNPIHHVzkIA_aM8IO)

### **📀 Enrollment Trends**  
**Definition:** Track the number of enrollments over time.  
📊 **Chart Type:** Line Chart  
🔖 **Fields:**  
- **X-Axis:** Enrollment Date  
- **Y-Axis:** COUNT(Student ID)
  
![Pie Chart](https://drive.google.com/uc?export=view&id=1gerBtll6JPUHdws6NWWaMBSvzFmLjBWX)

### **🏅 Student Performance Analysis**  
**Definition:** Analyzing student ratings and performance.  
📊 **Chart Type:** Bar Chart  
🔖 **Fields:**  
- **X-Axis:** Student Name  
- **Y-Axis:** Average Rating
  
![Pie Chart](https://drive.google.com/uc?export=view&id=1S8XVD0tykYrWfXCkj9OEJ-bRfsUO2Ptz)

---

## 👋 **Contributing**  

We welcome contributions! Follow these steps:  
1️⃣ Fork the repo  
2️⃣ Create a feature branch  
3️⃣ Commit changes  
4️⃣ Open a pull request  

---

## 📩 **Contact & Connect**  

**👤 Umair**  
📧 [Email](mailto:umairnawaz7228@gmail.com)  
👉 [LinkedIn](https://www.linkedin.com/in/umairnawaz7228/)  
🌐 [GitHub](https://github.com/umair7228/)  

🌟 **If you found this project useful, don't forget to ⭐ the repo!**
