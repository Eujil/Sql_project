-- subqueries further study 
/* builds query from inside out as we test each query if each part works 
 
 
 
 
 /* a query that u can define in another query, like a subquery

*/ 

-- list of purchases of Medium Visual only 

SELECT 
    Transactions.Transaction_id

FROM Transactions 

LEFT JOIN Product 
ON Transactions.Product = Products.Product

WHERE 
    Products.Medium = 'Visual'

--with subquery 

SELECT * 
FROM Transactions 
WHERE product IN 
    SELECT product 
    FROM products 
    WHERE Medium = 'Visual' 

-- Replace a table reference in a query, especially when a JOIN command is used  

SELECT  
    a.Field_1, 
    b.Field_1,  
    a.Field_N, 
    b.FIeld_N 

FROM Table_1a 
LEFT JOIN Table_1b 
    ON a.key = b.key 

--with subquery

SELECT  
    a.Field_1, 
    b.Field_1,  
    a.Field_N, 
    b.FIeld_N 

FROM Table_1a 
LEFT JOIN 
    (SELECT 
        key, 
        SUM(Field_A) AS Field_1,
        COUNT(*) AS FIELD_N
    FROM Table_B GROUP BY key) b 
    ON a.Key = b.key

-- A subquery in a JOIN usually follows this pattern:
SELECT main_table.columns, subquery_table.columns
FROM main_table
JOIN ( 
    SELECT subquery_columns 
    FROM some_table 
    GROUP BY grouping_column
) subquery_table
ON main_table.key = subquery_table.key;


/* 1. subquery can be used in the SELECT CAUSE 

Ex: Get the total sales for each customer along with their orders */

--formula 
SELECT column_name, 
       (SELECT aggregate_function(column_name) FROM table_name WHERE condition) AS alias
FROM main_table;

SELECT 
    customer_id,
    SELECT(SUM(total_sales) FROM orders WHERE orders.customer_id = customers.customer_id AS total_sales)
FROM customers; 

/* The subquery calculates the total spent by each customer (SUM(TotalAmount)).
The outer query then displays this for every customer. */




/* 2. Subquery in the FROM Clause (Derived table)

Ex: find employees with the highest salaries in each department*/

SELECT 
    main_table.Employee_id

FROM main_table
JOIN 
    (SELECT
        salary_table.salaries
    FROM salary_table
    GROUP BY main_table.Employee_id 
    ) salary 
 ON main_table.Employee_id = salary_table.Employee_id; ? 

SELECT e.EmployeeName, e.DepartmentID, high_salaries.MaxSalary
FROM Employees e
JOIN (SELECT DepartmentID, MAX(Salary) AS MaxSalary 
      FROM Employees 
      GROUP BY DepartmentID) high_salaries
ON e.DepartmentID = high_salaries.DepartmentID AND e.Salary = high_salaries.MaxSalary;
