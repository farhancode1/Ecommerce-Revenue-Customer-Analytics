# E-commerce Revenue & Customer Analytics

An end-to-end **data analytics portfolio project** focused on revenue performance, customer behaviour, retention, product performance, and management decision-making.

> **Project status:** structure and analysis framework created. Quantitative findings will be added only after the dataset is loaded and validated.

## Business Objective

The goal is to help an e-commerce management team understand:

- How revenue, orders, customers, and average order value change over time
- Which products/categories contribute most to sales and profit
- Which customers create the most value
- How new and returning customers behave differently
- Whether discounting is associated with stronger or weaker commercial performance
- How customer retention changes by acquisition cohort
- Which customers can be grouped into actionable RFM segments
- Where management should focus to improve retention and commercial performance

## Skills Demonstrated

`SQL` · `Python` · `Pandas` · `Data Cleaning` · `EDA` · `Power BI` · `Excel` · `KPI Design` · `Cohort Analysis` · `RFM Segmentation` · `Business Storytelling`

## Planned KPI Layer

| KPI | Definition |
|---|---|
| Revenue | Total completed-order sales value |
| Orders | Distinct completed orders |
| Customers | Distinct purchasing customers |
| Average Order Value | Revenue / Orders |
| Revenue Growth | Period-over-period revenue change |
| Repeat Purchase Rate | Share of customers with more than one order |
| Customer Lifetime Value Proxy | Historical revenue per customer |
| Retention Rate | Customers returning in later cohort periods |
| Category Contribution | Share of revenue/orders by category |
| RFM Segment | Customer group based on recency, frequency, and monetary value |

## Repository Structure

```text
Ecommerce-Revenue-Customer-Analytics/
├── data/
│   ├── raw/
│   └── processed/
├── sql/
│   ├── 01_data_quality.sql
│   ├── 02_sales_kpis.sql
│   ├── 03_customer_analysis.sql
│   ├── 04_product_analysis.sql
│   ├── 05_cohort_retention.sql
│   └── 06_rfm_segmentation.sql
├── python/
│   ├── README.md
│   └── ecommerce_analysis.ipynb
├── powerbi/
├── excel/
├── images/
├── business_report/
├── docs/
│   └── project_brief.md
├── .gitignore
├── LICENSE
└── README.md
```

## Analysis Workflow

1. **Data ingestion & validation**
   - Inspect schema and data types
   - Check duplicates and missing values
   - Validate order/customer/product keys
   - Identify cancelled or incomplete transactions

2. **SQL analysis**
   - Build core KPIs
   - Monthly trend analysis
   - Customer analysis
   - Product/category analysis
   - Cohort retention
   - RFM segmentation

3. **Python analysis**
   - Data cleaning checks
   - Exploratory data analysis
   - Outlier inspection
   - Visual analysis
   - Export analysis-ready tables

4. **Power BI dashboard**
   - Executive Overview
   - Sales & Product Performance
   - Customer Analytics
   - Retention & Cohort Analysis

5. **Executive summary**
   - Translate analysis into concise management recommendations

## Business Questions

1. What are the monthly trends in revenue, orders, customers, and AOV?
2. Which categories and products generate the highest commercial value?
3. Which regions or customer groups underperform?
4. What percentage of customers purchase more than once?
5. Which customers are high-value, loyal, new, or at risk?
6. How does retention change across customer acquisition cohorts?
7. Where are the biggest opportunities to improve revenue or retention?

## Important Portfolio Principle

This repository will **not invent performance numbers or business conclusions**. Results, charts, and recommendations will be added only after the underlying data has been processed and analysed.

## Author

**Mohd Farhan**  
AI/ML & Data Analytics Portfolio
