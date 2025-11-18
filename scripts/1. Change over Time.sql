/*
---------------------------------------------
-- CHANGE OVER TIME
---------------------------------------------
This analysis focuses on measuring of how measures eveolves over time, 
helping undertand trends and seasonality
*/

-- A. Analyze Sales performance over time
SELECT
	YEAR(order_date) AS order_year,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);
