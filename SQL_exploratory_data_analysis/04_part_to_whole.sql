-- PART TO WHOLE ANALYSIS

--[Measure]/Toatl [Measure] * 100 By [Dimesnion]

-- Which categories contribute the most to the overall sales?
WITH category_sales AS
(
	SELECT
		p.category,
		SUM(f.sales_amount) total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON p.product_key = f.product_key
	GROUP BY category
)

SELECT
	category,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER()) * 100, 2),'%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC
