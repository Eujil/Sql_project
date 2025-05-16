CREATE TABLE Sales (
    sale_id INT PRIMARY KEY, 
    product_id INT, 
    quantity_sold INT, 
    sale_date DATE, 
    total_price DECIMAL (10,2)
);

INSERT INTO Sales (sale_id, product_id, quantity_sold, sale_date, total_price)
VALUES 

(1, 101, 5, '2024-01-01', 2500.00), 
(2, 102, 3, '2024-01-02', 900.00), 
(3, 103, 2, '2024-01-02', 60.00), 
(4, 104, 4, '2024-01-03', 80.00), 
(5, 105, 6, '2024-01-03', 90.00);



CREATE TABLE Products (
    product_id INT PRIMARY KEY, 
    product_name VARCHAR (100), 
    category VARCHAR(50), 
    unit_price DECIMAL (10,2)
);

INSERT INTO Products (product_id, product_name, category, unit_price)
VALUES 
(101, 'Laptop', 'Electronics', 500.00), 
(102, 'Smartphone', 'Electronics', 300.00), 
(103, 'Headphones', 'Electronics', 30.00), 
(104, 'Keyboard', 'Electronics', 20.00), 
(105, 'Mouse', 'Electronics', 15.00); 


SELECT *
FROM Sales; 

SELECT * 
FROM Products; 

SELECT AVG(unit_price) AS avg_unit_price  
FROM Products; 

SELECT SUM(quantity_sold) AS total_quantity_sold 
FROM Sales;

 --12
 SELECT product_name, unit_price
 FROM Products
 ORDER BY unit_price DESC
 LIMIT 1;

 --13
 SELECT sale_id, product_id, total_price
 FROM sales
 WHERE quantity_sold > 4;

 --14
 SELECT product_name, unit_price
 FROM Products 
 ORDER BY unit_price DESC;

 --15
 SELECT ROUND(SUM(total_price), 2) AS total_price
 FROM Sales;

 --16 
 SELECT ROUND(AVG(total_price),2) AS abg_total_price
 FROM Sales;

 --17
 SELECT sale_id, TO_CHAR(sale_date, 'YYYY-MM-DD') AS sale_date
 FROM Sales;

 --18
SELECT SUM(total_price) AS total_rev
FROM Sales 

WHERE product_id IN (SELECT product_id
    FROM Products 
    WHERE category = 'Electronics'
); 

SELECT SUM(Sales.total_price) AS total_rev
FROM Sales 
JOIN Products ON Sales.product_id = Products.product_id
WHERE Products.category = 'Electronics'

--19
SELECT product_name, unit_price
FROM Products 
WHERE unit_price BETWEEN 20 AND 600;

--INTERMEDIATE 
--1

SELECT SUM(Sales.quantity_sold) AS total_quantity_sold
FROM Sales
JOIN Products ON Sales.product_id = Products.product_id 
WHERE Products.category = 'Electronics';

--2
SELECT *
FROM Sales;

SELECT *
FROM Products;

SELECT Products.product_name, (Sales.quantity_sold * Products.unit_price) AS total_price
FROM Products 
JOIN Sales ON Products.product_id = Sales.product_id;

--3
SELECT *
FROM Sales

SELECT quantity_sold, product_id
FROM Sales 
ORDER BY quantity_sold DESC 
LIMIT 1; -- this can only work when u have non repeating sale count but if it is a daa with multiple purchases of the same product then you need another query

SELECT product_id, COUNT(*) AS sales_count
FROM Sales 
GROUP BY product_id
ORDER BY sales_count DESC
LIMIT 1;

--Since all have the same count, the database just returns the first one it sees, which is product_id = 101

--4
SELECT product_id, product_name 
FROM Products 
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM Sales);


--more examples similar to 4 

/*Find customers who have never made a purchase.

Tables you have:
Customers(customer_id, customer_name)
Orders(order_id, customer_id)*/

--find customers who have made a purchase in the orders table
SELECT DISTINCT customer_id FROM Orders 

-- then the subquery 
SELECT customer_id, customer_name 
FROM Customers 
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM Orders);

/*Find products that have not been restocked.

Tables you have:
Products(product_id, product_name)
Restocks(restock_id, product_id)*/

--Find products that is restocked in the restock table 
SELECT DISTINCT product_id FROM Restocks 

--subquery is 
SELECT product_id, product_name 
FROM Products 
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM Restocks); 

--5
SELECT SUM(Sales.total_price) AS total_revenue
FROM Sales 
JOIN Products ON Sales.product_id = Products.product_id
GROUP BY Products.category 

-- subquery version

-- calculate total revenue generated from sales 

