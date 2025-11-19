/*
---------------------------------------------
-- CHANGE OVER TIME
---------------------------------------------
This analysis focuses on measuring of how measures eveolves over time, 
helping undertand trends and seasonality
*/

-- A. Analyze Sales, Customer performance over time
SELECT
	YEAR(order_date)AS order_year,
	DATENAME(MONTH,order_date) AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	sum(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), DATENAME(MONTH,order_date)
ORDER BY YEAR(order_date), DATENAME(MONTH,order_date);
