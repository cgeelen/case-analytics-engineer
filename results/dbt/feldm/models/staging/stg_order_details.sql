WITH source AS (

  SELECT * FROM {{ source('staging', 'order_details') }}

),

renamed AS (

  SELECT
    orderid AS order_id,
    productid AS productid,
    unitprice AS unit_price,
    quantity AS quantity,
    discount AS discount

  FROM source

)

SELECT * FROM renamed
