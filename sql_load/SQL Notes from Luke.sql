SELECT 
    job_title_short AS job_title, 
    job_location AS location, 
    job_posted_date AS date 

FROM job_postings_fact;

-- we will change the format timestamp to date

SELECT 
    job_title_short AS job_title, 
    job_location AS location, 
    job_posted_date::DATE AS date 

FROM job_postings_fact

LIMIT 100;

-- adding timestamp with timezone 

SELECT 
    job_title_short AS job_title, 
    job_location AS location, 
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_timezone, --from utc to est
    EXTRACT(MONTH FROM job_posted_date) AS month

FROM job_postings_fact

LIMIT 100;


SELECT 
    job_title_short, 
    EXTRACT(MONTH FROM job_posted_date) AS month

FROM job_postings_fact

WHERE EXTRACT(MONTH FROM job_posted_date) = 9; 



-- let's see how job postings are trending from month to month

SELECT 
    COUNT(job_id), 
    EXTRACT(MONTH FROM job_posted_date) AS month 
    
FROM 
    job_postings_fact

GROUP BY 
    EXTRACT(MONTH FROM job_posted_date)

ORDER BY 
    COUNT(job_id) DESC;



--if u only care about data analyst role SELECT 

SELECT
    COUNT(job_id) AS job_count, 
    EXTRACT(MONTH FROM job_posted_date) AS month 
    
FROM 
    job_postings_fact

WHERE 
    job_title_short = 'Data Analyst'

GROUP BY 
    month


ORDER BY 
    job_count DESC;

    -- from this result you can see that there is a trend
    -- where early months like jan feb and march has the highest
    -- job postngs



 
/* Practice problem 
1. create three tables 
    - jan 2023 jobs 
    - feb 2023 jobs 
    - mar 2023 jobs 
    
2. Foreshadowing: 
    - Use CREATE TABLE table_name AS to create ur table 
    - Look for a way to filter out certain months by using EXTRACT() 
*/

CREATE TABLE January_2023_jobs AS 
SELECT 
    job_title_short AS jobs,
    COUNT(EXTRACT(month FROM job_posted_date)) AS no_of_jobs
FROM 
    job_postings_fact

WHERE 
    EXTRACT(month FROM job_posted_date) = 1
 
GROUP BY 
    jobs;


CREATE TABLE February_2023_jobs AS 
SELECT 
    job_title_short AS jobs,
    COUNT(EXTRACT(month FROM job_posted_date)) AS no_of_jobs
FROM 
    job_postings_fact

WHERE 
    EXTRACT(month FROM job_posted_date) = 2
 
GROUP BY 
    jobs;



CREATE TABLE March_2023_jobs AS 
SELECT 
    job_title_short AS jobs,
    COUNT(EXTRACT(month FROM job_posted_date)) AS no_of_jobs
FROM 
    job_postings_fact

WHERE 
    EXTRACT(month FROM job_posted_date) = 3
 
GROUP BY 
    jobs;


SELECT * 
FROM    
    January_2023_jobs;


SELECT * 
FROM    
    February_2023_jobs;


SELECT * 
FROM    
    March_2023_jobs;


SELECT COUNT(*) 
FROM 
(SELECT job_title_short FROM job_postings_fact WHERE EXTRACT(MONTH FROM job_posted_date) = 1 ) AS jan_jobs
GROUP BY job_title_short;

/* These are not in the video just practices*/
--This query tells you how many jobs each company posted in New York.
SELECT COUNT(*), c.name
FROM job_postings_fact j
JOIN company_dim c ON j.company_id = c.company_id
WHERE j.job_location = 'New York'
GROUP BY c.name

--subquery version 

-- inner query first
SELECT * FROM job_postings_fact WHERE job_location = 'New York'

-- final query
SELECT COUNT(*), name
FROM company_dim c JOIN (SELECT * FROM job_postings_fact WHERE job_location = 'New York') AS location 
ON c.company_id = location.company_id
GROUP BY name

-- CTE 
WITH location AS 
(SELECT * 
FROM job_postings_fact 
WHERE job_location = 'New York')

SELECT COUNT(*), name 
FROM company_dim c
JOIN location l ON c.company_id = l.company_id
GROUP BY name;





/*
Now we will be using case expressions

Label new column as follows: 
- 'Anywhere' jobs as 'Remote' 
- 'New York, Ny' jobs as 'Local'
- Otherwise 'Onsite'

*/

SELECT 
    job_title_short, 
    job_location, 

    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS new_job_location
FROM 
    job_postings_fact; 

    -- so we can remove job_location 

SELECT 
    job_title_short, 

    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS new_job_location
