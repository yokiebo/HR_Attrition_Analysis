/* 
EXPLORATORY DATA ANALYSIS

Project Name: Analysis of Attrition Data in the Human Resources Department
Data Source: https://data.world/markbradbourne/rwfd-real-world-fake-data-season-2/workspace/file?filename=HR_Attrition.csv

*/

-- Let's first create the table

CREATE TABLE hr_attrition 
(
		attrition_date TIMESTAMP,
		random_number NUMERIC,
		age INTEGER,
		attrition TEXT,
		business_travel TEXT,
		daily_rate NUMERIC,
		department TEXT,
		distance_from_home NUMERIC,
		education TEXT,
		education_field TEXT,
		employee_count INTEGER,
		employee_number INTEGER PRIMARY KEY,
		environment_satisfaction INTEGER,
		gender TEXT,
		hourly_rate NUMERIC,
		job_involvement INTEGER,
		job_level INTEGER,
		job_role TEXT,
		job_satisfaction INTEGER,
		marital_status TEXT,
		monthly_income NUMERIC,
		monthly_rate NUMERIC,
		num_companies_worked INTEGER,
		over18 TEXT,
		overtime TEXT,
		percent_salary_hike NUMERIC,
		performance_rating INTEGER,
		relationship_satisfaction INTEGER,
		standard_hours INTEGER,
		stock_option_level INTEGER,
		total_working_years INTEGER,
		training_times_last_year INTEGER,
		work_life_balance INTEGER,
		years_at_company INTEGER,
		years_in_current_role INTEGER,
		years_since_last_promotion INTEGER,
		years_with_curr_manager INTEGER
)

-- Next step is to import the CSV file


-- Total employees
SELECT 
	SUM(employee_count) AS total_employees
FROM hr_attrition


-- Total attrition
SELECT 
	COUNT(attrition) AS total_attrition
FROM hr_attrition
WHERE attrition = 'Yes'


-- Current employees
SELECT 
	SUM(employee_count) - (SELECT COUNT(attrition) FROM hr_attrition WHERE attrition = 'Yes') AS current_employees
FROM hr_attrition


-- Attrition_rate
SELECT
	ROUND((COUNT(attrition):: numeric / (SELECT SUM(employee_count):: numeric FROM hr_attrition))*100, 2) AS attrition_rate
FROM hr_attrition
WHERE attrition = 'Yes'



--Lets see if the distance from home is a factor for employee attrition

CREATE EXTENSION IF NOT EXISTS tablefunc;

	SELECT *
	FROM crosstab 
	(
'SELECT
	CASE WHEN attrition = ''Yes'' THEN ''Attrition'' ELSE ''Retention'' END AS emp_status,
	CASE WHEN distance_from_home <= 10 THEN ''near''
		WHEN distance_from_home BETWEEN 11 AND 20 THEN ''far''
		WHEN distance_from_home >= 21 THEN ''very_far''
		END AS distance,
	COUNT(distance_from_home) AS emp_count
FROM hr_attrition
GROUP BY emp_status, distance
ORDER BY emp_status, distance'
		,
		'VALUES (''near''), (''far''), (''very_far'')'
		) 
		AS (emp_status TEXT, near bigint, far bigint, very_far bigint)
	ORDER BY emp_status
	
-- Attrition rate by Distance from Home

SELECT -- near
	ROUND(((SELECT SUM(CASE WHEN distance_from_home <= 10 THEN 1 ELSE 0 END):: numeric FROM hr_attrition WHERE attrition = 'Yes') / SUM(CASE WHEN distance_from_home BETWEEN 0 AND 10 THEN 1 ELSE 0 END):: numeric)*100, 2) AS near
FROM hr_attrition

SELECT --far
	ROUND(((SELECT SUM(CASE WHEN distance_from_home BETWEEN 11 AND 20 THEN 1 ELSE 0 END):: numeric FROM hr_attrition WHERE attrition = 'Yes') / SUM(CASE WHEN distance_from_home BETWEEN 11 AND 20 THEN 1 ELSE 0 END):: numeric)*100, 2) AS far
