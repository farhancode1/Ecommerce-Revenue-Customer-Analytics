-- 04_product_analysis.sql
-- Product and category performance.

WITH category_sales AS (
    SELECT
        COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(*) AS items_sold,
        SUM(oi.price) AS merchandise_revenue,
        AVG(oi.price) AS avg_item_price,
        SUM(oi.freight_value) AS freight_value
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    LEFT JOIN products p ON p.product_id = oi.product_id
    LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT
    category,
    orders,
    items_sold,
    ROUND(merchandise_revenue,2) AS merchandise_revenue,
    ROUND(avg_item_price,2) AS avg_item_price,
    ROUND(freight_value,2) AS freight_value,
    RANK() OVER (ORDER BY merchandise_revenue DESC) AS revenue_rank
FROM category_sales
ORDER BY merchandise_revenue DESC;

-- Top products by merchandise revenue
SELECT
    oi.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price),2) AS merchandise_revenue,
    ROUND(AVG(oi.price),2) AS avg_item_price
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id, category
ORDER BY merchandise_revenue DESC
LIMIT 50;

-- Delivery and review quality by category
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(AVG(r.review_score)::numeric,2) AS avg_review_score,
    ROUND(100.0 * COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) / NULLIF(COUNT(DISTINCT o.order_id),0), 2) AS late_delivery_rate_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
LEFT JOIN order_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY category
HAVING COUNT(DISTINCT o.order_id) >= 100
ORDER BY avg_review_score ASC NULLS LAST;
