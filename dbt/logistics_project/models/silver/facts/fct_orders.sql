select

    order_id,
    customer_sk,
    customer_id,
    order_date,

    order_status,
    payment_method,
    currency_code,

    order_amount,
    shipping_fee,
    discount_amount,
    net_amount,

    city,
    state,
    country,

    created_at

from {{ ref('stg_orders') }}
