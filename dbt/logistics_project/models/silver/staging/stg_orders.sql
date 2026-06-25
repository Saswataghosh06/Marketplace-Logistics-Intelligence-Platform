select
    order_id,
    customer_sk,
    customer_id,
    cast(order_date as date) as order_date,
    order_status,
    payment_method,

    case
        when upper(trim(currency_code)) in ('USD', 'US$') then 'USD'
        when upper(trim(currency_code)) in ('INR', 'RS', '₹') then 'INR'
        else upper(trim(currency_code))
    end as currency_code,

    order_amount,
    shipping_fee,
    discount_amount,
    net_amount,

    cast(created_at as timestamp) as created_at,

    city,
    state,
    country

from {{ source('bronze', 'fact_orders') }}
