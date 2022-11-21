/* MVP */

/* Q1 */
SELECT *
FROM employees
WHERE department = 'Human Resources';

/* Q2 */
SELECT 
    first_name, 
    last_name, 
    country 
FROM employees
WHERE department = 'Legal';

/* Q3 */
SELECT 
    COUNT(*) AS employees_in_portugal
FROM employees   
WHERE country = 'Portugal';

/* Q4 */
SELECT 
    COUNT(*) employees_in_spain_and_portugal
FROM employees   
WHERE country IN ('Spain','Portugal');


/* Q5 */
SELECT 
    COUNT(*) AS count_of_local_account_no_is_null
FROM pay_details 
WHERE local_account_no IS NULL;

/* Q6 */
SELECT * -- FIRST CHECK how many ibans ARE null
FROM pay_details 
WHERE iban IS NULL;

SELECT 
FROM pay_details 
WHERE local_account_no IS NULL AND iban IS NULL;
-- no there are not

/* Q7 */
SELECT 
     first_name ,
     last_name,
FROM employees   
ORDER BY last_name ASC NULLS LAST;

/* Q8 */
SELECT 
     first_name ,
     last_name,
     country
FROM employees   
ORDER BY country, last_name ASC NULLS LAST;

/* Q9 */
SELECT *
FROM employees   
ORDER BY salary DESC NULLS LAST
LIMIT 10;

/* Q10 */
SELECT 
     first_name ,
     last_name,
     salary, 
     country 
FROM employees 
WHERE country = 'Hungary'
ORDER BY salary ASC NULLS LAST; -- unecessary IN this case

/* Q11 */
SELECT 
    COUNT(*) AS name_start_with_F
FROM employees 
WHERE first_name  ~'^F';

/* Q12 */
SELECT 
    COUNT(*) AS email_server_is_yahoo
FROM employees 
WHERE email ~'@yahoo';

/* Q13 */
SELECT
    COUNT(*) AS pension_enrolled_exc_France_and_Germany
FROM employees
WHERE country NOT IN ('France', 'Germany') AND pension_enrol IS TRUE; 

/* Q14 */
SELECT salary
FROM employees
WHERE fte_hours = 1
ORDER BY salary DESC NULLS LAST
LIMIT 1;

/* Q15 */
SELECT
    first_name,
    last_name,
    fte_hours,
    salary,
    (fte_hours * salary) AS effective_yearly_salary
FROM employees;   

/* EXTENSION */
/* Q16 */

SELECT
    first_name,
    last_name,
    department,
    CONCAT(first_name,' ',last_name,' - ',department) AS badge_label
FROM employees
WHERE NOT (first_name ISNULL OR last_name ISNULL OR department ISNULL)

/* Q17 */
SELECT
    first_name,
    last_name,
    department,
    start_date,
    CONCAT(first_name,' ',last_name,' - ',department,
    ' (joined ',
    TRIM(TO_CHAR(start_date,'Month')),
    ' ',
    EXTRACT(YEAR FROM start_date),
    ')') 
    AS badge_label
FROM employees
WHERE NOT (first_name ISNULL OR last_name ISNULL 
OR department ISNULL OR start_date ISNULL);

/* Q18 */
SELECT 
    salary,
    CASE
        WHEN salary IS NULL THEN NULL
        WHEN salary >= 40000 THEN 'high'
        ELSE  'low'   
    END AS salary_class
FROM employees
ORDER BY salary DESC NULLS LAST;



