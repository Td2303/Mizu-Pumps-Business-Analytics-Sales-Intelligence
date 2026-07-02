-- ======================================================
-- MIZU PUMPS | BUSINESS ANALYTICS SQL PLAYBOOK
-- B2C Trading & Distribution Analytics
-- ======================================================

-- 1. Monthly Revenue Dashboard
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(revenue) AS total_revenue,
    COUNT(DISTINCT customer_id) AS active_customers,
    ROUND(AVG(order_value),2) AS avg_order_value
FROM sales
GROUP BY 1
ORDER BY 1;

-- 2. MoM Revenue Growth
SELECT
    month,
    total_revenue,
    ROUND(
        100.0 * (total_revenue - LAG(total_revenue) OVER(ORDER BY month))
        / LAG(total_revenue) OVER(ORDER BY month),2
    ) AS mom_growth_pct
FROM monthly_sales;

-- 3. Top Dealers by Revenue
SELECT
    dealer_name,
    SUM(revenue) AS revenue,
    DENSE_RANK() OVER(ORDER BY SUM(revenue) DESC) AS dealer_rank
FROM dealer_sales
GROUP BY dealer_name
LIMIT 10;

-- 4. Inventory Turnover Analysis
SELECT
    product_category,
    SUM(units_sold) / AVG(avg_inventory) AS inventory_turnover
FROM inventory_kpis
GROUP BY product_category
ORDER BY inventory_turnover DESC;

-- 5. Customer Segmentation (RFM-style)
SELECT
    customer_id,
    COUNT(order_id) AS frequency,
    SUM(revenue) AS monetary_value,
    MAX(order_date) AS last_purchase_date,
    CASE
        WHEN SUM(revenue) > 100000 THEN 'High Value'
        WHEN SUM(revenue) > 50000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM sales
GROUP BY customer_id;

-- 6. Product Profitability Dashboard
SELECT
    sku,
    product_name,
    SUM(revenue) AS revenue,
    SUM(revenue-cost) AS gross_profit,
    ROUND(100.0 * SUM(revenue-cost)/SUM(revenue),2) AS margin_pct
FROM product_sales
GROUP BY sku, product_name
ORDER BY margin_pct DESC;

-- 7. Stock-out Analysis
SELECT
    sku,
    COUNT(*) AS stockout_days
FROM inventory_log
WHERE closing_inventory = 0
GROUP BY sku
ORDER BY stockout_days DESC;

-- 8. Executive KPI View
CREATE VIEW executive_kpis AS
SELECT
    fiscal_year,
    SUM(revenue) AS revenue,
    SUM(gross_profit) AS gross_profit,
    ROUND(AVG(inventory_turnover),2) AS avg_inventory_turnover,
    COUNT(DISTINCT active_dealers) AS dealer_count
FROM annual_business_metrics
GROUP BY fiscal_year;
