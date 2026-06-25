select
    order_item_id,
    order_id,
    product_id,
    seller_id,
    category,
    subcategory,
    brand,
    quantity,
    unit_cost,
    unit_price,
    line_amount,
    created_at

from {{ ref('stg_order_items') }}