SELECT SUM(Sales.total_price)
FROM Sales 


-- categorized it 

SELECT
(SELECT SUM(Sales.total_price)
FROM Sales ) AS total_rev
FROM Products 
GROUP BY category;

--6 
SELECT category, AVG(unit_price) AS avg_unit_price
FROM Products
GROUP BY category
ORDER BY avg_unit_price DESC

--7
SELECT Products.product_name AS product_name, Sales.total_price AS total_sales
FROM Sales 
JOIN Products ON Sales.product_id = Products.product_id
WHERE Sales.total_price > 30
--It checks each individual sale — if a single sale has total_price > 30, it shows that sale and the product name

SELECT p.product_name
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(s.total_price) > 30;
--It checks the sum of all sales for a product — total sales per product — and only shows products where the combined sales are more than 30.

--8
SELECT TO_CHAR(sale_date, 'Month') AS sale_month, COUNT(quantity_sold) AS no_of_sales
FROM Sales
GROUP BY sale_month;

--9 
SELECT s.total_price AS sales, p.product_name AS name
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
WHERE p.product_name LIKE '%Smart%';

--10
SELECT AVG(S.quantity_sold) AS avg_quantity_sold
FROM Products P
JOIN Sales S ON P.product_id = S.product_id
WHERE P.unit_price > 100;

SELECT *
FROM Products 

SELECT * 
FROM Sales 

--11
SELECT product_name, SUM(s.total_price) AS total_rev
FROM Products p
JOIN Sales s ON p.product_id = s.product_id
GROUP BY product_name
ORDER BY SUM(s.total_price) DESC;

--12
SELECT p.product_name, SUM(s.total_price) AS total_sales_rev
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY SUM(s.total_price) DESC;

--1
SELECT SUM(quantity_sold) AS total_quantity_sold
FROM Sales s
JOIN (SELECT product_id, category FROM Products WHERE category ='Electronics') p
ON s.product_id = p.product_id;

SELECT SUM(quantity_sold) AS total_quantity_sold
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
WHERE p.category = 'Electronics';

--2
SELECT p.product_name, (s.quantity_sold * p.unit_price) AS total_price
FROM Products p 
JOIN Sales s ON p.product_id = s.product_id; 

--3
SELECT product_id, COUNT(quantity_sold) AS sale_count
FROM Sales
GROUP BY product_id
ORDER BY COUNT(quantity_sold) DESC;

--4
SELECT product_id, product_name
FROM Products 
WHERE product_name NOT IN (SELECT DISTINCT Product_name 
FROM Products);

--5 

--more recommended
SELECT p.category, SUM(s.total_price) AS total_rev_gen
FROM Sales s 
JOIN Products p 
ON p.product_id = s.product_id
GROUP BY p.category

--subquery makes it more complex 
SELECT category, SUM(total_price) AS total_rev_gen
FROM (
    SELECT s.total_price, p.category
    FROM Sales s
    JOIN Products p ON s.product_id = p.product_id
) AS sub
GROUP BY category;

SELECT *
FROM Products

SELECT *
FROM Sales

--6
SELECT category, AVG(unit_price) AS avg_unit_price
FROM Products
GROUP BY category
ORDER BY AVG(unit_price) DESC
LIMIT 1;

--7
SELECT product_name
FROM Products
WHERE (SELECT SUM(total_price) FROM Sales) > 30

SELECT p.product_name, SUM(s.total_price) AS total_sales 
FROM Products p
JOIN Sales s ON p.product_id = s.product_id
GROUP BY p.product_name
HAVING SUM(s.total_price) > 30;

--8 
SELECT COUNT(*), TO_CHAR(sale_date, 'Month-YYYY') AS Month
FROM Sales  
GROUP BY TO_CHAR(sale_date, 'Month-YYYY');

--9
SELECT *
FROM Sales
WHERE product_id IN (SELECT product_id FROM Products WHERE product_name LIKE '%Smart%');


--10 

SELECT AVG(quantity_sold) AS avg_quantity_sold
FROM Sales
WHERE product_id IN (SELECT product_id FROM products WHERE unit_price > 100);

--11
SELECT p.product_name, SUM(s.total_price) AS total_rev
FROM Products p
JOIN Sales s ON p.product_id = s.product_id 
GROUP BY p.product_name
ORDER BY SUM(s.total_price) DESC;

--12 
SELECT s.sale_id, p.product_name 
FROM Sales s
JOIN Products p ON s.product_id = p.product_id 

--14
SELECT RANK() OVER (
        ORDER BY SUM(s.total_price) DESC
    ) AS rank,
    p.product_name
FROM Sales s
    JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_name


