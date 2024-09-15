WITH
    no_orders as (
        select
            customer_id
            ,count(distinct order_id) as no_orders
            ,sum(
                (unit_price * quantity) * (1-discount)
            ) as revenue
        from {{ ref('fct_sales') }}
        group by 1
    )

    ,top_ten_customers AS (
        select customer_id
        from no_orders
        order by revenue desc
        limit 10
    )

select
    customers.customer_id,
    customers.company_name,
    customers.contact_title,
    customers.city,
    customers.region,
    customers.country,
    orders.no_orders,
    case
        when top_ten.customer_id is not null
            then true
        else false
    end AS is_top_ten_customer
from {{ ref('stg_customers') }} as customers
left join no_orders as orders
    on customers.customer_id = orders.customer_id
left join top_ten_customers as top_ten
    on customers.customer_id = top_ten.customer_id
