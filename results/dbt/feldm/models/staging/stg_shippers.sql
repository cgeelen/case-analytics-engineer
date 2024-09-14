WITH source AS (

  SELECT * FROM {{ source('staging', 'shippers') }}

),

renamed AS (

  SELECT
    shipperid::varchar AS shipper_id,
    companyname AS company_name,
    phone

  FROM source

)

SELECT * FROM renamed
