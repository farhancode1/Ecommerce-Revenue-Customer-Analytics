# Analysis Results

These results were calculated from the uploaded Olist CSV files using delivered orders as the completed transaction population.

## Executive KPIs

| KPI | Result |
|---|---:|
| Delivered orders | 96,478 |
| Unique customers | 93,358 |
| Merchandise revenue | R$13.22M |
| Freight value | R$2.20M |
| Average order value | R$137.04 |
| Repeat customers | 2,801 |
| Repeat purchase rate | 3.00% |
| Late delivery rate | 8.11% |

## Key Findings

### 1. Retention is the clearest commercial opportunity

Only **3.00%** of unique customers made more than one delivered purchase. The dataset is therefore dominated by one-time buyers. This makes post-purchase retention, reactivation, and second-order conversion a more important analytical opportunity than simply identifying high-frequency customers.

### 2. Late delivery is strongly associated with lower review scores

On-time deliveries received an average review score of **4.29**, compared with **2.57** for late deliveries. Among late deliveries, **46.21%** received a one-star review, versus only **6.59%** for on-time deliveries.

This is an association rather than proof of causality, but the size of the difference makes delivery reliability an important operational KPI to monitor.

### 3. Like-for-like growth was strong

Comparing **January–August 2018** with **January–August 2017**, merchandise revenue increased by approximately **141.1%** and delivered orders increased by approximately **139.9%**.

The dataset ends in August 2018, so full-year 2018 should not be compared directly with full-year 2017.

### 4. Revenue is concentrated in a small set of categories

The top three categories — **health & beauty**, **watches & gifts**, and **bed, bath & table** — generated approximately **25.9%** of merchandise revenue. Health & beauty alone generated about **R$1.23M**.

### 5. São Paulo dominates geographic revenue

Customers in **São Paulo (SP)** generated about **R$5.07M**, representing approximately **38.3%** of merchandise revenue. Rio de Janeiro and Minas Gerais were the next-largest states.

### 6. Credit cards dominate payment value

Credit-card transactions represented approximately **78.5%** of total recorded payment value among delivered orders.

## Management Recommendations

1. **Prioritise second-purchase conversion.** Build customer journeys that target the first 30–90 days after purchase, because repeat purchasing is rare.
2. **Treat late delivery as a customer-experience KPI.** Segment late-delivery rate by seller, category, state, and carrier-related timing to identify operational hotspots.
3. **Protect top-category availability while monitoring concentration risk.** The top categories contribute a meaningful share of revenue, so stock and seller performance in these categories deserve focused monitoring.
4. **Use geographic benchmarking rather than one national average.** SP dominates total revenue, while some smaller states have higher average order values; compare acquisition, freight, and service metrics by state.
5. **Design payment analysis around credit-card behaviour.** Credit cards dominate payment value, making installment behaviour and payment failure patterns useful next-step analyses if additional data becomes available.

## Methodological Notes

- Customer-level analysis uses `customer_unique_id`, not `customer_id`.
- Revenue means merchandise item price and excludes freight.
- The late-delivery rate excludes delivered orders with missing delivery timestamps.
- RFM frequency scoring is rule-based because more than 90,000 customers purchased only once; splitting tied frequency values into quantiles would be misleading.
- Historical marketplace data should not be interpreted as current Brazilian e-commerce performance.
