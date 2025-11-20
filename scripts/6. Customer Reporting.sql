/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend

Actions Behind Query
- Start from facts tabale with left join to Dimension table
- Filtering data: Select relevant columns for reports
- Divde process ibto multiple steps
	i} Base Query (CTE)  - ii}Trasnformation - embedded in first step
	iii} Aggregations (CTE) 
	iv} Final Result (VIEW) - v} Final trasnformation embedded within 4th step
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS
WITH base_query AS (
---------------------------------------------------------------------------
-- i} Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------
SELECT
s.order_number,
s.product_key,
s.order_date,
s.sales_amount,
s.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name, --ii}Trasnformation -second step imbedded in firts step)
DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age, --ii}Trasnformation -second step imbedded in firts step)
c.gender,
c.country
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
	ON s.customer_key = c.customer_key
WHERE s.order_date IS NOT NULL)

, customer_aggregation AS (
---------------------------------------------------------------------------
-- iii} Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,-- NO duplicates cause multiple products under one ordeer
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quanitity,
	COUNT( DISTINCT product_key) total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number, 
	customer_name,
	age
)
SELECT
customer_key,
customer_number, 
customer_name,
age,
CASE
	WHEN age < 20 THEN 'Under 20'
	WHEN age BETWEEN 20 and 29 THEN '20-29'
	WHEN age BETWEEN 30 and 39 THEN '30-39'
	WHEN age BETWEEN 40 and 49 THEN '40-49'
	ELSE '50 and Above'
END AS age_group,
CASE 
    WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
    WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
    ELSE 'New'
END AS customer_segment,
last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
total_orders,
total_sales,
total_quanitity,
total_products,
lifespan,
-- Compute average order value (AVO)
CASE
	WHEN total_sales = 0 THEN 0 -- so not to get 0 
	ELSE total_sales/total_orders
END AS average_order_value,
-- Compute average monthly spend
CASE
	WHEN lifespan = 0 THEN 0
	WHEN total_sales = 0 THEN 0
	ELSE total_sales/lifespan
END AS average_monthly_spend
FROM customer_aggregation
