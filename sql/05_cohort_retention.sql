-- 05_cohort_retention.sql
-- Monthly customer acquisition cohorts using customer_unique_id.

WITH customer_orders AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
cohorts AS (
    SELECT
        customer_unique_id,
        MIN(order_month) AS cohort_month
    FROM customer_orders
    GROUP BY customer_unique_id
),
activity AS (
    SELECT
        co.customer_unique_id,
        c.cohort_month,
        co.order_month,
        (
            EXTRACT(YEAR FROM AGE(co.order_month, c.cohort_month)) * 12
            + EXTRACT(MONTH FROM AGE(co.order_month, c.cohort_month))
        )::int AS cohort_index
    FROM customer_orders co
    JOIN cohorts c USING (customer_unique_id)
),
cohort_counts AS (
    SELECT
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM activity
    GROUP BY cohort_month, cohort_index
),
cohort_sizes AS (
    SELECT
        cohort_month,
        active_customers AS cohort_size
    FROM cohort_counts
    WHERE cohort_index = 0
)
SELECT
    cc.cohort_month,
    cc.cohort_index,
    cc.active_customers,
    cs.cohort_size,
    ROUND(100.0 * cc.active_customers / NULLIF(cs.cohort_size,0), 2) AS retention_rate_pct
FROM cohort_counts cc
JOIN cohort_sizes cs USING (cohort_month)
ORDER BY cc.cohort_month, cc.cohort_index;
