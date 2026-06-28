select

    o.order_id,

    coalesce(c.customer_sk, -1) as customer_sk,

    o.customer_id,

    o.order_date,

    extract(year from o.order_date) as order_year,
    extract(month from o.order_date) as order_month,

    trim(o.order_status) as order_status,
    trim(o.payment_method) as payment_method,

    o.currency_code,

    o.order_amount,
    o.shipping_fee,
    o.discount_amount,
    o.net_amount,

    nullif(trim(o.city), '') as city,
    nullif(trim(o.state), '') as state,
    nullif(trim(o.country), '') as country,

    o.created_at

from {{ ref('stg_orders') }} o

left join {{ ref('dim_customers') }} c
    on o.customer_id = c.customer_id
   and c.is_current = true

where o.order_date <= current_date