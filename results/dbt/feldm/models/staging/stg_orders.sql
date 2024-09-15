WITH source AS (

  SELECT * FROM {{ source('staging', 'orders') }}

),

renamed AS (

  SELECT
    orderid::varchar AS order_id,
    customerid::varchar AS customer_id,
    employeeid::varchar AS employee_id,
    nullif(orderdate, 'NULL')::date AS order_date,
    nullif(requireddate, 'NULL')::date AS required_date,
    nullif(shippeddate, 'NULL')::date AS shipped_date,
    shipvia::varchar AS shipper_id,
    freight AS freight,
    -- These columns are attributes of customers
    -- Downstream these attributes should be taken from the
    -- customers table instead. Verify, whether they can
    -- be left out in the staging layer.
    shipcity AS ship_city,
    shipcountry AS ship_country,
    replace(shipname, '''', '') AS ship_name,
    nullif(shipregion, 'NULL') AS ship_region
    -- PII-sensitive data: Review legal policy and implement access control
    {# shippostalcode AS postal_code,
    shipaddress AS ship_address #}

  FROM source

)

SELECT * FROM renamed
