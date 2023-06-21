/* 
The purpose of the following SQL queries is to validate the values and ensure the accuracy of the formulas used in the data visualization
produced in Tableau. 
Data Visualization: https://public.tableau.com/views/HRAttritionDashboardProject_16865853535310/Viz?:language=en-US&:display_count=n&:origin=viz_share_link

Project Name: Analysis of Attrition Data in the Human Resources Department
Skills used: CTE, CASE, Crosstab 
Data Source: https://data.world/markbradbourne/rwfd-real-world-fake-data-season-2/workspace/file?filename=HR_Attrition.csv

*/


-- Let's start with the KPIs first
-- Determine the attrition rate, attition count and retention(current employee) count

WITH KPI AS 
(
SELECT 
	  SUM(employee_count):: numeric AS total_employee_count,
	  SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END):: numeric AS attrition_count
FROM hr_attrition
	)
	SELECT 
		ROUND((attrition_count/total_employee_count)*100, 1) AS attrition_rate,
		attrition_count AS total_attrition,
		(total_employee_count - attrition_count) AS Current_employees
	FROM KPI
	
	
-- Before we start with the attrition/retention analysis by demographics, department, etc, I decided to add a new column to the table for easier referencing. 
-- We'll name the new column as attrition_label with only two allowable values: attrition and retention.
	
	
--Add a new table
ALTER TABLE hr_attrition
ADD COLUMN attrition_label TEXT;


-- Insert values into new column
UPDATE hr_attrition
SET attrition_label = CASE WHEN attrition = 'Yes' THEN 'Attrition' ELSE 'Retention' END;
	
	
	
-- DEMOGRAPHICS

-- Attrition/retention by gender

SELECT
	gender, 
	attrition_label,
	COUNT(attrition_label)
FROM hr_attrition
GROUP BY gender, attrition_label
ORDER BY gender DESC, attrition_label ASC
	



-- Attrition/retention by Age group

--Approach 1: By using Crosstab:

CREATE EXTENSION IF NOT EXISTS tablefunc;
	SELECT *
	FROM crosstab (
		'SELECT attrition_label,
				CASE WHEN age BETWEEN 16 AND 24 THEN ''under_25''
					WHEN age BETWEEN 25 AND 34 THEN ''age_25_to_34''
					WHEN age BETWEEN 35 AND 44 THEN ''age_35_to_44''
					WHEN age BETWEEN 45 AND 55 THEN ''age_45_to_55''
					ELSE ''over_55'' END AS age_band,
				COUNT(age)
				FROM hr_attrition
				GROUP BY attrition_label, age_band
				ORDER BY attrition_label, age_band'
				,
				'VALUES (''under_25''), (''age_25_to_34''), (''age_35_to_44''), (''age_45_to_55''), (''over_55'')')
		AS CT (attrition_label text, under_25 bigint, age_25_to_34 bigint, age_35_to_44 bigint, age_45_to_55 bigint, over_55 bigint)
		ORDER BY attrition_label



-- Approach 2: By using CASE statement: 

SELECT 
	attrition_label,
	COUNT(CASE WHEN age < 25 THEN age ELSE NULL END) AS under_25,
	COUNT(CASE WHEN age BETWEEN 25 AND 34 THEN age ELSE NULL END) AS Age_25_to_34,
	COUNT(CASE WHEN age BETWEEN 35 AND 44 THEN age ELSE NULL END) AS Age_35_to_44,
	COUNT(CASE WHEN age BETWEEN 45 AND 55 THEN age ELSE NULL END) AS Age_45_to_55,
	COUNT(CASE WHEN age > 55 THEN age ELSE NULL END) AS over_55
FROM hr_attrition
GROUP BY attrition_label


	
	

-- Attrition/retention by Education

SELECT 
	education,
	COUNT(CASE WHEN attrition = 'Yes' THEN attrition ELSE NULL END) AS attrition_count,
	COUNT(CASE WHEN attrition = 'No' THEN attrition ELSE NULL END) AS retention_count
FROM hr_attrition
GROUP BY education
ORDER BY attrition_count DESC




-- Attrition/retention by Education Field

SELECT
	education_field,
	COUNT(CASE WHEN attrition = 'Yes' THEN attrition ELSE NULL END) AS attrition_count,
	COUNT(CASE WHEN attrition = 'No' THEN attrition ELSE NULL END) AS retention_count
FROM hr_attrition
GROUP BY education_field
ORDER BY attrition_count DESC




-- Attrition/Retention by Department

SELECT
	department,
	COUNT(CASE WHEN attrition = 'Yes' THEN attrition ELSE NULL END) AS attrition_count,
	COUNT(CASE WHEN attrition = 'No' THEN attrition ELSE NULL END) AS retention_count
FROM hr_attrition
GROUP BY department
ORDER BY attrition_count DESC




-- Attrition/Retention by Job Role

SELECT 
	job_role,
	COUNT(CASE WHEN attrition = 'Yes' THEN attrition ELSE NULL END) AS attrition_count,
	COUNT(CASE WHEN attrition = 'No' THEN attrition ELSE NULL END) AS retention_count
FROM hr_attrition
GROUP BY job_role
ORDER BY attrition_count DESC





-- Survey Score 1: Environment Satisfaction


