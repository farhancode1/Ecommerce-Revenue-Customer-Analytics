-- 04_product_analysis.sql
-- Product/category contribution and commercial performance.

-- Planned analyses:
-- 1. Revenue by category
-- 2. Orders by category
-- 3. Average selling price
-- 4. Product/category rank using window functions
-- 5. Revenue concentration (top products vs long tail)
-- 6. Discount impact if discount data is available
-- 7. Profit/margin analysis if cost data is available

-- Example ranking pattern:
-- SELECT
--   category,
--   SUM(revenue) AS revenue,
--   RANK() OVER (ORDER BY SUM(revenue) DESC) AS revenue_rank
-- FROM fact_order_items
-- GROUP BY category;
