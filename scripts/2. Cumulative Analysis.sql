
---------------------------------------------
--  Cumulative Analysis
---------------------------------------------
-- A. Calclate total sales per month and the running total of sales over time
SELECT 
	order_date,
	monthly_sls_amount,
	SUM(monthly_sls_amount) OVER(PARTITION BY order_year ORDER BY order_date) AS running_total,
	AVG(avg_price) OVER(PARTITION BY order_year ORDER BY order_date) AS moving_avg_price
FROM 
(
	SELECT
		YEAR(order_date) AS order_year,
		MONTH(order_date) AS order_mnth_num,
		DATETRUNC(MONTH, order_date) AS order_date,
		SUM(sales_amount) AS monthly_sls_amount,
		AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), MONTH(order_date), DATETRUNC(MONTH, order_date)
)t


