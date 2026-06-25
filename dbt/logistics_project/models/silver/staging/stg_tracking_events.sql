select
    tracking_event_id,
    shipment_id,
    order_id,
    carrier_id,

    cast(event_timestamp as timestamp) as event_timestamp,

    event_type,
    event_location,
    event_status,

    cast(created_at as timestamp) as created_at

from {{ source('bronze', 'fact_tracking_events') }}