select
    order_item_id,

    order_id,

    cast(product_id as bigint) as product_id,

    seller_id,

    category,
    subcategory,
    brand,

    unit_cost,

    quantity,

    unit_price,

    line_amount,

    cast(created_at as timestamp) as created_at

from {{ source('bronze', 'fact_order_items') }}