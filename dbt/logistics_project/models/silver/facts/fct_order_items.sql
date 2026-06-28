select

    order_item_id,
    order_id,
    product_id,
    seller_id,

    category,
    subcategory,
    brand,

    quantity,
    abs(quantity) as abs_quantity,

    case
        when quantity < 0 then true
        else false
    end as is_return,

    unit_cost,
    unit_price,

    unit_price - unit_cost as unit_margin,

    line_amount,

    (unit_price - unit_cost) * quantity as line_margin,

    created_at

from {{ ref('stg_order_items') }}