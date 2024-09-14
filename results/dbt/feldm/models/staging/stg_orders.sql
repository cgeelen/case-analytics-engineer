WITH source AS (

  SELECT * FROM {{ source('staging', 'orders') }}

),

renamed AS (

  SELECT
    orderid::varchar AS order_id,
    customerid AS customer_id,
    employeeid AS employee_id,
    orderdate AS order_date,
    requireddate AS required_date,
    shippeddate AS shipped_date,
    shipvia AS ship_via,
    freight AS freight,
    shipname AS ship_name,
    shipcity AS city,
    shipregion AS region,
    shipcountry AS country
    -- PII-sensitive data: Should be masked with access
    -- to columns regulated by legal policy or completely left out.
    {# shippostalcode AS postal_code,
    shipaddress AS ship_address #}

  FROM source

)

SELECT * FROM renamed
