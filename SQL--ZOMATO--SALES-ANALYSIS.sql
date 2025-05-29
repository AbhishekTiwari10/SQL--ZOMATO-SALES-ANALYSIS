-- Data insertion :- 

-- the data was inserted into the PostgreSQL database through the built-in import functionality. 
-- This method allows you to load CSV files directly into their respective tables
-- without manually writing SQL COPY or INSERT INTO commands. The import feature automatically maps columns, 
-- detects data types, and ensures smooth data insertion



-- Note : - you can also use copy or insert into command for data insetion

---\c zomato_db;


--  #COPY mainly used for bulk data loading from CSV files. It is faster than multiple 
--  INSERT INTO statements and is an alternative to the Import option in pgAdmin.


-- Load customers data
COPY customers FROM 'E:\PostgresSQL\zomato analysis\customers.csv' DELIMITER ',' CSV HEADER;

-- Load restaurants data
COPY restaurants FROM 'E:\PostgresSQL\zomato analysis\restaurants.csv' DELIMITER ',' CSV HEADER;

-- Load food data
COPY food FROM 'E:\PostgresSQL\zomato analysis\food.csv' DELIMITER ',' CSV HEADER;

-- Load menu data
COPY menu FROM 'E:\PostgresSQL\zomato analysis\menu.csv' DELIMITER ',' CSV HEADER;

-- Load orders data
COPY orders FROM 'E:\PostgresSQL\zomato analysis\orders.csv' DELIMITER ',' CSV HEADER;


-- OR

-- Insert into customers table
INSERT INTO customers (cust_name, email, password, age, gender, marital_status, occupation, monthly_income) 
VALUES ('Rahul Sharma', 'rahul@example.com', 'password123', 30, 'Male', 'Single', 'Software Engineer', '70000');

-- Insert into restaurants table
INSERT INTO restaurants (rest_id, rest_name, city, rating, rating_count, cost, cuisine, lic_no, address) 
VALUES (101, 'Spice Garden', 'Mumbai', 4.5, 120, 800, 'Indian', 'LIC123456', 'Andheri East, Mumbai');

-- Insert into food table
INSERT INTO food (food_id, item, veg_or_non_veg) 
VALUES ('F001', 'Paneer Butter Masala', 'Veg');

-- Insert into menu table
INSERT INTO menu (menu_id, rest_id, food_id, cuisine, price) 
VALUES ('M001', 101, 'F001', 'North Indian', 350.00);

-- Insert into orders table
INSERT INTO orders (order_date, sales_qty, sales_amount, currency, cust_id, rest_id) 
VALUES ('2025-03-17', 2, 700.00, 'INR', 1, 101);



-- INSERT INTO method is useful for manually adding or modifying individual records. 
-- Choosing the right method depends on the scale of data insertion and the specific use case of the project


-- Verify data insertion

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM restaurants;
SELECT COUNT(*) FROM food;
SELECT COUNT(*) FROM menu;
SELECT COUNT(*) FROM orders;

OR 

SELECT * FROM customers;
SELECT * FROM food;
SELECT * FROM restaurants;
SELECT * FROM menu;
SELECT * FROM orders;


-- Check for Null or Missing Values of important column


SELECT * FROM customers 
WHERE
    cust_id IS NULL  OR
    cust_name IS NULL;

SELECT * FROM restaurants 
WHERE 
    rest_id IS NULL  OR
    rest_name IS NULL;

SELECT * FROM menu 
WHERE  
     food_id IS NULL OR
	 menu_id IS NULL;
	 
SELECT * FROM food 
WHERE 
     food_id IS NULL OR
     item IS NULL;

SELECT * FROM orders 
WHERE 
     order_id IS NULL OR
     order_date IS NULL;


-- Deletion of unusual and null values

DELETE FROM customers 
WHERE
    cust_id IS NULL  OR
    cust_name IS NULL;

DELETE FROM restaurants 
WHERE 
    rest_id IS NULL  OR
    rest_name IS NULL;

DELETE FROM menu 
WHERE  
     food_id IS NULL OR
	 menu_id IS NULL;
	 DELETE  FROM food 
WHERE 
     food_id IS NULL OR
     item IS NULL;

DELETE FROM orders 
WHERE 
     order_id IS NULL OR
     order_date IS NULL;
     
--------------------------------------------------------------------------
--Sales_analysis.sql

