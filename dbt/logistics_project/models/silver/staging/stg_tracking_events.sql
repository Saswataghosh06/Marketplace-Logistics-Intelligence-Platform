select

    tracking_event_id,

    shipment_id,

    order_id,

    carrier_id,

    trim(carrier_name) as carrier_name,

    cast(warehouse_id as bigint) as warehouse_id,

    trim(city) as city,

    trim(state) as state,

    event_sequence,

    trim(event_name) as event_name,

    trim(event_status) as event_status,

    cast(event_timestamp as timestamp) as event_timestamp,

    trim(delay_reason) as delay_reason,

    exception_type,

    delivery_attempt,

    trim(scan_source) as scan_source,

    cast(created_at as timestamp) as created_at

from {{ source('bronze','fact_tracking_events') }}