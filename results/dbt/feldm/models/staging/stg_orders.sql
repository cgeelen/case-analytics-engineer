WITH source AS (

  SELECT * FROM {{ source('staging', 'orders') }}

),

renamed AS (

  SELECT
    orderid::varchar AS order_id,
    customerid AS customer_id,
    employeeid AS employee_id,
    nullif(orderdate, 'NULL')::date AS order_date,
    nullif(requireddate, 'NULL')::date AS required_date,
    nullif(shippeddate, 'NULL')::date AS shipped_date,
    shipvia AS ship_via,
    freight AS freight,
    shipname AS ship_name,
    shipcity AS ship_city,
    shipregion AS ship_region,
    shipcountry AS ship_country
    -- PII-sensitive data: Should be masked with access
    -- to columns regulated by legal policy or completely left out.
    {# shippostalcode AS postal_code,
    shipaddress AS ship_address #}

  FROM source

)

SELECT * FROM renamed
