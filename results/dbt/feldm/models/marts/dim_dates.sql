
with dates AS (
    SELECT reporting_date::date as reporting_date
FROM generate_series
        ( '1996-07-04'::date
        , '1998-05-06'::date
        , '1 day'::interval) as reporting_date
)

SELECT
    reporting_date,
    date_trunc('month', reporting_date)::date AS reporting_month,
    date_trunc('week', reporting_date)::date AS reporting_week
FROM dates
