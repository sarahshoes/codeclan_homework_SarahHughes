-- MVP
-- Q1a 

SELECT 
 e.first_name,
 e.last_name,
 t."name" AS team_name
FROM teams AS t INNER JOIN employees AS e
ON t.id = e.team_id

-- Q1b 

SELECT 
 e.first_name,
 e.last_name,
 e.pension_enrol,
 t."name" AS team_name
FROM teams AS t LEFT JOIN employees AS e
ON t.id = e.team_id
WHERE pension_enrol = TRUE

-- Q1c 

SELECT 
 e.first_name,
 e.last_name,
 t.charge_cost,
 t."name" AS team_name
FROM teams AS t LEFT JOIN employees AS e
ON t.id = e.team_id
WHERE CAST(t.charge_cost AS INT) > 80
-- or WHERE t.charge_cost::INT > 80

-- Q2

SELECT 
 e.first_name,
 e.last_name,
 p.local_account_no,
 p.local_sort_code 
FROM employees AS e LEFT JOIN pay_details AS p
ON e.pay_detail_id = p.id

-- Q2b

SELECT 
 e.first_name,
 e.last_name,
 p.local_account_no,
 p.local_sort_code,
 t."name" AS team_name
FROM employees AS e LEFT JOIN pay_details AS p
ON e.pay_detail_id = p.id
LEFT JOIN teams AS t ON e.team_id = t.id 

-- Q3

SELECT 
 e.id AS employee_id,
 t."name" AS team_name
FROM employees AS e LEFT JOIN teams AS t
ON e.team_id = t.id
ORDER BY e.id ASC

-- Q3b

SELECT 
 t."name" AS team_name,
 count(e.id)
FROM employees AS e LEFT JOIN teams AS t
ON e.team_id = t.id
GROUP BY t."name"

-- Q3c

SELECT 
 t."name" AS team_name,
 count(e.id) AS num_employees
FROM employees AS e LEFT JOIN teams AS t
ON e.team_id = t.id
GROUP BY t."name"
ORDER BY count(e.id) ASC