-- CHECK and ANAYZE the data carefully for further analysis 


SELECT * FROM customers;
SELECT * FROM food;
SELECT * FROM restaurants;
SELECT * FROM menu;
SELECT * FROM orders;


-- We will now write important queries to analyze restaurant sales, customer behavior, and food trends.

-- 1??  Basic Data Retrieval & Filtering :-


-- Retrieve all restaurants:

SELECT * FROM restaurants;

-- List all unique cuisines available:

SELECT DISTINCT cuisine FROM restaurants;

-- Find all vegetarian food items:

SELECT item FROM food WHERE veg_or_non_veg = 'Veg';

-- Find restaurants with a rating above 4.5:

SELECT rest_name, rating FROM restaurants WHERE rating > 4.5;

-- Find all customers who have placed at least one order:

SELECT c.cust_id, c.cust_name FROM customers c
JOIN orders o ON c.cust_id = o.cust_id;

-- Retrieve all menu items sorted by price in descending order:

SELECT * FROM menu ORDER BY price DESC;

-- Find all customers from a specific Age Criteria:

SELECT * FROM customers 
WHERE age > 30;

--  Find all customers who are students:

SELECT * FROM customers WHERE Occupation = 'Student';


-- 2?? Join, Aggregation & Grouping : -


-- Count total orders placed:

SELECT COUNT(*) AS total_orders FROM orders;

-- List all menu items with restaurant names:

SELECT m.food_id, m.cuisine, m.price, r.rest_name 
FROM menu m
INNER JOIN restaurants r ON m.rest_id = r.rest_id;

-- Get all orders with customer and restaurant details:

SELECT o.order_id, c.cust_name, r.rest_name, o.order_date 
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
JOIN restaurants r ON o.rest_id = r.rest_id;

-- Count total orders per restaurant:

SELECT o.rest_id, r.rest_name, COUNT(order_id) AS total_orders 
FROM orders o 
JOIN restaurants r ON  o.rest_id = r.rest_id
GROUP BY o.rest_id, r.rest_name
ORDER BY total_orders DESC;

-- Get details of food items ordered along with restaurant and customer details:

SELECT o.order_id, f.item, f.veg_or_non_veg, c.cust_name, r.rest_name, o.order_date
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
JOIN restaurants r ON o.rest_id = r.rest_id
JOIN menu m ON o.rest_id = m.rest_id 
JOIN food f ON m.food_id = f.food_id;

--  Find customers who have placed orders along with those who haven't:

SELECT c.cust_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id;

-- Find the highest sales amount recorded in a single order: 

SELECT MAX(sales_amount) AS max_sales 
FROM orders;

-- Calculate total revenue generated by each restaurant:

SELECT rest_id, SUM(sales_amount) AS total_revenue 
FROM orders 
GROUP BY rest_id;


-- 3?? Subqueries : - 


--  Find restaurants that have more than 10 menu items:

SELECT rest_id FROM menu GROUP BY rest_id HAVING COUNT(food_id) > 10;

-- Retrieve the most expensive menu item in each cuisine:

SELECT * FROM menu 
WHERE price = (SELECT MAX(price) FROM menu );

--  Retrieve the name of the customer who placed the highest number of orders:

SELECT cust_name FROM customers
WHERE cust_id = (
    SELECT cust_id FROM orders GROUP BY cust_id ORDER BY COUNT(order_id) DESC LIMIT 1
);

-- Find restaurants that have an average menu price higher than the overall average menu price:

SELECT rest_id FROM menu
GROUP BY rest_id 
HAVING AVG(price) > (
    SELECT AVG(price) FROM menu
);




-- 4?? CTEs  : - 


-- Find the top 5 highest revenue-generating restaurants:

WITH Revenue AS (
    SELECT o.rest_id, SUM(o.sales_amount) AS total_revenue 
    FROM orders o
    GROUP BY o.rest_id
)
SELECT r.rest_name, total_revenue FROM Revenue
JOIN restaurants r ON Revenue.rest_id = r.rest_id
ORDER BY total_revenue DESC LIMIT 5;


--  Find the number of orders each customer has placed:

WITH CustomerOrders AS (
    SELECT cust_id, COUNT(order_id) AS total_orders 
    FROM orders 
    GROUP BY cust_id
)
SELECT c.cust_name, co.total_orders FROM CustomerOrders co
JOIN customers c ON co.cust_id = c.cust_id;


