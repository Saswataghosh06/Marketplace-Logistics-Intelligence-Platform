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

union all

select
    -1 as customer_sk,
    -1 as customer_id,

    'Unknown Customer' as customer_name,
    null as email,
    null as phone,

    'Unknown' as city,
    'Unknown' as state,
    'Unknown' as country,

    'Unknown' as customer_segment,

    null as signup_date,

    cast('1900-01-01' as date) as effective_from,
    cast('9999-12-31' as date) as effective_to,

    true as is_current,

    current_timestamp as created_at