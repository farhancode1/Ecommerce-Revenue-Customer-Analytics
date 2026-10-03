-- 06_rfm_segmentation.sql
-- RFM customer segmentation using customer_unique_id.
-- Frequency is intentionally scored with business rules rather than NTILE because
-- most Olist customers purchased only once; quantile-splitting tied frequency=1
-- would create misleading differences between otherwise identical customers.

WITH snapshot AS (
    SELECT MAX(order_purchase_timestamp)::date + INTERVAL '1 day' AS snapshot_date
    FROM orders
    WHERE order_status = 'delivered'
),
rfm_base AS (
    SELECT
        c.customer_unique_id,
        (SELECT snapshot_date FROM snapshot) - MAX(o.order_purchase_timestamp)::date AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price) AS monetary
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
recency_monetary_scores AS (
    SELECT
        *,
        6 - NTILE(5) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
),
scored AS (
    SELECT
        *,
        CASE
            WHEN frequency >= 3 THEN 5
            WHEN frequency = 2 THEN 3
            ELSE 1
        END AS f_score
    FROM recency_monetary_scores
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN r_score >= 4 AND f_score >= 3 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score = 1 THEN 'New / Promising'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score = 1 THEN 'Hibernating'
            ELSE 'Potential Loyalists'
        END AS rfm_segment
    FROM scored
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    ROUND(monetary,2) AS monetary,
    r_score,
    f_score,
    m_score,
    rfm_segment
FROM segmented
ORDER BY monetary DESC;
