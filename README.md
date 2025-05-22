# Introduction 
This Project handles data about Data Analytical roles 

SQL queries are found here: [project_sql folder](/project_sql/)
# Background

Furthermore it answers the following questions:

1. What are the top-paying data analyst jobs?
2. What skills are required for the top-paying data analyst jobs?
3. What are the most in-demand skills for data analysts?
4. What are the top skills based on salary?
5. What are the most optimal skills to learn (aka its in high demand and a high-paying skills)?

# Tools I used
- **SQL**
- **PostgreSQL**
- **Visual Studio Code**
- **Git & Github**

# The Analysis
## 1. What are the top-paying data analyst jobs?

The top 10 highest-paying data analyst roles that are available remotely was first identified. In order to focus on job postings with specified salaries, the nulls were removed. The overall purpose of this SQL query is to highight the top paying opportunities for data analyst, offering insights. 

```sql 
SELECT 
    job_id,
    job_title,
    job_location,
    job_schedule_type, 
    salary_year_avg, 
    job_posted_date,
    name AS company_name

FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id

WHERE job_title_short = 'Data Analyst' 
AND job_location = 'Anywhere' 
AND salary_year_avg IS NOT NULL

ORDER BY salary_year_avg DESC
LIMIT 10; 

```
## Findings: 
The top paying data analyst role offering $650000 as annual salary, comes from Mantys. Following after are data analyst roles that offers principal and directorial position from companies such as Meta, Pinterest, etc. This findings offers an insight on the job market for job seekers planning to take on data analstical role.

## 2. What skills are required for the top-paying data analyst jobs?

By using the findings for question 1, the skills associated to the top-paying jobs are identified through this

```sql
WITH query1 AS (

SELECT 
    job_id,
    job_title,
    salary_year_avg, 
    name AS company_name

FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id

WHERE job_title_short = 'Data Analyst' 
AND job_location = 'Anywhere' 
AND salary_year_avg IS NOT NULL

ORDER BY salary_year_avg DESC
LIMIT 10
)

SELECT query1.*, skills
FROM query1
INNER JOIN skills_job_dim 
ON query1.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY salary_year_avg DESC

```

## Findings 
For data analytical job seekers aiming to get a role offering $200k annualy, it is beneficial to prioritize mastering a combination of **SQL, Python, and Tableau.**. Supplemented with **Power BI, Excel, AWS/Azure, and Git tools**. This analysis will provide a detailed look at which high-paying jobs demand certain skills,
 helping job seekers understand which skills to develop that align with top salaries. 

 ## What are the most in-demand skills for data analysts?
By joining job postings to inner join similar to question 2, the common in-demand skills will be identified. 

```sql
SELECT skills, COUNT(skills_job_dim.skill_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_postings_fact.job_title_short = 'Data Analyst'
AND job_postings_fact.job_location = 'Anywhere'
GROUP BY skills
ORDER BY COUNT(skills_job_dim.skill_id) DESC
LIMIT 5

```
## Findings
The top in-demand skills reveal to be **SQL, Excel, Python, Tableu, and Power Bi**. This results are in lign with the findings found in question 2. Therefore, it is best to be familiar with these tools for data analyst job seekers.

## What are the top skills based on salary?
```sql
SELECT skills, ROUND(AVG(salary_year_avg), 0) AS avg_salary

FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id

WHERE job_postings_fact.job_title_short = 'Data Analyst'
AND salary_year_avg IS NOT NULL
AND job_work_from_home = TRUE
GROUP BY skills
ORDER BY AVG(salary_year_avg) DESC
LIMIT 25

```

## Findings
High-demand skills does not always mean it offers the highest salary. **SQL** is considered to be the most in-demand, but the highest paid skill is **Pyspark**. **Bitbucket, Couchbase, and Watson** are one of the highest paid skill after **Pyspark**. However, the highest in demand reveals to be **Excel and Tableu**. This findings emphasizes the mismatch between demand skills and its salary. Showing that high-paying skills have low demand visibility. 

## What are the most optimal skills to learn (aka its in high demand and a high-paying skills)?

Since it is revealed that high-paying skills does not equal to high-demand skills, let's find out the high-demand skills within the high-salaried set of skills reported in question 4

```sql
WITH topdemandskills AS (
SELECT skills_dim.skill_id, skills_dim.skills, COUNT(skills_job_dim.skill_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_postings_fact.job_title_short = 'Data Analyst'
AND job_postings_fact.job_location = 'Anywhere'
AND salary_year_avg IS NOT NULL
GROUP BY skills_dim.skill_id
), 

tophighpayingskills AS (
SELECT skills_dim.skill_id, ROUND(AVG(salary_year_avg), 0) AS avg_salary

FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id

WHERE job_postings_fact.job_title_short = 'Data Analyst'
AND salary_year_avg IS NOT NULL
AND job_work_from_home = TRUE
GROUP BY skills_dim.skill_id
)

SELECT topdemandskills.skill_id, topdemandskills.skills, demand_count, avg_salary
FROM topdemandskills
INNER JOIN tophighpayingskills ON topdemandskills.skill_id = tophighpayingskills.skill_id 
WHERE demand_count > 10
ORDER BY avg_salary DESC, demand_count DESC

```

If we based it on the average salary, **Go, Confluence, Hadoop, and Snowflake**, are some of the many high-paying skills that have emerged to be the highest, with demand ranging from 11-37. It's not that demanded compared to **SQL, Excel, and Python** that have a demand count ranging from 200-400. But if we are talking about the most optimal skills to learn are those that strike a balance between high demand and high salary—such as **Python, Tableau, Power BI, and SQL**—making them the best investment for those seeking career growth and strong compensation. 


# What have I learn
- **JOINS** - I learned to utilize JOINS to connect different tables to acquire the information that I need. These are through the use of different type of JOINS such as LEFT JOINS and INNER JOINS on the common column that tables share. 
- **CTEs** - CTE's helped me create complex queries more easier as it is similar to substituting a whole query over a temporary table. These can be seen in question 4 and 5.

Overall, this project helped me utilize the SQL skills that i have learned. Only theoretically learn these different queries will prove to be a challenge as learning through theory and learning through application exhibits improvement. Therefore, this project gave me this opportunity to apply the skills that I have learned. 
