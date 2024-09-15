WITH
reporting_months AS (
  SELECT DISTINCT month_start_date
  FROM {{ ref('dim_dates') }}
),

customers AS (
  SELECT
    customer_id,
    country
  FROM {{ ref('dim_customers') }}
),

-- Creates all dimension combinations
dimensions AS (
  SELECT
    reporting_months.month_start_date,
    countries.country
  FROM reporting_months
  CROSS JOIN (
    SELECT DISTINCT country
    FROM customers
  ) AS countries
),


first_order_value AS (
  SELECT
    customers.country,
    date_trunc('month', order_date)::date AS first_purchase_month,
    sum(round(((unit_price * quantity) * (1 - discount_perc))::numeric, 2))
      AS first_purchase_value,
    count(DISTINCT sales.customer_id) AS no_customers
  FROM {{ ref('fct_sales') }} AS sales
  LEFT JOIN customers
    ON sales.customer_id = customers.customer_id
  WHERE sales.is_repeat_customer = false
  GROUP BY 1, 2
),

final AS (
  SELECT
    coalesce(orders.first_purchase_month, dimensions.month_start_date)
      AS cohort_month,
    coalesce(orders.country, dimensions.country) AS country,
    coalesce(first_purchase_value, 0) AS sales_value,
    coalesce(no_customers, 0) AS no_customers
  FROM dimensions
  FULL OUTER JOIN first_order_value AS orders
    ON
      dimensions.month_start_date = orders.first_purchase_month
      AND dimensions.country = orders.country
)

SELECT
  {{ dbt_utils.generate_surrogate_key([
      'cohort_month',
      'country'
  ])}} AS sk_customer_cohort_id,
  cohort_month,
  country,
  sales_value,
  no_customers
FROM final
