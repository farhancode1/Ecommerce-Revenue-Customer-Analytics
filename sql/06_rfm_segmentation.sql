-- 06_rfm_segmentation.sql
-- Recency-Frequency-Monetary customer segmentation.

-- Definitions:
-- Recency  = days since most recent completed purchase
-- Frequency = number of completed orders
-- Monetary  = total historical revenue

-- Planned process:
-- 1. Calculate R, F, and M per customer.
-- 2. Use NTILE(5) or percentile-based scoring.
-- 3. Combine scores into interpretable segments.

-- Example segments:
-- Champions
-- Loyal Customers
-- Potential Loyalists
-- New Customers
-- At Risk
-- Hibernating
