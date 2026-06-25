select
    shipment_id,
    order_id,

    shipment_weight_kg,

    city,
    state,
    country,
    customer_region,

    cast(warehouse_id as bigint) as warehouse_id,

    carrier_id,
    carrier_name,
    carrier_tier,
    service_type,

    sla_target_pct,

    shipping_cost,

    cast(dispatch_date as date) as dispatch_date,

    expected_transit_days,

    cast(promised_delivery_date as date) as promised_delivery_date,

    actual_transit_days,

    cast(actual_delivery_date as date) as actual_delivery_date,

    delay_days,

    case
        when sla_breach_flag = 1 then true
        else false
    end as is_sla_breached,

    shipment_status

from {{ source('bronze', 'fact_shipments') }}