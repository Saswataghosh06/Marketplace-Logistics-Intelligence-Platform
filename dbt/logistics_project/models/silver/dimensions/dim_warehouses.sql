select
    warehouse_id,
    warehouse_name,
    warehouse_type,

    city,
    state,
    region,

    capacity_units,
    warehouse_rating,

    cast(created_at as timestamp) as created_at

from {{ source('bronze', 'dim_warehouses') }}