-- Identify the highest-spending customer:

WITH CustomerSpending AS (
    SELECT cust_id, SUM(sales_amount) AS total_spent 
    FROM orders 
    GROUP BY cust_id
)
SELECT c.cust_name, cs.total_spent FROM CustomerSpending cs
JOIN customers c ON cs.cust_id = c.cust_id
ORDER BY total_spent DESC LIMIT 1;



--  5?? Window Functions : - 


--  Rank restaurants by total orders:

SELECT rest_id, COUNT(order_id) AS total_orders,
       RANK() OVER(ORDER BY COUNT(order_id) DESC) AS rank_order
FROM orders
GROUP BY rest_id;

-- Show cumulative sales per restaurant over time:

SELECT rest_id, order_date, SUM(sales_amount) OVER (PARTITION BY rest_id ORDER BY order_date) AS cumulative_sales
FROM orders;

-- Calculate running total of orders per customer:

SELECT cust_id, order_id, SUM(sales_amount) OVER (PARTITION BY cust_id ORDER BY order_date) AS running_total
FROM orders;

--  Assign row numbers to orders per customer:

SELECT cust_id, order_id, ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY order_date) AS row_num
FROM orders;

-- Calculate average order value per restaurant with a moving average
SELECT rest_id, order_id, 
AVG(sales_amount) OVER (PARTITION BY rest_id ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM orders;



--  6?? Advanced Analysis : - 


-- Identify the most frequently ordered food items:

SELECT f.item, COUNT(o.order_id) AS order_count 
FROM orders o
JOIN menu m ON o.food_id = m.food_id
JOIN food f ON m.food_id = f.food_id
GROUP BY f.item
ORDER BY order_count DESC LIMIT 5;


--  Find the restaurant with the highest total revenue:

SELECT r.rest_name, SUM(o.sales_amount) AS total_revenue FROM orders o
JOIN restaurants r ON o.rest_id = r.rest_id
GROUP BY r.rest_name ORDER BY total_revenue DESC LIMIT 1;



-----------------------------------------------

-- Zomato Sales Analysis using SQL


-- Drop Orders Table (depends on customers and restaurant)
DROP TABLE IF EXISTS orders;
-- Drop Menu Table (depends on restaurant and food)
DROP TABLE IF EXISTS menu;
-- Drop Restaurant Table (independent after menu and orders are removed)
DROP TABLE IF EXISTS restaurants;
-- Drop Food Table (independent after menu is removed)
DROP TABLE IF EXISTS food;
-- Drop Customers Table (independent after orders are removed)
DROP TABLE IF EXISTS customers;



-- Customers Table
CREATE TABLE customers (
    cust_id SERIAL PRIMARY KEY,
    cust_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    password VARCHAR(255) NOT NULL,
    age INT ,
    gender VARCHAR(10),
    marital_status VARCHAR(50),
    occupation VARCHAR(255),
    monthly_income VARCHAR(50)
);

-- Food Table
CREATE TABLE food (
    food_id VARCHAR(10) PRIMARY KEY,
    item VARCHAR(255) NOT NULL,
    veg_or_non_veg VARCHAR(10) 
);

-- Restaurants Table
CREATE TABLE restaurants (
    rest_id INT PRIMARY KEY,
    rest_name VARCHAR(255) ,
    city VARCHAR(100) NOT NULL,
    rating DECIMAL(3,2),
    rating_count INT ,
    cost INT ,
    cuisine VARCHAR(255),
    lic_no VARCHAR(50) ,
    address TEXT
);

-- Menu Table
CREATE TABLE menu (
    menu_id VARCHAR(10),
    rest_id INT NOT NULL,
    food_id VARCHAR(10) NOT NULL,
    cuisine VARCHAR(255) ,
    price DECIMAL(10,2),
    FOREIGN KEY (rest_id) REFERENCES restaurants(rest_id),
    FOREIGN KEY (food_id) REFERENCES food(food_id)
);


-- Orders Table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL,
    sales_qty INT,
    sales_amount DECIMAL(10,2) ,
    currency VARCHAR(10),
    cust_id INT NOT NULL,
    rest_id INT NOT NULL,
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id),
    FOREIGN KEY (rest_id) REFERENCES restaurants(rest_id)
);



-- End of Schema
-- Zomato Sales Analysis using SQL


