select

    tracking_event_id,
    shipment_id,
    order_id,
    carrier_id,

    event_timestamp,
    event_type,
    event_location,
    event_status,

    created_at

from {{ ref('stg_tracking_events') }}