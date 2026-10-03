# Power BI Measures

Suggested DAX measures after loading the processed tables.

```DAX
Merchandise Revenue = SUM(monthly_kpis[merchandise_revenue])

Orders = SUM(monthly_kpis[orders])

Customers = SUM(monthly_kpis[customers])

Average Order Value = DIVIDE([Merchandise Revenue], [Orders])

Freight Value = SUM(monthly_kpis[freight_value])

Revenue MoM % =
VAR CurrentRevenue = [Merchandise Revenue]
VAR PreviousRevenue = CALCULATE([Merchandise Revenue], DATEADD('Date'[Date], -1, MONTH))
RETURN DIVIDE(CurrentRevenue - PreviousRevenue, PreviousRevenue)
```

Recommended dashboard pages:

1. Executive Overview
2. Product & State Performance
3. Customer & RFM Analysis
4. Retention, Delivery & Reviews
