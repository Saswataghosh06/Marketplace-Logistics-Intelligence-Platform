select

    shipment_id,

    order_id,

    shipment_weight_kg,

    trim(city) as city,

    trim(state) as state,

    trim(country) as country,

    trim(customer_region) as customer_region,

    cast(warehouse_id as bigint) as warehouse_id,

    carrier_id,

    trim(carrier_name) as carrier_name,

    trim(carrier_tier) as carrier_tier,

    trim(service_type) as service_type,

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
        when sla_breach_flag = 0 then false
        else null
    end as is_sla_breached,

    trim(shipment_status) as shipment_status

from {{ source('bronze','fact_shipments') }}