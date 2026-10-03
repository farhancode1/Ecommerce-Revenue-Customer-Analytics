-- 01_data_quality.sql
-- Purpose: validate the dataset before KPI analysis.
-- Replace table/column names after the final dataset is loaded.

-- 1. Row counts
-- SELECT COUNT(*) FROM orders;

-- 2. Duplicate order IDs
-- SELECT order_id, COUNT(*) AS n
-- FROM orders
-- GROUP BY order_id
-- HAVING COUNT(*) > 1;

-- 3. Missing critical fields
-- SELECT
--   SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
--   SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id
-- FROM orders;

-- 4. Invalid dates / future dates
-- 5. Negative or zero values
-- 6. Orphaned foreign keys
-- 7. Cancelled/incomplete order status review