FROM hr_attrition

SELECT --very far
	ROUND(((SELECT SUM(CASE WHEN distance_from_home >= 21 THEN 1 ELSE 0 END):: numeric FROM hr_attrition WHERE attrition = 'Yes') / SUM(CASE WHEN distance_from_home BETWEEN 21 AND 30 THEN 1 ELSE 0 END):: numeric)*100, 2) AS very_far
FROM hr_attrition

-- Let's see if business travel has any effect on employee's attrition

CREATE EXTENSION IF NOT EXISTS tablefunc;

	SELECT *
	FROM crosstab 
	(
'SELECT
	CASE WHEN attrition = ''Yes'' THEN ''Attrition'' ELSE ''Retention'' END AS emp_status,
	business_travel,
	COUNT(business_travel) AS emp_count
FROM hr_attrition
GROUP BY emp_status, business_travel
ORDER BY emp_status, business_travel'
		) 
		AS (emp_status TEXT, non_travel bigint, travel_frequently bigint, travel_rarely bigint)
	ORDER BY emp_status
	

	
-- Attrition rate by Travel frequency

--Non-travel
SELECT 
	ROUND(((SELECT SUM(CASE WHEN business_travel = 'Non-Travel' THEN 1 ELSE 0 END):: numeric FROM hr_attrition WHERE attrition = 'Yes') / COUNT(business_travel):: numeric)*100, 2) AS non_travel
FROM hr_attrition
WHERE business_travel = 'Non-Travel'

--Travel frequently
SELECT
ROUND(((SELECT SUM(CASE WHEN business_travel = 'Travel_Frequently' THEN 1 ELSE 0 END):: numeric FROM hr_attrition WHERE attrition = 'Yes') / COUNT(business_travel):: numeric)*100, 2) AS travel_frequently
FROM hr_attrition
WHERE business_travel = 'Travel_Frequently'

-- Travel rarely
SELECT
ROUND(((SELECT SUM(CASE WHEN business_travel = 'Travel_Rarely' THEN 1 ELSE 0 END):: numeric FROM hr_attrition WHERE attrition = 'Yes') / COUNT(business_travel):: numeric)*100, 2) AS travel_rarely
FROM hr_attrition
WHERE business_travel = 'Travel_Rarely'


-- Finding out the Max and Min Salary per department: Attrition vs Retention
SELECT a.department, 
		MAX(daily_rate) AS max_retention,
		max_attrition,
		MIN(daily_rate) AS min_retention,
		min_attrition
FROM hr_attrition a INNER JOIN (
		SELECT department,
			MAX(daily_rate) AS max_attrition,
			MIN(daily_rate) AS min_attrition
	FROM hr_attrition
	WHERE attrition = 'Yes'
	GROUP BY department) b
	ON (a.department = b.department)
WHERE attrition = 'No'
GROUP BY a.department, b.department, max_attrition, min_attrition




-- Comparing average daily rate: Attrition vs Retention

SELECT
	CASE WHEN attrition = 'Yes' THEN 'Attrition'
		WHEN attrition = 'No' THEN 'Retention' ELSE NULL END AS emp_status,
	ROUND(AVG(daily_rate), 2) AS AVG_daily_rate
FROM hr_attrition
GROUP BY emp_status




-- Comparing average daily rate per department: Attrition vs. Retention

WITH CTE AS 
	(
		SELECT 
			department,
			ROUND(AVG(daily_rate), 2) AS AVG_attrition
		FROM hr_attrition 
		WHERE attrition = 'Yes'
		GROUP BY department
		) 
			SELECT 
				a.department, 
				AVG_attrition,
				ROUND(AVG(daily_rate), 2) AS AVG_retention
			FROM CTE a INNER JOIN hr_attrition b 
			ON (a.department = b.department)
			WHERE attrition = 'No'
			GROUP BY a.department, Avg_attrition
			
			
-- Comparing Attrition vs Retention by Gender

SELECT
	CASE WHEN attrition = 'Yes' THEN 'Attrition' ELSE 'Retention' END AS emp_status,
	SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
	SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS female_count
