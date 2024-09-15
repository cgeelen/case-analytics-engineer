WITH
    reporting_months AS (
        select distinct reporting_month
        FROM {{ ref('dim_dates') }}
    )

, first_order_value as (
    select
        customer_id,
        date_trunc('month', first_purchase_date) AS first_purchase_month,
        (unit_price * quantity) * (1-discount) AS first_purchase_value
    from {{ ref('fct_sales') }}
    where first_purchase_date = order_date
)

select
    coalesce(orders.first_purchase_month,months.reporting_month) as reporting_month,
    customers.country,
    sum(orders.first_purchase_value) as sales_value,
    count(orders.customer_id) as no_customers
from reporting_months as months
full outer join first_order_value as orders
    on months.reporting_month = orders.first_purchase_month
left join {{ ref('dim_customers') }} as customers
    on orders.customer_id = orders.customer_id
group by 1,2