CREATE EXTENSION IF NOT EXISTS tablefunc;
	SELECT *
	FROM crosstab (
		'SELECT attrition_Label, environment_satisfaction, COUNT(environment_satisfaction)
		FROM hr_attrition
		GROUP BY attrition_label, environment_satisfaction
		ORDER BY attrition_label, environment_satisfaction'
		) AS CT(attrition_label text, one bigint, two bigint, three bigint, four bigint)
	ORDER BY attrition_label




-- Survey Score 2: Job Satisfaction

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
		
		
		
		
-- Survey Score 3: Job Involvement


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





-- Survey Score 4: Relationship Satisfaction

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
	
	
	
	

-- Survey Score 5: Work Life Balance

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




		
--Recent attrition table

SELECT 
	CONCAT('E_', employee_number),
	job_role,
	department,
	attrition_date::date,
	ROUND((environment_satisfaction + job_satisfaction + job_involvement + relationship_satisfaction + work_life_balance)::numeric / 5 , 1) AS avg_sat_rating,
	performance_rating,
	monthly_income,
	percent_salary_hike
FROM hr_attrition
WHERE attrition = 'Yes'
ORDER BY attrition_date::date DESC



-- CHECKING IF THE ACTION FILTERS ARE WORKING AS INTENDED

-- Total Attrition
SELECT 
	SUM(employee_count)
FROM hr_attrition
WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000
AND attrition = 'Yes'


-- Total Retention

SELECT 
	SUM(employee_count)
FROM hr_attrition
WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000
AND attrition = 'No'


-- Attrition rate
SELECT 
	ROUND(((SELECT SUM(employee_count)::numeric FROM hr_attrition WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000
AND attrition = 'Yes')
	/
	SUM(employee_count)::numeric)*100, 1)
FROM hr_attrition
WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000


-- Average age
SELECT 
	ROUND(AVG(age)::numeric, 0)
FROM hr_attrition 
WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000


-- SURVEY SCORES

-- Environment Satisfaction
SELECT
	attrition_label,
	SUM(CASE WHEN environment_satisfaction = 1 THEN 1 ELSE 0 END) AS one,
	SUM(CASE WHEN environment_satisfaction = 2 THEN 1 ELSE 0 END) AS two,
	SUM(CASE WHEN environment_satisfaction = 3 THEN 1 ELSE 0 END) AS three,
	SUM(CASE WHEN environment_satisfaction = 4 THEN 1 ELSE 0 END) AS four
FROM hr_attrition
WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000
GROUP BY attrition_label

					
-- Job Satisfaction
SELECT 
	attrition_label,
	SUM(CASE WHEN job_satisfaction = 1 THEN 1 ELSE 0 END) AS one,
	SUM(CASE WHEN job_satisfaction = 2 THEN 1 ELSE 0 END) AS two,
	SUM(CASE WHEN job_satisfaction = 3 THEN 1 ELSE 0 END) AS three,
	SUM(CASE WHEN job_satisfaction = 4 THEN 1 ELSE 0 END) AS four
FROM hr_attrition
WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000
GROUP BY attrition_label

-- Job Involvement
SELECT
	attrition_label,
	SUM(CASE WHEN job_involvement = 1 THEN 1 ELSE 0 END) AS one,
	SUM(CASE WHEN job_involvement = 2 THEN 1 ELSE 0 END) AS two,
	SUM(CASE WHEN job_involvement = 3 THEN 1 ELSE 0 END) AS three,
	SUM(CASE WHEN job_involvement = 4 THEN 1 ELSE 0 END) AS four
FROM hr_attrition
WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000
GROUP BY attrition_label

-- Relationship Satisfaction
SELECT
	attrition_label,
	SUM(CASE WHEN relationship_satisfaction = 1 THEN 1 ELSE 0 END) AS one,
	SUM(CASE WHEN relationship_satisfaction = 2 THEN 1 ELSE 0 END) AS two,
	SUM(CASE WHEN relationship_satisfaction = 3 THEN 1 ELSE 0 END) AS three,
	SUM(CASE WHEN relationship_satisfaction = 4 THEN 1 ELSE 0 END) AS four
FROM hr_attrition
WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000
GROUP BY attrition_label

-- Work Life Balance
SELECT
	attrition_label,
	SUM(CASE WHEN work_life_balance = 1 THEN 1 ELSE 0 END) AS one,
	SUM(CASE WHEN work_life_balance = 2 THEN 1 ELSE 0 END) AS two,
	SUM(CASE WHEN work_life_balance = 3 THEN 1 ELSE 0 END) AS three,
	SUM(CASE WHEN work_life_balance = 4 THEN 1 ELSE 0 END) AS four
FROM hr_attrition
WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000
GROUP BY attrition_label


-- Recent Attrition
SELECT 
	CONCAT('E_', employee_number),
	job_role,
	department,
	attrition_date::date,
	ROUND((environment_satisfaction + job_satisfaction + job_involvement + relationship_satisfaction + work_life_balance)::numeric / 5 , 1) AS avg_sat_rating,
	performance_rating,
	monthly_income,
	percent_salary_hike
FROM hr_attrition
WHERE gender = 'Male' AND age BETWEEN 25 AND 34 AND education = 'Bachelor''s Degree' AND department = 'Sales' AND job_role = 'Sales Executive' AND monthly_income BETWEEN 5000 AND 10000 AND attrition = 'Yes'
ORDER BY attrition_date::date DESC




