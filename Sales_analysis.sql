-- Amazon Sales Analysis Projects 

-- Create the table so we can import the data

-- creating customers table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
                            customer_id VARCHAR(25) PRIMARY KEY,
                            customer_name VARCHAR(25),
                            state VARCHAR(25)
);


-- creating sellers table
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
                        seller_id VARCHAR(25) PRIMARY KEY,
                        seller_name VARCHAR(25)
);


-- creating products table
DROP TABLE IF EXISTS products;
CREATE TABLE products (
                        product_id VARCHAR(25) PRIMARY KEY,
                        product_name VARCHAR(255),
                        Price FLOAT,
                        cogs FLOAT
);



-- creating orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
                        order_id VARCHAR(25) PRIMARY KEY,
                        order_date DATE,
                        customer_id VARCHAR(25),  -- this is a foreign key from customers(customer_id)
                        state VARCHAR(25),
                        category VARCHAR(25),
                        sub_category VARCHAR(25),
                        product_id VARCHAR(25),   -- this is a foreign key from products(product_id)
                        price_per_unit FLOAT,
                        quantity INT,
                        sale FLOAT,
                        seller_id VARCHAR(25),    -- this is a foreign key from sellers(seller_id)
    
                        CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
                        CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),    
                        CONSTRAINT fk_sellers FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);



-- creating returns table
DROP TABLE IF EXISTS returns;
CREATE TABLE returns (
                        order_id VARCHAR(25),
                        return_id VARCHAR(25),
                        CONSTRAINT pk_returns PRIMARY KEY (order_id), -- Primary key constraint
                        CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
-- Importing the data into the table 

-- -------------------------------------------------------------------------------------
-- Solving Business Problems 
-- -------------------------------------------------------------------------------------

-- Q.1 Find total sales for each category ?

SELECT 
	category,
	SUM(sales) as total_sales
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


-- Q.2 Find out top 5 customers who made the highest profits?
SELECT 
	customer_name,
	SUM(profit) as total_profit
FROM sales
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5;

-- Q.3 Find out the average quantity ordered per category.
SELECT
	category,
	AVG(quantity) as avg_qty_ordered
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


-- Q.4 Find the top 5 products that generate the highest revenue. 

SELECT 
    product_name,
    ROUND(SUM(sales)::numeric, 2) as revenue
FROM 
    sales
GROUP BY 
    1
ORDER BY 
    2 DESC
LIMIT 5;


-- Q.5 Find the top 5 products whose revenue has decreased compared to previous year?

WITH py1 
AS (
	SELECT
		product_name,
		SUM(sales) as revenue
	FROM sales
	WHERE year = '2023'
	GROUP BY 1
),
py2 
AS	(
	SELECT
		product_name,
		SUM(sales) as revenue
	FROM sales
	WHERE year = '2022'
	GROUP BY 1
)
SELECT
	py1.product_name,
	py1.revenue as current_revenue,
	py2.revenue as prev_revenue,
	(py1.revenue / py2.revenue) as revenue_decreased_ratio
FROM py1
JOIN py2
ON py1.product_name = py2.product_name
WHERE py1.revenue < py2.revenue
ORDER BY 2 DESC
LIMIT 5;
	

-- Q.6 Highest profitable sub category ?

SELECT 
	sub_category,
	sum(profit)
FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- Q.7 Find out states with highest total orders?


SELECT 
	state,
	COUNT(id) as total_order
FROM sales
GROUP BY 1
ORDER BY 2 DESC; 
	
-- Q.8 Determine the month with the highest number of orders.

SELECT 
	(month ||'-' || year) month_name, -- for mysql CONCAT()
	COUNT(id)
FROM sales
GROUP BY 1
ORDER BY 2 DESC;

	
-- Q.9 Calculate the profit margin percentage for each sale (Profit divided by Sales).


SELECT 
	profit/sales as profit_mergin
FROM sales;
	

-- Q.10 Calculate the percentage contribution of each sub-category to 
-- the total sales amount for the year 2023.
	

WITH CTE
	AS (SELECT
			sub_category,
			SUM(sales) as revenue_per_category
		FROM sales
		WHERE year = '2023'
		GROUP BY 1

)

SELECT	
	sub_category,
	(revenue_per_category / total_sales * 100)
FROM cte
CROSS JOIN
(SELECT SUM(sales) AS total_sales FROM sales WHERE year = '2023') AS cte1;


