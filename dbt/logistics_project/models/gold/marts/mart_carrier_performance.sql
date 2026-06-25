{{ config(materialized='table') }}

select

    carrier_id,
    carrier_name,
    carrier_tier,

    count(*) as total_shipments,

    sum(
        case
            when shipment_status = 'Delivered'
            then 1
            else 0
        end
    ) as delivered_shipments,

    sum(
        case
            when is_sla_breached = false
            then 1
            else 0
        end
    ) as on_time_shipments,

    sum(
        case
            when is_sla_breached = true
            then 1
            else 0
        end
    ) as sla_breached_shipments,

    round(
        100.0 *
        sum(
            case
                when is_sla_breached = true
                then 1
                else 0
            end
        ) / count(*),
        2
    ) as sla_breach_pct,

    round(avg(actual_transit_days),2) as avg_transit_days,

    round(avg(delay_days),2) as avg_delay_days,

    round(sum(shipping_cost),2) as total_shipping_cost,

    round(avg(shipping_cost),2) as avg_shipping_cost,

    round(
        sum(shipping_cost)
        / nullif(sum(shipment_weight_kg),0),
        2
    ) as shipping_cost_per_kg

from {{ ref('fct_shipments') }}

where
    carrier_id is not null
    and shipment_status = 'Delivered'

group by

    carrier_id,
    carrier_name,
    carrier_tier