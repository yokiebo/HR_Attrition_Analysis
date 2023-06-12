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




-- Recent Attrition

SELECT 
	DATE(attrition_date) AS attrition_date,
	employee_number AS emp_no,
	job_role,
	department,
	ROUND(CAST((environment_satisfaction + job_satisfaction + job_involvement + relationship_satisfaction + work_life_balance) AS numeric) / 5, 1)  AS Avg_satisfaction_score,
	performance_rating,
	monthly_income:: money,
	CONCAT(percent_salary_hike, '%') AS salary_hike
FROM hr_attrition
WHERE attrition_date IS NOT NULL
ORDER BY attrition_date DESC, employee_number





