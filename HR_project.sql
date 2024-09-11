
-- DATA CLEANING

CREATE DATABASE Project;

SELECT *
FROM
	`human resources`;

CREATE TABLE hr
LIKE
	`human resources`;


INSERT INTO hr
SELECT *
FROM
	`human resources`;
    
    
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20);
    
DESCRIBE hr;

SELECT
	birthdate
	,date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
	,date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
FROM
	hr;
    
UPDATE hr
SET birthdate = CASE
					WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
                    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
					ELSE NULL
				END;

SELECT *
FROM
	hr;
    
SET sql_safe_updates = 0;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

SELECT hire_date, 
	date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d'),
    date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
FROM
	hr;

UPDATE hr
SET
	hire_date = CASE
					WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
                    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
                    ELSE NULL
				END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;


SELECT termdate, date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
FROM
	HR
WHERE
	termdate IS NOT NULL
AND
	termdate != '';

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE
	termdate IS NOT NULL
AND
	termdate != '';

SELECT termdate, nullif(termdate, '')
FROM
	HR;

UPDATE HR
SET termdate = nullif(termdate, '');


ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr
ADD COLUMN age INT;


SELECT
	MIN(birthdate)
   ,MAX(birthdate)
FROM
	hr;

SELECT 
	birthdate, date_sub(birthdate, INTERVAL 100 YEAR)
FROM
	hr
WHERE
	birthdate > '2060-01-01'
AND
	birthdate < '2070-01-01';
    
UPDATE hr
SET
	birthdate = DATE_SUB(birthdate, INTERVAL 100 YEAR)
WHERE
	birthdate > '2060-01-01'
AND
	birthdate < '2070-01-01';
    
    
SELECT birthdate, timestampdiff(YEAR, birthdate, CURDATE())
FROM
	hr;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT
	MIN(age)
    ,MAX(age)
FROM
	hr;


SELECT *
FROM
	hr;

------------------------------------------------------------------------------------------------------------------


-- What is the gender breakdown of employees in the company?

SELECT
	gender
    ,COUNT(*) AS Count
FROM
	hr
WHERE
	termdate IS NULL
GROUP BY
	gender;


-------------------------------------------------------------------------------------------------------


-- What is the race/eithnicity breakdown of employees in the company?


SELECT
	race
    ,COUNT(*) AS Count
FROM
	hr
WHERE
	termdate IS NULL
GROUP BY
	race
ORDER BY
	Count DESC;
    
----------------------------------------------------------------------------------------------------

-- What is the age distribution of employees in the company?

SELECT
	MIN(age) AS Youngest
    ,MAX(age) AS Oldest
FROM
	hr
WHERE
	termdate IS NULL;

SELECT
CASE
	WHEN age >=18 AND age <=24 THEN '18-24'
    WHEN age >=25 AND age <=34 THEN '25-34'
    WHEN age >=35 AND age <=44 THEN '35-44'
    WHEN age >=45 AND age <=54 THEN '45-54'
    WHEN age >=55 AND age <=64 THEN '55-64'
    ELSE '65+'
END AS age_group
,COUNT(*) AS Count
FROM
	hr
WHERE
	termdate IS NULL
GROUP BY
	age_group
ORDER BY
	age_group;


SELECT
CASE
	WHEN age >=18 AND age <=24 THEN '18-24'
    WHEN age >=25 AND age <=34 THEN '25-34'
    WHEN age >=35 AND age <=44 THEN '35-44'
    WHEN age >=45 AND age <=54 THEN '45-54'
    WHEN age >=55 AND age <=64 THEN '55-64'
    ELSE '65+'
END AS age_group
,gender
,COUNT(*) AS Count
FROM
	hr
WHERE
	termdate IS NULL
GROUP BY
	age_group
    ,gender
ORDER BY
	age_group;
    
    
-------------------------------------------------------------------------------------------------------


-- How many employees work at headquarters versus remote locations?

SELECT
	location
    ,COUNT(*) AS Count
FROM
	hr
WHERE
	termdate IS NULL
GROUP BY
	location;
    
----------------------------------------------------------------------------------------------

-- What is the average length of employment for employees who have been terminated


SELECT ROUND(AVG(DATEDIFF(termdate, hire_date)) / 365) AS Avg_length_employment
FROM
	hr
WHERE
	termdate <= CURDATE()
AND
	termdate IS NOT NULL;
    
WITH year_termdate AS (    
SELECT
	gender
    ,birthdate
    ,age
    ,timestampdiff(YEAR, termdate, CURDATE()) AS Years_of_termination
FROM
	hr
WHERE
	termdate IS NOT NULL
)
SELECT *
FROM
	year_termdate
WHERE
	Years_of_termination >= 1;
    
----------------------------------------------------------------------------------------------------

-- How does the gender distribution vary across departments and job titles

SELECT department, gender, COUNT(*) AS Count
FROM
	hr
WHERE
	termdate IS NULL
GROUP BY
	department
    ,gender
ORDER BY
	department
    ,gender;
    
-------------------------------------------------------------------------------------------------


-- What is the distribution of job titles across the company?

SELECT jobtitle, COUNT(*) AS Count
FROM
	hr
WHERE
	termdate IS NULL
GROUP BY
	jobtitle
ORDER BY
	jobtitle DESC;
    

----------------------------------------------------------------------------------------------------


-- What department has the highest turnover rate?

SELECT
	department
    ,SUM(hire_date) AS total_count
    ,SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END  ) AS terminated_count
FROM
	hr
GROUP BY
	department;
    

SELECT
	department
    ,total_count
    ,terminated_count
    ,(terminated_count/total_count) AS terminated_rate
FROM (
	SELECT
		department
    ,COUNT(hire_date) AS total_count
    ,SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END  ) AS terminated_count
FROM
	hr
GROUP BY
	department
) AS subquery
ORDER BY
	terminated_rate DESC;


--------------------------------------------------------------------------------------------------------


-- What is the distribution of employees across location by city and state?

SELECT
	location_state
    ,COUNT(*) AS count
FROM
	hr
WHERE
	termdate IS NULL
GROUP BY
    location_state
ORDER BY
	count DESC;
    
    
------------------------------------------------------------------------------------------------------


-- What has the company employee count change over time based on hire and term dates?
    
SELECT
	YEAR(hire_date) AS `YEAR`
    ,COUNT(hire_date) AS hires
    ,SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
FROM
	hr
 GROUP BY
	`YEAR`;
    
SELECT
	`YEAR`
    ,hires
    ,terminations
    ,(hires - terminations) AS net_change
    ,ROUND((hires - terminations)/hires * 100, 2) AS net_change_percent
FROM (
	SELECT
		YEAR(hire_date) AS `YEAR`
		,COUNT(hire_date) AS hires
		,SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
	FROM
		hr
	GROUP BY
		`YEAR`
) AS subquery
ORDER BY
	`YEAR`;
	
 
-------------------------------------------------------------------------------------------------

-- What is the tenure distribution for each department?

SELECT
	department
    ,ROUND(AVG(DATEDIFF(termdate, hire_date)/ 365)) AS avg_tenure
FROM
	hr
WHERE
	termdate <= CURDATE() AND termdate IS NOT NULL
GROUP BY
	department;
    

    
    
    
    
    
    
    
    
    
    
    







    
    
    