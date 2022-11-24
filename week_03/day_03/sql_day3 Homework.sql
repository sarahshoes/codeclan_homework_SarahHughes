-- MVP

-- Q1

SELECT 
    COUNT(*)
FROM employees
WHERE salary ISNULL AND grade ISNULL;

-- Q2

SELECT 
    department,
    CONCAT(first_name,' ',last_name) AS employee_full_name 
FROM employees
ORDER BY department, last_name;

-- Q3

SELECT *
FROM employees 
WHERE last_name LIKE 'A%'
ORDER BY salary DESC NULLS LAST 
LIMIT 10;

-- Q4

SELECT 
    department,
    count(*) AS employees_since_2003
FROM employees
WHERE EXTRACT(YEAR FROM start_date) =2003
GROUP BY department;

-- Q5

SELECT 
  department,
  fte_hours,
  count (*) AS num
 FROM employees
 GROUP BY fte_hours, department
 ORDER BY department, fte_hours ASC

-- Q6

SELECT
 pension_enrol,
 count(*)
FROM employees
GROUP BY pension_enrol;

-- could do a CASE WHEN
WITH pension_status_table AS (
    SELECT
        CASE
            WHEN pension_enrol IS NULL THEN 'unknown status'
            WHEN pension_enrol THEN 'enrolled'
            ELSE  'not enrolled'   
        END AS pension_status
    FROM employees )
SELECT
    pension_status,
    count(*)    
FROM pension_status_table
GROUP BY pension_status;

--shorter - didnt need a table as we are only adding a column.

SELECT 
    pension_enrol,
    count(*),
    CASE
        WHEN pension_enrol = TRUE THEN 'enrolled'
        WHEN pension_enrol = FALSE THEN 'not-enrolled'
        WHEN pension_enrol is NULL THEN 'unknown'
    END AS status
FROM employees
GROUP BY pension_enrol;


-- Q7

SELECT *
 FROM employees
 WHERE department = 'Accounting' AND NOT pension_enrol
 ORDER BY salary DESC NULLS LAST
 LIMIT 1;
 
 -- Q8
 
 WITH country_count AS
    (SELECT
    COUNT(*) AS cc
    FROM employees
    GROUP BY country),
  SELECT 
    country,
    ROUND(AVG(salary)) AS avg_salary
    FROM employees 
    GROUP BY country
    HAVING (SELECT cc FROM country_count) > 30
    ORDER BY avg_salary DESC NULLS LAST;

SELECT
    COUNT(*) AS cc
    FROM employees
    GROUP BY country

-- Matts answer!
SELECT 
    country,
    count(*) AS num_of_employees,
    avg(salary)
FROM employees 
GROUP BY country
HAVING count(*) > 30
ORDER BY avg(salary) DESC;

WITH country_count AS
  (SELECT
  ROUND(AVG(salary)) AS avg_salary,
  country,
  COUNT(*) AS cc
  FROM employees
  GROUP BY country)
  SELECT *
  FROM country_count
  WHERE cc > 30
  ORDER BY avg_salary DESC;

-- Q9
  
 SELECT 
  first_name,
  last_name,
  fte_hours,
  salary,
  fte_hours * salary AS effective_yearly_salary
  FROM employees
  WHERE (fte_hours * salary) > 30000;
  
-- Q10
  
SELECT 
  employees.*, 
  teams.name AS team_name 
FROM teams INNER JOIN employees 
ON teams.id = employees.team_id
WHERE teams."name" LIKE 'Data Team%';  

-- Q11

SELECT 
  e.first_name,
  e.last_name,
  p.local_tax_code  
FROM pay_details AS p INNER JOIN employees AS e 
ON p.id = e.pay_detail_id 
WHERE p.local_tax_code IS NULL;

-- Q12

SELECT 
  e.first_name,
  e.last_name,
  e.department,
  e.salary,
  t.charge_cost,
  t."name",
  (((48 * 35 * CAST(t.charge_cost AS int)) - e.salary) * e.fte_hours) 
  AS expected_profit
FROM teams AS t INNER JOIN employees AS e 
ON t.id = e.team_id

-- note some employees have negative expected profit
 
-- Q13

-- first define sub-query
SELECT
    fte_hours
    FROM employees 
    GROUP BY fte_hours 
    ORDER BY count(*) ASC
    LIMIT 1

 -- then insert into main query.
  SELECT 
    first_name,
    last_name,
    salary,
    fte_hours,
    country
 FROM employees
 WHERE fte_hours = (SELECT
    fte_hours
    FROM employees 
    GROUP BY fte_hours 
    ORDER BY count(*) ASC
    LIMIT 1) AND country = 'Japan'
 ORDER BY salary ASC
 LIMIT 1;
 
 -- Q14
 
 SELECT
   department,
   count (*) AS first_name_missing
FROM employees
WHERE first_name ISNULL
GROUP BY department
HAVING count(*) >=2
ORDER BY count(*) DESC, department ASC


-- Q15

SELECT
   first_name,
   count(*)
FROM employees
WHERE NOT first_name ISNULL
GROUP BY first_name
HAVING count(*) >=2
ORDER BY count(*) DESC, first_name ASC

-- Q16

--count of employees by department 
SELECT
  department,
  count(id) AS count_all
FROM employees
GROUP BY department

SELECT
  department,
  count(id) AS count_grade1
FROM employees
WHERE grade =1
GROUP BY department

SELECT
  id,
  department,
  grade,
  CAST((grade = 1) AS INT) AS is_grade_1,
  COUNT(*) OVER (PARTITION BY department) AS is_grade1
  -- count(*) OVER (PARTITION BY grade) AS all_grades
  FROM employees
  GROUP BY id




SELECT
  id,
  grade,
  department,
  count(*)
FROM employees
GROUP BY department, grade


