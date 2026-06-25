select
    customer_sk,
    customer_id,

    customer_name,
    email,
    phone,

    city,
    state,
    country,

    customer_segment,

    cast(signup_date as date) as signup_date,

    cast(effective_from as date) as effective_from,

    cast(effective_to as date) as effective_to,

    is_current,

    cast(created_at as timestamp) as created_at

from {{ source('bronze', 'dim_customers_scd') }}