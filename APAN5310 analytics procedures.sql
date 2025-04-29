-- Question 1:How can we assess monthly sales performance across multiple retail stores, identify underperformance periods, and evaluate whether sales are meeting, exceeding, or falling short of predefined goals over time?

--Average of Order Total by Order Date: Month
SELECT
  CAST(
    DATE_TRUNC('month', "public"."orders"."order_date") AS date
  ) AS "order_date",
  AVG("public"."orders"."order_total") AS "avg"
FROM
  "public"."orders"
WHERE
  (
    ("public"."orders"."store_id" = '201')
    OR ("public"."orders"."store_id" = '202')
    OR ("public"."orders"."store_id" = '203')
  )
  AND (
    (LOWER("public"."orders"."store_id") LIKE '%201%')
    OR (LOWER("public"."orders"."store_id") LIKE '%202%')
    OR (LOWER("public"."orders"."store_id") LIKE '%203%')
  )
GROUP BY
  CAST(
    DATE_TRUNC('month', "public"."orders"."order_date") AS date
  )
ORDER BY
  CAST(
    DATE_TRUNC('month', "public"."orders"."order_date") AS date
  ) ASC

--Overall sell by store
SELECT
  "public"."orders"."store_id" AS "store_id",
  SUM("public"."orders"."order_total") AS "sum"
FROM
  "public"."orders"
GROUP BY
  "public"."orders"."store_id"
ORDER BY
  "public"."orders"."store_id" ASC


-- Question 2:Compare revenue between Walk-in and Delivery orders & sales in product level

-- Compare revenue between Walk-in and Delivery orders 
SELECT
  "public"."orders"."order_type" AS "order_type",
  SUM("public"."orders"."order_total") AS "sum"
FROM
  "public"."orders"
GROUP BY
  "public"."orders"."order_type"
ORDER BY
  "public"."orders"."order_type" ASC

Purchase Distribution by Product Category
SELECT
  "source"."products__via__product_id__category" AS "products__via__product_id__category",
  "source"."count" AS "count"
FROM
  (
    SELECT
      "products__via__product_id"."category" AS "products__via__product_id__category",
      COUNT(*) AS "count"
    FROM
      "public"."order_items"
     
LEFT JOIN "public"."products" AS "products__via__product_id" ON "public"."order_items"."product_id" = "products__via__product_id"."product_id"
   
GROUP BY
      "products__via__product_id"."category"
   
ORDER BY
      "products__via__product_id"."category" ASC
  ) AS "source"
LIMIT
  1048575


-- Revenue Contribution by Product Category
SELECT
  "products__via__product_id"."category" AS "products__via__product_id__category",
  SUM(
    "public"."order_items"."quantity" * "public"."order_items"."unit_price"
  ) AS "Revenue"
FROM
  "public"."order_items"
 
LEFT JOIN "public"."products" AS "products__via__product_id" ON "public"."order_items"."product_id" = "products__via__product_id"."product_id"
GROUP BY
  "products__via__product_id"."category"
ORDER BY
  "products__via__product_id"."category" ASC

-- Question 3:What are the top 5 products contributing most to revenue?
SELECT
  "products__via__product_id"."product_name" AS "products__via__product_id__product_name",
  SUM(
    "public"."order_items"."quantity" * "public"."order_items"."unit_price"
  ) AS "Revenue"
FROM
  "public"."order_items"
 
LEFT JOIN "public"."products" AS "products__via__product_id" ON "public"."order_items"."product_id" = "products__via__product_id"."product_id"
GROUP BY
  "products__via__product_id"."product_name"
ORDER BY
  "Revenue" DESC,
  "products__via__product_id"."product_name" ASC
LIMIT
  5
  

-- Question 4:How can we analyze sales performance at the product and category levels to identify high-impact items, optimize inventory planning, and inform strategic decisions regarding promotions and pricing?

--Marketing Performance:accumulative conversion through time
SELECT
  "source"."target_audience" AS "target_audience",
  "source"."date" AS "date",
  "source"."channel" AS "channel",
  SUM(SUM("source"."conversions")) OVER (
    PARTITION BY "source"."target_audience",
    "source"."channel"
   
ORDER BY
      "source"."target_audience" ASC,
      "source"."channel" ASC,
      "source"."date" ASC ROWS UNBOUNDED PRECEDING
  ) AS "sum"
FROM
  (
    SELECT
      "public"."marketing_performance"."target_audience" AS "target_audience",
      CAST(
        DATE_TRUNC('month', "public"."marketing_performance"."date") AS date
      ) AS "date",
      "public"."marketing_performance"."channel" AS "channel",
      "public"."marketing_performance"."conversions" AS "conversions"
    FROM
      "public"."marketing_performance"
   
WHERE
      (
        (
          "public"."marketing_performance"."target_audience" = 'Inactive'
        )
       
    OR (
          "public"."marketing_performance"."target_audience" = 'New Users'
        )
        OR (
          "public"."marketing_performance"."target_audience" = 'Premium'
        )
      )
     
   AND (
        ("public"."marketing_performance"."channel" = 'App')
        OR (
          "public"."marketing_performance"."channel" = 'Social Media'
        )
        OR ("public"."marketing_performance"."channel" = 'SMS')
        OR (
          "public"."marketing_performance"."channel" = 'Email'
        )
      )
  ) AS "source"
