
-- Project: Retail Sales Analysis
-- File: 3_advanced_kpis.sql

-- Description:
-- This file contains advanced SQL analysis including
-- customer retention, segmentation, ranking,
-- cumulative metrics, and key performance indicators (KPIs).

-- Key Metrics:
-- - Customer Retention & Lifetime
-- - Customer Segmentation
-- - Ranking (Top Customers)
-- - Cumulative Revenue
-- - KPIs: Profit Margin, AOV, CLTV
--
-- Purpose:
-- To generate actionable business insights and support decision-making.

-- Author: Abhay Goral
-- =========================================



--7.ADVANCE SQL INSIGHTS
SELECT*FROM retail_sales

--Customer Retention
SELECT 
    customer_id,
    MIN(sale_date) AS first_purchase,
    MAX(sale_date) AS last_purchase,
    COUNT(*) AS total_orders,
    (MAX(sale_date) - MIN(sale_date)) AS customer_lifetime_days
FROM retail_sales
GROUP BY customer_id;

--Customer segmentation
SELECT 
    customer_segment,
    COUNT(*) AS total_customers
FROM (
    SELECT customer_id,
        CASE 
            WHEN SUM(total_sale) > 10000 THEN 'High Value'
            WHEN SUM(total_sale) > 5000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM retail_sales
    GROUP BY customer_id
) t
GROUP BY customer_segment;

--Find best category for every month
SELECT month,category,category_revenue 
FROM(
	SELECT category,
            DATE_TRUNC('month', sale_date) AS month,
			SUM(total_sale) AS category_revenue,
			DENSE_RANK() OVER(PARTITION BY DATE_TRUNC('month', sale_date) 
			ORDER BY SUM(total_sale) DESC ) AS rnk
	FROM retail_sales
	GROUP BY month,category
)t
WHERE rnk=1
ORDER BY month;

--Calculate cumulative revenue over time
SELECT 
    sale_date,
    SUM(total_sale) AS daily_revenue,
    SUM(SUM(total_sale)) OVER(ORDER BY sale_date) AS cumulative_revenue
FROM retail_sales
GROUP BY sale_date
ORDER BY sale_date;
	
--Rank Customers by Spending
SELECT
	customer_id,
	SUM(total_sale) AS customer_spending,
	DENSE_RANK()OVER(ORDER BY SUM(total_sale) DESC) AS rnk
FROM retail_sales
GROUP BY customer_id;

--Find customers whose spending is above average.

WITH customer_spending AS (
    SELECT 
        customer_id,
        SUM(total_sale) AS total_spent
    FROM retail_sales
    GROUP BY customer_id
)
SELECT *
FROM customer_spending
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM customer_spending
);

SELECT* FROM retail_sales
--8.KPI's

--Profit Margin
SELECT
	ROUND(SUM(total_sale-cogs)::numeric,2) AS total_profit,
	ROUND((SUM(total_sale-cogs)/SUM(total_sale))::numeric*100,2) AS profit_margin_percentage
FROM retail_sales;

--Average Order Value (AOV)
SELECT 
	COUNT(*) total_orders,
	SUM(total_sale) AS total_revenue,
	ROUND(AVG(total_sale)::numeric,2) AS avg_order_value
FROM retail_sales;


--Customer Lifetime Value (CLTV)
--Which customer generates most revenue over time?
SELECT 
	customer_id,
	SUM(total_sale) AS lifetime_value
FROM retail_sales
GROUP BY customer_id
ORDER BY lifetime_value DESC;

--Repeat vs New Customers
SELECT
	COUNT(*) FILTER(WHERE cust_count=1) AS new_customer,
	COUNT(*) FILTER(WHERE cust_count>1) AS repeat_customer
FROM(
	SELECT customer_id,
		COUNT(*) AS cust_count
	FROM retail_sales
	GROUP BY customer_id
)t;


--Revenue per Customer
SELECT 
	ROUND((SUM(total_sale)/COUNT(DISTINCT customer_id))::numeric,2) AS revenue_per_customer
FROM retail_sales;
