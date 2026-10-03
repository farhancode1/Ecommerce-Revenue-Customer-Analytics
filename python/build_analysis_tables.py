from pathlib import Path
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
OUT = ROOT / "data" / "processed"
OUT.mkdir(parents=True, exist_ok=True)

FILES = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "items": "olist_order_items_dataset.csv",
    "payments": "olist_order_payments_dataset.csv",
    "reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "translation": "product_category_name_translation.csv",
}

missing = [name for name in FILES.values() if not (RAW / name).exists()]
if missing:
    raise FileNotFoundError(
        "Missing raw files:\\n- " + "\\n- ".join(missing)
        + "\\nDownload the Olist Brazilian E-Commerce dataset and place these files in data/raw/."
    )

customers = pd.read_csv(RAW / FILES["customers"])
orders = pd.read_csv(RAW / FILES["orders"])
items = pd.read_csv(RAW / FILES["items"])
payments = pd.read_csv(RAW / FILES["payments"])
reviews = pd.read_csv(RAW / FILES["reviews"])
products = pd.read_csv(RAW / FILES["products"])
sellers = pd.read_csv(RAW / FILES["sellers"])
translation = pd.read_csv(RAW / FILES["translation"])

date_cols = [
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date",
]
for col in date_cols:
    orders[col] = pd.to_datetime(orders[col], errors="coerce")

# Use delivered orders as the completed transaction population.
delivered = orders.loc[orders["order_status"].eq("delivered")].copy()

# Item-level fact table.
fact = (
    delivered.merge(customers, on="customer_id", how="left")
    .merge(items, on="order_id", how="left")
    .merge(products, on="product_id", how="left")
    .merge(
        translation,
        on="product_category_name",
        how="left",
    )
)

fact["category"] = (
    fact["product_category_name_english"]
    .fillna(fact["product_category_name"])
    .fillna("unknown")
)
fact["order_month"] = fact["order_purchase_timestamp"].dt.to_period("M").dt.to_timestamp()
fact["is_late"] = (
    fact["order_delivered_customer_date"] > fact["order_estimated_delivery_date"]
)

# ------------------------------
# Overall KPI summary
# ------------------------------
order_merch = (
    fact.groupby("order_id", as_index=False)
    .agg(
        merchandise_revenue=("price", "sum"),
        freight_value=("freight_value", "sum"),
        customer_unique_id=("customer_unique_id", "first"),
        order_purchase_timestamp=("order_purchase_timestamp", "first"),
        customer_state=("customer_state", "first"),
        is_late=("is_late", "max"),
    )
)

summary = pd.DataFrame(
    {
        "metric": [
            "delivered_orders",
            "unique_customers",
            "merchandise_revenue",
            "freight_value",
            "average_order_value",
            "repeat_purchase_rate_pct",
            "late_delivery_rate_pct",
        ],
        "value": [
            order_merch["order_id"].nunique(),
            order_merch["customer_unique_id"].nunique(),
            order_merch["merchandise_revenue"].sum(),
            order_merch["freight_value"].sum(),
            order_merch["merchandise_revenue"].sum() / order_merch["order_id"].nunique(),
            100
            * (
                order_merch.groupby("customer_unique_id")["order_id"].nunique().gt(1).mean()
            ),
            100 * order_merch["is_late"].mean(),
        ],
    }
)
summary.to_csv(OUT / "kpi_summary.csv", index=False)

# ------------------------------
# Monthly KPIs
# ------------------------------
monthly = (
    fact.groupby("order_month", as_index=False)
    .agg(
        orders=("order_id", "nunique"),
        customers=("customer_unique_id", "nunique"),
        merchandise_revenue=("price", "sum"),
        freight_value=("freight_value", "sum"),
    )
    .sort_values("order_month")
)
monthly["average_order_value"] = monthly["merchandise_revenue"] / monthly["orders"]
monthly["mom_revenue_growth_pct"] = monthly["merchandise_revenue"].pct_change() * 100
monthly.to_csv(OUT / "monthly_kpis.csv", index=False)

# ------------------------------
# Category performance
# ------------------------------
category = (
    fact.groupby("category", as_index=False)
    .agg(
        orders=("order_id", "nunique"),
        items_sold=("order_item_id", "count"),
        merchandise_revenue=("price", "sum"),
        avg_item_price=("price", "mean"),
        freight_value=("freight_value", "sum"),
    )
    .sort_values("merchandise_revenue", ascending=False)
)
category.to_csv(OUT / "category_performance.csv", index=False)

# ------------------------------
# State performance
# ------------------------------
state = (
    fact.groupby("customer_state", as_index=False)
    .agg(
        orders=("order_id", "nunique"),
        customers=("customer_unique_id", "nunique"),
        merchandise_revenue=("price", "sum"),
    )
    .sort_values("merchandise_revenue", ascending=False)
)
state["average_order_value"] = state["merchandise_revenue"] / state["orders"]
state.to_csv(OUT / "state_performance.csv", index=False)