GROUP BY
  "source"."target_audience",
  "source"."date",
  "source"."channel"
ORDER BY
  "source"."target_audience" ASC,
  "source"."channel" ASC,
  "source"."date" ASC

-- Conversion rate by Channel and Target Audience
SELECT
  "public"."marketing_performance"."channel" AS "channel",
  "public"."marketing_performance"."target_audience" AS "target_audience",
  CAST(
    SUM("public"."marketing_performance"."conversions") AS float
  ) / NULLIF(SUM("public"."marketing_performance"."clicks"), 0) AS "Conversion rate"
FROM
  "public"."marketing_performance"
GROUP BY
  "public"."marketing_performance"."channel",
  "public"."marketing_performance"."target_audience"
ORDER BY
  "public"."marketing_performance"."channel" ASC,
  "public"."marketing_performance"."target_audience" ASC
  
-- ROI by Channel and Target Audience
SELECT
  "public"."marketing_performance"."channel" AS "channel",
  "public"."marketing_performance"."target_audience" AS "target_audience",
  CAST(
    SUM(
      "public"."marketing_performance"."revenue_generated"
    ) AS float
  ) / NULLIF(SUM("public"."marketing_performance"."spend"), 0) AS "ROI"
FROM
  "public"."marketing_performance"
GROUP BY
  "public"."marketing_performance"."channel",
  "public"."marketing_performance"."target_audience"
ORDER BY
  "public"."marketing_performance"."channel" ASC,
  "public"."marketing_performance"."target_audience" ASC
  

-- Question 5:Customers: How Can We Identify Customers with Low Average Spend but High Purchase Frequency?
SELECT 
  total_orders,
  AVG(avg_order_value) AS avg_order_value
FROM customers
WHERE total_orders > 10
  AND avg_order_value < 1000.83
GROUP BY total_orders
ORDER BY total_orders;

-- Question 6:Customers: How Can We Identify the Most Valuable Customers to Drive Revenue Growth?
SELECT
  customer_id,
  customer_name,
  total_orders,
  avg_order_value,
  total_orders * avg_order_value AS total_spent
FROM customers
ORDER BY total_orders * avg_order_value DESC
LIMIT 10;
  
-- Question 7:Customers: How Can We Identify Customers with the Highest Average Transaction Value?
SELECT
  customer_id,
  customer_name,
  avg_order_value,
  total_orders,
  total_orders * avg_order_value AS total_spent
FROM customers
ORDER BY avg_order_value DESC
LIMIT 10;

-- Question 8:Supply Chain: How Can We Identify the Most Reliable and Risky Suppliers?
  
SELECT
  "public"."vendor_deliveries"."vendor_id" AS "vendor_id",
  CAST(
    100 * SUM(
      CASE
        WHEN "public"."vendor_deliveries"."delivery_status" = 'Delivered' THEN 1
        ELSE 0.0
      END
    ) AS float
  ) / NULLIF(COUNT(*), 0) AS "On-Time Rate",
  COUNT(*) AS "count"
FROM
  "public"."vendor_deliveries"
 
LEFT JOIN "public"."vendors" AS "Vendors" ON "public"."vendor_deliveries"."vendor_id" = "Vendors"."vendor_id"
GROUP BY
  "public"."vendor_deliveries"."vendor_id"
ORDER BY
  "public"."vendor_deliveries"."vendor_id" ASC
  
-- Question 9:Supply Chain: How Can We Detect Store-Level Delivery Challenges?
SELECT
  "public"."vendor_deliveries"."delivery_status" AS "delivery_status",
  "public"."vendor_deliveries"."store_id" AS "store_id",
  COUNT(*) AS "count"
FROM
  "public"."vendor_deliveries"
GROUP BY
  "public"."vendor_deliveries"."delivery_status",
  "public"."vendor_deliveries"."store_id"
ORDER BY
  "public"."vendor_deliveries"."delivery_status" ASC,
  "public"."vendor_deliveries"."store_id" ASC

-- Question 10:Supply Chain: How Can We Detect Product Shelf Life Risk and Delivery Delays?
/*
    bp.price,                                        x axis：price
    bp.shelf_life_days,                              y axis：保质期
    COUNT(vd.vendor_delivery_id) AS delay_count      bubble size,delay count */
FROM
    blinkit_products bp
JOIN
    vendor_deliveries_simulated vd
ON
    bp.product_id = vd.product_id
WHERE bp.shelf_life_days <30
  AND vd.delivery_status = 'Delayed' 
GROUP BY
    bp.price,
    bp.shelf_life_days
ORDER BY
    bp.price ASC, bp.shelf_life_days ASC;