/*
---------------------------------------------
-- DATA SEGMENTATION
---------------------------------------------
*/
A. Segment products into cost ranges and COUNT how many products fall into each segment
    + < 100
    + 100 - 500
    + 501 - 1000
    + Above 100
*/
WITH product_cost AS (
    SELECT
        product_name,
        cost,
        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
            WHEN cost BETWEEN 501 AND 1000 THEN '501 - 1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products 
)
SELECT
    cost_range,
    COUNT(product_name) AS product_count
FROM product_cost
GROUP BY cost_range
ORDER BY product_count DESC;

/*
B. GROUP customers into 3 segments based on their spending behaviour
    + VIP: Customers with at least 12 months of history and spending more than 5000
    + Regular: Customers with at least 12 months of history but spending 5000 or less
    + New: Customers with a lifespan less than 12 months
   Find total number of customers by each group 
*/

WITH customer_segmentation AS (
    SELECT
        c.customer_key,
        SUM(s.sales_amount) AS total_spend,
        MIN(s.order_date) AS first_order_date,
        MAX(s.order_date) AS latest_order_date,
        DATEDIFF(MONTH, MIN(s.order_date), MAX(s.order_date))AS lifespan,
        CASE 
        WHEN DATEDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) >= 12 AND SUM(s.sales_amount) > 5000 THEN 'VIP'
        WHEN DATEDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) >= 12 AND SUM(s.sales_amount) < 5000 THEN 'Regular'
        ELSE 'New'
        END AS customer_segment
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT
    customer_segment,
    COUNT(customer_key) AS customer_count
FROM  customer_segmentation
GROUP BY customer_segment
ORDER BY customer_count DESC;
