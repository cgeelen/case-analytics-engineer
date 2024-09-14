WITH source AS (

  SELECT * FROM {{ source('staging', 'employees') }}

),

renamed AS (

  SELECT
    employeeid::varchar AS employee_id,
    title,
    titleofcourtesy AS title_of_courtesy,
    hiredate AS hired_date,
    city AS city,
    region AS region,
    country AS country,
    notes,
    reportsto AS reports_toe
    
    -- PII-sensitive data: Should be masked with access
    -- to columns regulated by legal policy or completely left out.
    {# homephone,
    extension,
    photo,
    postalcode AS postal_code,
    address AS employee_address,
    birthdate,
    lastname AS last_name,
    firstname AS first_name,
    photopath #}

  FROM source

)

SELECT * FROM renamed
