-- DATA SEGMENTATION

-- [Measure] by [Measure]

/* Segement products into cost ranges and count
how many products fall into each segment */

WITH product_segments AS
(
	SELECT
		product_key,
		product_name,
		cost,
		CASE WHEN cost < 100 THEN 'Below 100'
			 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			 ELSE 'Above 1000'
		END cost_range
	FROM gold.dim_products
)

SELECT
	cost_range,
	COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products
GO
----------------------------------------------------------------------------------------
-- Group customers into three segments based on their spending behavior
-- VIP: at least 12 months of histort and spending more than $5000
-- Regular: at least 12 months of history but spending less than $5000
-- New: less than 12 momths of history
-- Find total number of customers in each segemnt

WITH customer_behavior AS
(
	SELECT
	c.customer_key,
	SUM(f.sales_amount) AS total_spending,
	MIN(f.order_date) first_order_date,
	MAX(f.order_date) last_order_date,
	DATEDIFF(month, MIN(f.order_date),MAX(f.order_date)) AS lifespan
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
	GROUP BY c.customer_key
)

SELECT
t.segments,
COUNT(t.customer_key) total_customers
FROM 
(
	SELECT
		customer_key,
		CASE WHEN lifespan > 11 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan > 11 AND total_spending < 5000 THEN 'Regular'
			 ELSE 'New'
		END segments
	FROM customer_behavior
) t
GROUP BY t.segments
