WITH
no_orders AS (
  SELECT
    customer_id,
    count(DISTINCT order_id) AS no_orders,
    sum(
      round(cast((unit_price * quantity) * (1 - discount_perc) AS numeric), 2)
    ) AS sales_value,
    max(
      round(cast((unit_price * quantity) * (1 - discount_perc) AS numeric), 2)
    ) AS most_expensive_order
  FROM {{ ref('fct_sales') }}
  GROUP BY 1
),

top_ten_customers AS (
  SELECT customer_id
  FROM no_orders
  ORDER BY sales_value DESC
  LIMIT 10
)

SELECT
  customers.customer_id,
  customers.customer_name,
  customers.contact_title,
  customers.city,
  customers.region,
  customers.country,
  coalesce(orders.no_orders, 0) AS no_orders,
  coalesce(orders.most_expensive_order, 0) AS most_expensive_order,
  coalesce (top_ten.customer_id IS NOT null, FALSE) AS is_top_ten_customer
FROM {{ ref('stg_customers') }} AS customers
LEFT JOIN no_orders AS orders
  ON customers.customer_id = orders.customer_id
LEFT JOIN top_ten_customers AS top_ten
  ON customers.customer_id = top_ten.customer_id
