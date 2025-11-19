/*
---------------------------------------------
-- PERFORMANCE ANALYSIS
---------------------------------------------
*/
-- A. Analyze the yearly performance of products by comparing each product's sale to both
--		it's average sales perfromance and the previous's year's sales
WITH performance AS (
SELECT 
	YEAR(s.order_date) AS order_year,
	p.product_name AS product_name,
	SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(s.order_date), p.product_name
)

SELECT
	order_year,
	product_name,
	total_sales,
	AVG(total_sales) OVER(PARTITION BY product_name),
	total_sales - AVG(total_sales) OVER(PARTITION BY product_name) AS diff_avg,
	CASE 
		WHEN total_sales - AVG(total_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above change'
		WHEN total_sales - AVG(total_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below average'
		ELSE 'Avg'
	END AS Average_compare,
	LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_year_sale,
	total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_prev,
	CASE 
		WHEN total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No change'
	END AS prev_compare
FROM performance
ORDER BY product_name, order_year ;
