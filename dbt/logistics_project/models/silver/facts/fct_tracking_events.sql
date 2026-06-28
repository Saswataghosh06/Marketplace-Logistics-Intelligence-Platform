select

    tracking_event_id,
    shipment_id,
    order_id,

    carrier_id,
    carrier_name,

    event_sequence,
    event_name,
    event_status,

    event_timestamp,

    cast(event_timestamp as date) as event_date,

    extract(hour from event_timestamp) as event_hour,

    warehouse_id,
    city,
    state,

    delay_reason,
    exception_type,

    delivery_attempt,
    scan_source,

    case
        when event_status = 'Exception' then true
        else false
    end as is_exception,

    case
        when event_name = 'Delivered' then true
        else false
    end as is_delivery_event,

    created_at

from {{ ref('stg_tracking_events') }}