FROM hr_attrition
GROUP BY emp_status
			
			
			
-- Let's add a new column called attrition_label for easier reference. The logic is that if attrition = 'Yes' then we'll call it 'attrition', if attrition = 'No' then we'll call it 'Retention'.


ALTER TABLE hr_attrition -- Adding the column
ADD COLUMN attrition_label TEXT;

UPDATE hr_attrition -- Inserting values into the column
SET attrition_label = CASE WHEN attrition = 'Yes' THEN 'Attrition' ELSE 'Retention' END;
	
			
			
-- Survey Score for Environment Satisfaction: Attrition vs Retention

CREATE EXTENSION IF NOT EXISTS tablefunc;
	SELECT *
	FROM crosstab (
		'SELECT attrition_Label, environment_satisfaction, COUNT(environment_satisfaction)
		FROM hr_attrition
		GROUP BY attrition_label, environment_satisfaction
		ORDER BY attrition_label, environment_satisfaction'
		) AS CT(attrition_label text, one bigint, two bigint, three bigint, four bigint)
	ORDER BY attrition_label



-- Survey Score for Job Satisfaction: Attrition vs Retention

CREATE EXTENSION IF NOT EXISTS tablefunc;
	SELECT *
	FROM crosstab (
		'SELECT
			attrition_label,
			job_satisfaction,
			COUNT(job_satisfaction)
		FROM hr_attrition
		GROUP BY attrition_label, job_satisfaction
		ORDER BY attrition_label, job_satisfaction'
		) AS CT (attrition_label text, one bigint, two bigint, three bigint, four bigint)
	ORDER BY attrition_label
		 
		 

-- Survey Score for Job Involvement: Attrition vs Retention

CREATE EXTENSION IF NOT EXISTS tablefunc;
	SELECT *
	FROM crosstab (
		'SELECT 
			attrition_label,
			job_involvement,
			COUNT(job_involvement)
		FROM hr_attrition
		GROUP BY attrition_label, job_involvement
		ORDER BY attrition_label, job_involvement'
		) AS CT (attrition_label text, one bigint, two bigint, three bigint, four bigint)
	ORDER BY attrition_label



-- Survey Score for Relationship Satisfaction: Attrition vs Retention


CREATE EXTENSION IF NOT EXISTS tablefunc;
	SELECT *
	FROM crosstab (
		'SELECT
			attrition_label,
			relationship_satisfaction,
			COUNT(relationship_satisfaction)
		FROM hr_attrition
		GROUP BY attrition_label, relationship_satisfaction
		ORDER BY attrition_label, relationship_satisfaction'
		) AS CT (attrition_label text, one bigint, two bigint, three bigint, four bigint)
	ORDER BY attrition_label



-- Survey Score for Work-life Balance: Attrition vs Retention

CREATE EXTENSION IF NOT EXISTS tablefunc;
	SELECT *
	FROM crosstab (
		'SELECT
			attrition_label,
			work_life_balance,
			COUNT(work_life_balance)
		FROM hr_attrition
		GROUP BY attrition_label, work_life_balance
		ORDER BY attrition_label, work_life_balance'
		) AS CT (attrition_label text, one bigint, two bigint, three bigint, four bigint)
	ORDER BY attrition_label



-- Let's see which job level has the most attrition/retention

CREATE EXTENSION IF NOT EXISTS tablefunc;
	SELECT *
	FROM crosstab (
		'SELECT 
			attrition_label,
			job_level,
			COUNT(job_level) AS cnt_job_level
		FROM hr_attrition
		GROUP BY attrition_label, job_level
		ORDER BY attrition_label, job_level'
		) AS (attrition_label text, one bigint, two bigint, three bigint, four bigint, five bigint)
	ORDER BY attrition_label
	
	
	
-- Now let's see their marital status

CREATE EXTENSION IF NOT EXISTS tablefunc;
	SELECT *
	FROM crosstab (
		'SELECT 
			attrition_label,
			marital_status,
			COUNT(marital_status) AS cnt_marital_status
		FROM hr_attrition
		GROUP BY attrition_label, marital_status
		ORDER BY attrition_label, marital_status'
		) AS (attrition_label text, divorced bigint, married bigint, single bigint)
	ORDER BY attrition_label
	
	
