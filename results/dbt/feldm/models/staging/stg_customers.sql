WITH source AS (

  SELECT * FROM {{ source('staging', 'customers') }}

),

renamed AS (

  SELECT
    customerid::varchar AS customer_id,
    companyname AS company_name,
    contacttitle AS contact_title,
    city,
    nullif(region, 'NULL') AS region,
    country
    -- PII-sensitive data: Should be masked with access
    -- to columns regulated by legal policy or completely left out.
    {# "address" AS contact_address,
    postalcode AS postal_code,
    contactname AS contact_name,
    phone,
    fax #}

  FROM source

)

SELECT * FROM renamed
