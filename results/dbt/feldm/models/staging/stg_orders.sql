WITH source AS (

  SELECT * FROM {{ source('staging', 'orders') }}

),

renamed AS (

  SELECT
    orderid AS order_id,
    customerid AS customer_id,
    employeeid AS employee_id,
    orderdate AS order_date,
    requireddate AS required_date,
    shippeddate AS shipped_date,
    shipvia AS ship_via,
    freight AS freight,
    shipname AS ship_name,
    shipaddress AS ship_address,
    shipcity AS city,
    shipregion AS region,
    shippostalcode AS postal_code,
    shipcountry AS country

  FROM source

)

SELECT * FROM renamed
