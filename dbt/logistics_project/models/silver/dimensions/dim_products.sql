select
    product_id,
    seller_id,

    product_name,
    category,
    subcategory,
    brand,

    unit_weight_kg,
    unit_cost,

    length_cm,
    width_cm,
    height_cm,

    cast(created_at as timestamp) as created_at

from {{ source('bronze', 'dim_products') }}