/*
---------------------------------------------
-- PART TO WHOLE (Proportion)
---------------------------------------------
*/
WITH sales_by_category AS (
    SELECT
        p.category,
        SUM(s.sales_amount) AS product_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY p.category
)
SELECT
    category,
    product_sales,
    CONCAT(ROUND(CAST(product_sales AS FLOAT)/ SUM(product_sales) OVER () * 100.0 ,2), '%') AS percentage_of_sales
FROM sales_by_category
ORDER BY product_sales DESC;
