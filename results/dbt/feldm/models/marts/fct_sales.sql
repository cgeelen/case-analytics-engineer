{{
  config(
    materialized = 'incremental',
    unique_key = 'sk_order_id'
    )
}}

WITH

orders AS (
    SELECT
        order_id,
        customer_id,
        employee_id,
        shipper_id,
        order_date,
        required_date,
        shipped_date,
        freight
    FROM {{ ref('stg_orders') }}

    {% if is_incremental() %}

      -- Add overlap to ensure late-coming data is still captured on an incremental run
      WHERE order_date >= coalesce(
        (select max(order_date) from {{ this }}) - interval '7 day',
        '1900-01-01'
        )

    {% endif %}

),

order_details AS (
    SELECT
        order_id,
        product_id,
        unit_price,
        quantity,
        discount_perc
    FROM {{ ref('stg_order_details') }}

    {% if is_incremental() %}

      WHERE order_id in (SELECT order_id from orders)

    {% endif %}

),

repeat_customers AS (
    SELECT
        customer_id,
        min(order_date) AS first_purchase_date
    FROM orders
    GROUP BY 1
),

final AS (
    SELECT
        orders.order_id,
        orders.customer_id,
        orders.employee_id,
        orders.shipper_id,
        orders.order_date,
        orders.required_date,
        orders.shipped_date,
        orders.freight,
        order_details.product_id,
        order_details.unit_price,
        order_details.quantity,
        order_details.discount_perc,
        coalesce(orders.order_date > repeat_customers.first_purchase_date, false) AS is_repeat_customer,
        coalesce(order_date::date - repeat_customers.first_purchase_date::date, 0) AS days_between_first_last_order
    FROM orders
    LEFT JOIN order_details
        ON orders.order_id = order_details.order_id
    LEFT JOIN repeat_customers
        ON orders.customer_id = repeat_customers.customer_id

)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'order_id',
        'product_id'
    ])}} AS sk_order_id,
    order_id,
    customer_id,
    employee_id,
    shipper_id,
    product_id,
    order_date,
    required_date,
    shipped_date,
    freight,
    unit_price,
    quantity,
    discount_perc,
    is_repeat_customer,
    days_between_first_last_order
FROM final