FROM 
    job_postings_fact; 



-- as a data analyst i wanna analyz how many job I can apply
-- to with the local, remote, and onsite ones 


SELECT 
    COUNT(job_title_short) AS jobs, 

    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS  new_job_location
FROM 
    job_postings_fact 

WHERE 
    job_title_short = 'Data Analyst'

GROUP BY 
    new_job_location; 



/* Let's see a list of companies offering jobs that dont have any requirements or a degree*/


SELECT name AS 
    company_name 

FROM 
    company_dim

WHERE 
    company_id IN (

    SELECT 
        company_id
    FROM 
        job_postings_fact

    WHERE 
        job_no_degree_mention = TRUE
    
    )

ORDER BY company_name ASC;


-- make a list of everything that is in january 

SELECT * 
FROM (SELECT * FROM job_postings_fact WHERE EXTRACT(month FROM job_posted_date) = 1)
AS january_jobs

-- or you can use CTEs 

-- CTEs

WITH january_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1 
    -- CTE definition ends here 
)

SELECT *
FROM January_jobs;

/* find the companies that hve the most job openings. 
- Get the total number of job postings per company id in the job_postings_fact table 
- return the total number of jobs with the company name in the company_dim table 
*/
  
WITH job_openings AS (
    SELECT company_id, COUNT(*) AS jobs
    FROM job_postings_fact
    GROUP BY company_id
)

SELECT c.name AS name, j.jobs
FROM company_dim c 

LEFT JOIN job_openings j ON c.company_id = j.company_id
ORDER BY j.jobs DESC;
--just practicing

WITH no_of_jobs AS (

    SELECT 
        COUNT(*) AS jobs, 
        company_id

    FROM 
        job_postings_fact 

    GROUP BY 
        company_id

)

SELECT 
    company_dim.name AS name, 
    no_of_jobs.jobs
FROM 
    company_dim 

LEFT JOIN no_of_jobs 
ON no_of_jobs.company_id = company_dim.company_id
ORDER BY no_of_jobs.jobs DESC;

--The highest is EMPREGO 
/* COUNT(*) counts all rows in the result set, regardless of whether columns contain NULL values.
This is different from COUNT(column_name), which only counts non-NULL values in that column.

We will then be using the left join method where A is the company dim table 
and job postings will be the B, since there may be some companies that don't have job
postings we aggregated from the B table so we want everything listed so that if there's 0 then there is 0 */


/* Find the count of the number of remote job postings per skill 
- display the top 5 skills by their demand in remote jobs 
- include skill id, name, and count of postings requiring the skill

we need to build a CTEs that collects the number of 
job postings per skill(JOIN between job_postings_fact 
and skills job dim table and then combine with the skills
 dim table for the final result ) we will be using inner join 
 because we are only interested how to get a count of jobs 
 that actually exist */ 

-- this is my version
WITH jb_per_skill AS (
    SELECT sjd.skill_id AS skill_id, COUNT(j.job_work_from_home) AS remote_countings
    FROM skills_job_dim sjd
    INNER JOIN job_postings_fact j ON j.job_id = sjd.job_id
    WHERE j.job_work_from_home = TRUE
    GROUP BY sjd.skill_id
)

SELECT s.skill_id, skills AS skill_name, jb_per_skill.remote_countings
FROM skills_dim s
INNER JOIN jb_per_skill ON s.skill_id = jb_per_skill.skill_id
ORDER BY jb_per_skill.remote_countings DESC
LIMIT 5 -- top skills for remote are python, sql, aws, azure, and spark

-- for data analyst
WITH jb_per_skill AS (
    SELECT sjd.skill_id AS skill_id, COUNT(j.job_work_from_home) AS remote_countings
    FROM skills_job_dim sjd
    INNER JOIN job_postings_fact j ON j.job_id = sjd.job_id
    WHERE j.job_work_from_home = TRUE AND j.job_title_short = 'Data Analyst'
    GROUP BY sjd.skill_id
)

SELECT s.skill_id, skills AS skill_name, jb_per_skill.remote_countings
FROM skills_dim s
INNER JOIN jb_per_skill ON s.skill_id = jb_per_skill.skill_id
ORDER BY jb_per_skill.remote_countings DESC
LIMIT 5


-- luke version
SELECT 
    job_id,
    skill_id

FROM skills_job_dim AS skills

LIMIT 100;

-- if u run this, you will see that each job requires multiple skills ex: job id 0 requires skill id 0 and one and we need to join it to skill table to see the name of the skills 

SELECT 
    job_postings_fact.job_id AS job_id,
    skills.skill_id AS skill_id
    