-- Drop Orders Table (depends on customers and restaurant)
DROP TABLE IF EXISTS orders;
-- Drop Menu Table (depends on restaurant and food)
DROP TABLE IF EXISTS menu;
-- Drop Restaurant Table (independent after menu and orders are removed)
DROP TABLE IF EXISTS restaurants;
-- Drop Food Table (independent after menu is removed)
DROP TABLE IF EXISTS food;
-- Drop Customers Table (independent after orders are removed)
DROP TABLE IF EXISTS customers;



-- Customers Table
CREATE TABLE customers (
    cust_id SERIAL PRIMARY KEY,
    cust_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    password VARCHAR(255) NOT NULL,
    age INT ,
    gender VARCHAR(10),
    marital_status VARCHAR(50),
    occupation VARCHAR(255),
    monthly_income VARCHAR(50)
);

-- Food Table
CREATE TABLE food (
    food_id VARCHAR(10) PRIMARY KEY,
    item VARCHAR(255) NOT NULL,
    veg_or_non_veg VARCHAR(10) 
);

-- Restaurants Table
CREATE TABLE restaurants (
    rest_id INT PRIMARY KEY,
    rest_name VARCHAR(255) ,
    city VARCHAR(100) NOT NULL,
    rating DECIMAL(3,2),
    rating_count INT ,
    cost INT ,
    cuisine VARCHAR(255),
    lic_no VARCHAR(50) ,
    address TEXT
);

-- Menu Table
CREATE TABLE menu (
    menu_id VARCHAR(10),
    rest_id INT NOT NULL,
    food_id VARCHAR(10) NOT NULL,
    cuisine VARCHAR(255) ,
    price DECIMAL(10,2),
    FOREIGN KEY (rest_id) REFERENCES restaurants(rest_id),
    FOREIGN KEY (food_id) REFERENCES food(food_id)
);


-- Orders Table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL,
    sales_qty INT,
    sales_amount DECIMAL(10,2) ,
    currency VARCHAR(10),
    cust_id INT NOT NULL,
    rest_id INT NOT NULL,
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id),
    FOREIGN KEY (rest_id) REFERENCES restaurants(rest_id)
);



-- End of Schema
-- Zomato Sales Analysis using SQL


-- Drop Orders Table (depends on customers and restaurant)
DROP TABLE IF EXISTS orders;
-- Drop Menu Table (depends on restaurant and food)
DROP TABLE IF EXISTS menu;
-- Drop Restaurant Table (independent after menu and orders are removed)
DROP TABLE IF EXISTS restaurants;
-- Drop Food Table (independent after menu is removed)
DROP TABLE IF EXISTS food;
-- Drop Customers Table (independent after orders are removed)
DROP TABLE IF EXISTS customers;



-- Customers Table
CREATE TABLE customers (
    cust_id SERIAL PRIMARY KEY,
    cust_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    password VARCHAR(255) NOT NULL,
    age INT ,
    gender VARCHAR(10),
    marital_status VARCHAR(50),
    occupation VARCHAR(255),
    monthly_income VARCHAR(50)
);

-- Food Table
CREATE TABLE food (
    food_id VARCHAR(10) PRIMARY KEY,
    item VARCHAR(255) NOT NULL,
    veg_or_non_veg VARCHAR(10) 
);

-- Restaurants Table
CREATE TABLE restaurants (
    rest_id INT PRIMARY KEY,
    rest_name VARCHAR(255) ,
    city VARCHAR(100) NOT NULL,
    rating DECIMAL(3,2),
    rating_count INT ,
    cost INT ,
    cuisine VARCHAR(255),
    lic_no VARCHAR(50) ,
    address TEXT
);

-- Menu Table
CREATE TABLE menu (
    menu_id VARCHAR(10),
    rest_id INT NOT NULL,
    food_id VARCHAR(10) NOT NULL,
    cuisine VARCHAR(255) ,
    price DECIMAL(10,2),
    FOREIGN KEY (rest_id) REFERENCES restaurants(rest_id),
    FOREIGN KEY (food_id) REFERENCES food(food_id)
);


-- Orders Table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL,
    sales_qty INT,
    sales_amount DECIMAL(10,2) ,
    currency VARCHAR(10),
    cust_id INT NOT NULL,
    rest_id INT NOT NULL,
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id),
    FOREIGN KEY (rest_id) REFERENCES restaurants(rest_id)
);



-- End of Schema



















