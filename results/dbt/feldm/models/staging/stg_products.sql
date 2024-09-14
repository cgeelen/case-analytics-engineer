WITH source AS (

  SELECT * FROM {{ source('staging', 'products') }}

),

renamed AS (

  SELECT
    productid::varchar AS product_id,
    productname AS product_name,
    categoryid AS category_id,
    quantityperunit AS quantity_per_unit,
    unitprice AS unit_price,
    unitsinstock AS is_in_stock,
    unitsonorder AS is_on_order,
    reorderlevel AS reorder_level,
    discontinued = 1 AS is_discontinued

  FROM source

)

SELECT * FROM renamed
