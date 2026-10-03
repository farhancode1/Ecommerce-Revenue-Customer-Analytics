-- 05_cohort_retention.sql
-- Acquisition cohort and customer-retention framework.

-- Steps:
-- 1. Find each customer's first purchase month.
-- 2. Assign that month as the acquisition cohort.
-- 3. Calculate the number of months between first purchase and each later purchase.
-- 4. Count active customers by cohort and cohort age.
-- 5. Divide by cohort size to calculate retention.

-- Expected output columns:
-- cohort_month
-- cohort_index
-- active_customers
-- cohort_size
-- retention_rate
