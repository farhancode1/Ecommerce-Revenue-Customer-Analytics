-- 03_customer_analysis.sql
-- Customer behaviour using customer_unique_id.

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        MIN(o.order_purchase_timestamp) AS first_order_at,
        MAX(o.order_purchase_timestamp) AS last_order_at,
        SUM(oi.price) AS merchandise_value
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS unique_customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers,
    ROUND(100.0 * COUNT(*) FILTER (WHERE order_count > 1) / NULLIF(COUNT(*),0), 2) AS repeat_purchase_rate_pct,
    ROUND(AVG(order_count), 3) AS avg_orders_per_customer,
    ROUND(AVG(merchandise_value), 2) AS avg_customer_merchandise_value
FROM customer_orders;

-- Top customers by merchandise value
WITH customer_value AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.price) AS merchandise_value,
        MAX(o.order_purchase_timestamp) AS last_order_at
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    orders,
    ROUND(merchandise_value,2) AS merchandise_value,
    last_order_at,
    DENSE_RANK() OVER (ORDER BY merchandise_value DESC) AS value_rank
FROM customer_value
ORDER BY merchandise_value DESC
LIMIT 50;

-- New vs returning customers by month
WITH customer_months AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
first_month AS (
    SELECT customer_unique_id, MIN(order_month) AS first_order_month
    FROM customer_months
    GROUP BY customer_unique_id
)
SELECT
    cm.order_month,
    COUNT(*) FILTER (WHERE cm.order_month = fm.first_order_month) AS new_customers,
    COUNT(*) FILTER (WHERE cm.order_month > fm.first_order_month) AS returning_customers
FROM customer_months cm
JOIN first_month fm USING (customer_unique_id)
GROUP BY cm.order_month
ORDER BY cm.order_month;
