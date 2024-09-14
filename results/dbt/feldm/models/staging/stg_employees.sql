WITH source AS (

  SELECT * FROM {{ source('staging', 'employees') }}

),

renamed AS (

  SELECT
    employeeid AS employee_id,
   
    title,
    titleofcourtesy AS title_of_courtesy,
    birthdate,
    hiredate AS hired_date,
    address,
    city AS city,
    region AS region,
    postalcode AS postal_code,
    country AS country,
    homephone,
    extension,
    photo,
    notes,
    reportsto AS reports_toe,
    lastname AS last_name,
    firstname AS first_name,
    photopath

  FROM source

)

SELECT * FROM renamed
