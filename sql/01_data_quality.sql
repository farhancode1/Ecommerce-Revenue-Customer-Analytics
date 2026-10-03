-- 01_data_quality.sql
-- Data quality checks for the Olist schema.

-- Row counts
SELECT 'customers' AS table_name, COUNT(*) AS rows FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers;

-- Duplicate business keys
SELECT order_id, COUNT(*) AS n
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT customer_id, COUNT(*) AS n
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Missing critical order fields
SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS missing_purchase_timestamp,
    COUNT(*) FILTER (WHERE order_status IS NULL) AS missing_status
FROM orders;

-- Order status distribution
SELECT order_status, COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- Delivered orders without a delivery timestamp
SELECT COUNT(*) AS delivered_missing_delivery_timestamp
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- Invalid monetary values
SELECT
    COUNT(*) FILTER (WHERE price < 0) AS negative_price_rows,
    COUNT(*) FILTER (WHERE freight_value < 0) AS negative_freight_rows,
    COUNT(*) FILTER (WHERE price IS NULL) AS missing_price_rows
FROM order_items;

-- Orders referenced by items but missing from orders
SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o USING (order_id)
WHERE o.order_id IS NULL;

-- Customer IDs referenced by orders but missing from customers
SELECT COUNT(*) AS orphan_order_customers
FROM orders o
LEFT JOIN customers c USING (customer_id)
WHERE c.customer_id IS NULL;

-- Product IDs referenced by items but missing from products
SELECT COUNT(*) AS orphan_products
FROM order_items oi
LEFT JOIN products p USING (product_id)
WHERE p.product_id IS NULL;
