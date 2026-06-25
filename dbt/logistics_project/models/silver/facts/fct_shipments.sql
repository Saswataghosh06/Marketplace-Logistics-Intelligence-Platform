select

    shipment_id,
    order_id,

    shipment_weight_kg,

    city,
    state,
    country,
    customer_region,

    warehouse_id,

    carrier_id,
    carrier_name,
    carrier_tier,
    service_type,

    sla_target_pct,
    shipping_cost,

    dispatch_date,
    expected_transit_days,
    promised_delivery_date,

    actual_transit_days,
    actual_delivery_date,

    delay_days,
    is_sla_breached,

    shipment_status

from {{ ref('stg_shipments') }}