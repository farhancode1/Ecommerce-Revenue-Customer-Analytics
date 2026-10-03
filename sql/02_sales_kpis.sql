-- 02_sales_kpis.sql
-- Revenue, orders, customers, AOV and monthly growth.
-- Revenue is defined as item merchandise price, excluding freight.

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(DISTINCT c.customer_unique_id) AS customers,
        SUM(oi.price) AS merchandise_revenue,
        SUM(oi.freight_value) AS freight_value
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
),
with_growth AS (
    SELECT
        *,
        merchandise_revenue / NULLIF(orders, 0) AS average_order_value,
        LAG(merchandise_revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly
)
SELECT
    month,
    orders,
    customers,
    ROUND(merchandise_revenue, 2) AS merchandise_revenue,
    ROUND(freight_value, 2) AS freight_value,
    ROUND(average_order_value, 2) AS average_order_value,
    ROUND(
        100.0 * (merchandise_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0), 2
    ) AS mom_revenue_growth_pct
FROM with_growth
ORDER BY month;

-- Overall KPIs
SELECT
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(oi.price), 2) AS merchandise_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_value,
    ROUND(SUM(oi.price) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS average_order_value
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- State performance
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(SUM(oi.price), 2) AS merchandise_revenue,
    ROUND(SUM(oi.price) / NULLIF(COUNT(DISTINCT o.order_id),0), 2) AS aov
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY merchandise_revenue DESC;

-- Payment method mix (all payment rows attached to delivered orders)
SELECT
    p.payment_type,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT p.order_id) AS orders_using_payment_type,
    ROUND(SUM(p.payment_value), 2) AS payment_value
FROM order_payments p
JOIN orders o ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY payment_value DESC;
