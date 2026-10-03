# Olist Data Dictionary

## customers

- `customer_id` — order-level customer key used by `orders`
- `customer_unique_id` — persistent customer identifier used for retention/RFM
- `customer_zip_code_prefix`
- `customer_city`
- `customer_state`

## orders

- `order_id`
- `customer_id`
- `order_status`
- `order_purchase_timestamp`
- `order_approved_at`
- `order_delivered_carrier_date`
- `order_delivered_customer_date`
- `order_estimated_delivery_date`

## order_items

- `order_id`
- `order_item_id`
- `product_id`
- `seller_id`
- `shipping_limit_date`
- `price`
- `freight_value`

## order_payments

- `order_id`
- `payment_sequential`
- `payment_type`
- `payment_installments`
- `payment_value`

## order_reviews

- `review_id`
- `order_id`
- `review_score`
- `review_comment_title`
- `review_comment_message`
- `review_creation_date`
- `review_answer_timestamp`

## products

- `product_id`
- `product_category_name`
- `product_name_lenght`
- `product_description_lenght`
- `product_photos_qty`
- `product_weight_g`
- `product_length_cm`
- `product_height_cm`
- `product_width_cm`

## sellers

- `seller_id`
- `seller_zip_code_prefix`
- `seller_city`
- `seller_state`

## category_translation

- `product_category_name`
- `product_category_name_english`
