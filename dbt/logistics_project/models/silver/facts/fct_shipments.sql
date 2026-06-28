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

    round(shipping_cost / nullif(shipment_weight_kg, 0), 2) as shipping_cost_per_kg,

    dispatch_date,

    expected_transit_days,

    promised_delivery_date,

    actual_transit_days,

    actual_delivery_date,

    delay_days,

    is_sla_breached,

    shipment_status,

    case
        when shipment_status = 'Delivered' then true
        else false
    end as is_delivered,

    case
        when delay_days > 0 then true
        else false
    end as is_delayed,

    case
        when actual_delivery_date is null then true
        else false
    end as is_open_shipment

from {{ ref('stg_shipments') }}