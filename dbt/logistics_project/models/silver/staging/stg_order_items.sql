select

    order_item_id,

    order_id,

    cast(product_id as bigint) as product_id,

    cast(seller_id as bigint) as seller_id,

    trim(category) as category,

    trim(subcategory) as subcategory,

    trim(brand) as brand,

    unit_cost,

    quantity,

    unit_price,

    line_amount,

    cast(created_at as timestamp) as created_at

from {{ source('bronze','fact_order_items') }}