-- Let's see if working overtime has an effect of employee attrition/retention

SELECT 
	attrition_label,
	SUM(CASE WHEN overtime = 'Yes' THEN 1 ELSE 0 END) AS yes,
	SUM(CASE WHEN overtime = 'No' THEN 1 ELSE 0 END) AS no
FROM hr_attrition
GROUP BY attrition_label


-- Attrition rate for those who work overtime

SELECT
	ROUND(((SELECT SUM(CASE WHEN overtime = 'Yes' THEN 1 ELSE 0 END)::numeric FROM hr_attrition WHERE attrition= 'Yes')/ COUNT(overtime)::numeric)*100, 2) AS ATR_rate_YES
FROM hr_attrition
WHERE overtime = 'Yes'


-- Attrition rate for those who don't work overtime

SELECT
	ROUND(((SELECT SUM(CASE WHEN overtime = 'No' THEN 1 ELSE 0 END)::numeric FROM hr_attrition WHERE attrition= 'Yes')/ COUNT(overtime)::numeric)*100, 2) AS ATR_rate_NO
FROM hr_attrition
WHERE overtime = 'No'


-- Years at company

CREATE EXTENSION IF NOT EXISTS tablefunc;

	SELECT *
	FROM crosstab 
	(
'SELECT
	attrition_label,
	CASE WHEN years_at_company < 10 THEN ''under_10''
		WHEN years_at_company BETWEEN 10 AND 19 THEN ''yr_10_to_19''
		WHEN years_at_company BETWEEN 20 AND 29 THEN ''yr_20_to_29''
		WHEN years_at_company >= 30 THEN ''yr_30_and_above''
		END AS yrs_at_company,
	COUNT(years_at_company) AS years
FROM hr_attrition
GROUP BY attrition_label, yrs_at_company
ORDER BY attrition_label, yrs_at_company'
		,
		'VALUES (''under_10''), (''yr_10_to_19''), (''yr_20_to_29''), (''yr_30_and_above'')'
		) 
		AS (attrition_label TEXT, under_10 bigint, yr_10_to_19 bigint, yr_20_to_29 bigint, yr_30_and_above bigint)
	ORDER BY attrition_label
	
	
SELECT -- Attrition rate for those in company for less than 10 yrs
	ROUND(((SELECT SUM(CASE WHEN years_at_company < 10 THEN 1 ELSE 0 END):: numeric FROM hr_attrition WHERE attrition = 'Yes') / COUNT(years_at_company):: numeric)*100, 2) AS under_10
FROM hr_attrition
WHERE years_at_company < 10


SELECT -- Attrition rate for those in company for 10 yrs to 19 yrs
	ROUND(((SELECT SUM(CASE WHEN years_at_company BETWEEN 10 AND 19 THEN 1 ELSE 0 END):: numeric FROM hr_attrition WHERE attrition = 'Yes') / COUNT(years_at_company):: numeric)*100, 2) AS yr_10_to_19
FROM hr_attrition
WHERE years_at_company BETWEEN 10 AND 19


SELECT -- Attrition rate for those in company for 20 yrs to 29 yrs
	ROUND(((SELECT SUM(CASE WHEN years_at_company BETWEEN 20 AND 29 THEN 1 ELSE 0 END):: numeric FROM hr_attrition WHERE attrition = 'Yes') / COUNT(years_at_company):: numeric)*100, 2) AS yr_20_to_29
FROM hr_attrition
WHERE years_at_company BETWEEN 20 AND 29


SELECT -- Attrition rate for those in company for 30 yrs and above
	ROUND(((SELECT SUM(CASE WHEN years_at_company >= 30 THEN 1 ELSE 0 END):: numeric FROM hr_attrition WHERE attrition = 'Yes') / COUNT(years_at_company):: numeric)*100, 2) AS yr_30_and_above
FROM hr_attrition
WHERE years_at_company >= 30