# ------------------------------
# Customer RFM
# ------------------------------
customer = (
    order_merch.groupby("customer_unique_id", as_index=False)
    .agg(
        last_order=("order_purchase_timestamp", "max"),
        frequency=("order_id", "nunique"),
        monetary=("merchandise_revenue", "sum"),
    )
)
snapshot = order_merch["order_purchase_timestamp"].max().normalize() + pd.Timedelta(days=1)
customer["recency_days"] = (snapshot - customer["last_order"].dt.normalize()).dt.days

# Rank-based scoring is robust to the heavily tied frequency distribution.
customer["r_score"] = pd.qcut(
    customer["recency_days"].rank(method="first", ascending=True),
    5,
    labels=[5, 4, 3, 2, 1],
).astype(int)
customer["f_score"] = pd.qcut(
    customer["frequency"].rank(method="first"),
    5,
    labels=[1, 2, 3, 4, 5],
).astype(int)
customer["m_score"] = pd.qcut(
    customer["monetary"].rank(method="first"),
    5,
    labels=[1, 2, 3, 4, 5],
).astype(int)

def segment(row):
    r, f, m = row["r_score"], row["f_score"], row["m_score"]
    if r >= 4 and f >= 4 and m >= 4:
        return "Champions"
    if r >= 3 and f >= 4:
        return "Loyal Customers"
    if r >= 4 and f <= 2:
        return "New / Promising"
    if r <= 2 and f >= 3:
        return "At Risk"
    if r <= 2 and f <= 2:
        return "Hibernating"
    return "Potential Loyalists"

customer["rfm_segment"] = customer.apply(segment, axis=1)
customer.to_csv(OUT / "rfm_customers.csv", index=False)

rfm_summary = (
    customer.groupby("rfm_segment", as_index=False)
    .agg(
        customers=("customer_unique_id", "nunique"),
        avg_recency_days=("recency_days", "mean"),
        avg_frequency=("frequency", "mean"),
        avg_monetary=("monetary", "mean"),
        total_merchandise_value=("monetary", "sum"),
    )
    .sort_values("total_merchandise_value", ascending=False)
)
rfm_summary.to_csv(OUT / "rfm_segment_summary.csv", index=False)

# ------------------------------
# Cohort retention
# ------------------------------
customer_months = (
    order_merch.assign(
        order_month=order_merch["order_purchase_timestamp"].dt.to_period("M").dt.to_timestamp()
    )[["customer_unique_id", "order_month"]]
    .drop_duplicates()
)
first_month = customer_months.groupby("customer_unique_id")["order_month"].min().rename("cohort_month")
cohort = customer_months.join(first_month, on="customer_unique_id")
cohort["cohort_index"] = (
    (cohort["order_month"].dt.year - cohort["cohort_month"].dt.year) * 12
    + (cohort["order_month"].dt.month - cohort["cohort_month"].dt.month)
)
cohort_counts = (
    cohort.groupby(["cohort_month", "cohort_index"])["customer_unique_id"]
    .nunique()
    .rename("active_customers")
    .reset_index()
)
cohort_sizes = (
    cohort_counts.loc[cohort_counts["cohort_index"].eq(0), ["cohort_month", "active_customers"]]
    .rename(columns={"active_customers": "cohort_size"})
)
cohort_retention = cohort_counts.merge(cohort_sizes, on="cohort_month", how="left")
cohort_retention["retention_rate_pct"] = (
    100 * cohort_retention["active_customers"] / cohort_retention["cohort_size"]
)
cohort_retention.to_csv(OUT / "cohort_retention.csv", index=False)

# ------------------------------
# Payment mix
# ------------------------------
payment_mix = (
    payments.merge(delivered[["order_id"]], on="order_id", how="inner")
    .groupby("payment_type", as_index=False)
    .agg(
        payment_records=("order_id", "size"),
        orders=("order_id", "nunique"),
        payment_value=("payment_value", "sum"),
    )
    .sort_values("payment_value", ascending=False)
)
payment_mix.to_csv(OUT / "payment_mix.csv", index=False)

# ------------------------------
# Delivery + reviews
# ------------------------------
order_service = (
    delivered[[
        "order_id",
        "order_purchase_timestamp",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ]]
    .copy()
)
order_service["delivery_days"] = (
    order_service["order_delivered_customer_date"] - order_service["order_purchase_timestamp"]
).dt.total_seconds() / 86400
order_service["is_late"] = (
    order_service["order_delivered_customer_date"] > order_service["order_estimated_delivery_date"]
)
review_one = (
    reviews.sort_values("review_answer_timestamp")
    .drop_duplicates("order_id", keep="last")[["order_id", "review_score"]]
)
order_service = order_service.merge(review_one, on="order_id", how="left")
order_service.to_csv(OUT / "delivery_review_analysis.csv", index=False)

print("Created analysis tables in:", OUT)
for path in sorted(OUT.glob("*.csv")):
    print(" -", path.name)
