WITH source AS (

  SELECT * FROM {{ source('staging', 'order_details') }}

),

renamed AS (

  SELECT
    orderid::varchar AS order_id,
    productid::varchar AS product_id,
    unitprice AS unit_price,
    quantity AS quantity,
    discount AS discount

  FROM source

)

SELECT * FROM renamed
