select
    date_key,
    cast(full_date as date) as full_date,
    year,
    quarter,
    month,
    month_name,
    week_of_year,
    day_of_month,
    day_name,
    is_weekend,
    is_holiday,
    festival_name

from {{ source('bronze', 'dim_date') }}