FROM skills_job_dim AS skills
INNER JOIN job_postings_fact 
ON job_postings_fact.job_id = skills.job_id 

WHERE 
    job_postings_fact.job_work_from_home = TRUE;


-- next step btw we removed the jobid since it appears that there can only be one column used in the group by

WITH remote_job_skills AS (
    SELECT 
        skills.skill_id AS skill_id, 
        COUNT(*) AS skill_count 

    FROM skills_job_dim AS skills
    INNER JOIN job_postings_fact 
    ON job_postings_fact.job_id = skills.job_id 

    WHERE 
        job_postings_fact.job_work_from_home = TRUE

    GROUP BY 
        skills.skill_id) 

SELECT 
    skills_name.skill_id, 
    skills_name.skills, 
    skill_count 

FROM remote_job_skills
INNER JOIN skills_dim AS skills_name 
ON remote_job_skills.skill_id = skills_name.skill_id 

ORDER BY 
    skill_count DESC 

LIMIT 5;

-- the top 5 are python, sql, aws, azure, and spark

-- filtering data analyst remote jobs version

WITH remote_job_skills AS (
    SELECT 
        skills.skill_id AS skill_id, 
        COUNT(*) AS skill_count 

    FROM skills_job_dim AS skills
    INNER JOIN job_postings_fact 
    ON job_postings_fact.job_id = skills.job_id 

    WHERE 
        job_postings_fact.job_work_from_home = TRUE AND 
        job_postings_fact.job_title_short = 'Data Analyst'

    GROUP BY 
        skills.skill_id) 

SELECT 
    skills_name.skill_id, 
    skills_name.skills, 
    skill_count 

FROM remote_job_skills
INNER JOIN skills_dim AS skills_name 
ON remote_job_skills.skill_id = skills_name.skill_id 

ORDER BY 
    skill_count DESC 

LIMIT 5;
-- the answer for top 5 is sql, excel,python, tableau, and power bi  

--UNION OPERATORS 

/* the difference between UNIONS and JOINS is that JOINS combine tables that maybe relate on a single value

so we have made months table here Lets combine these row wise, we could use a UNION operator to do this 
and remember, union requires to have the same amount of columns, and the data type must match
UNION gets rid of dublicate rows while UNION ALL doesnt*/

CREATE TABLE january_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(month FROM job_posted_date) = 1

CREATE TABLE february_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(month FROM job_posted_date) = 2

CREATE TABLE march_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(month FROM job_posted_date) = 3

SELECT job_title_short, company_id, job_location
FROM january_jobs

UNION ALL

SELECT job_title_short, company_id, job_location
FROM february_jobs

UNION ALL

SELECT job_title_short, company_id, job_location
FROM march_jobs

-- UNION ALL is usually used to get all the datas 

/* 
Find job postings from the first quarter that have a salary greater than 70k
- combine job posting tables from the first quarter of 2023 (Jan-March)
- gets job postings with an average yearly salary > 70k*/


SELECT *
FROM (
SELECT * 
FROM january_jobs

UNION 

SELECT * 
FROM february_jobs

UNION 

SELECT * 
FROM march_jobs
) AS quarter1_jobs

-- remove irrelevant columns 

SELECT 
    quarter1_jobs.job_title_short, 
    quarter1_jobs.job_location,
    quarter1_jobs.job_via,
    quarter1_jobs.job_posted_date::DATE

FROM (
    SELECT * 
    FROM january_jobs

    UNION 

    SELECT * 
    FROM february_jobs

    UNION 

    SELECT * 
    FROM march_jobs
) AS quarter1_jobs

WHERE salary_year_avg > 70000

--for data analyst jobs 
SELECT 
    quarter1_jobs.job_title_short, 
    quarter1_jobs.job_location,
    quarter1_jobs.job_via,
    quarter1_jobs.job_posted_date::DATE,
    quarter1_jobs.salary_year_avg

FROM (
    SELECT * 
    FROM january_jobs

    UNION 

    SELECT * 
    FROM february_jobs

    UNION 

    SELECT * 
    FROM march_jobs
) AS quarter1_jobs

WHERE quarter1_jobs.salary_year_avg > 70000 AND
quarter1_jobs.job_title_short = 'Data Analyst'
ORDER BY quarter1_jobs.salary_year_avg DESC
-- you can also remove the quarter1_jobs.

/*
ABOUT THE PROJECT
1. you are an aspiring data nerd looking to analyze the top_paying roles and skills
2. you will create SQL queries to explore this large dataset specific to you
3. For those job searching or looking for a promotion; you can not only use this project to showcase experience BUT also to exract roles/skills you should target*/