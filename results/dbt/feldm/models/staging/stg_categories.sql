WITH source AS (
  SELECT * FROM {{ source('staging', 'categories') }}
),

renamed AS (
  SELECT
    categoryid AS category_id,
    categoryname AS category_name,
    description AS category_description,
    picture AS category_picutre
  FROM source
)

SELECT * FROM renamed
