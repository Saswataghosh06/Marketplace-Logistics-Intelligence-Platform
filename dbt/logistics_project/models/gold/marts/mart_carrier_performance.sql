{{ config(
    materialized = 'table'
) }}

with shipment_base as (

    select

        carrier_id,
        carrier_name,
        carrier_tier,

        shipment_status,
        shipping_cost,
        shipment_weight_kg,

        actual_transit_days,
        delay_days,
        is_sla_breached

    from {{ ref('fct_shipments') }}

    where carrier_id is not null

),

carrier_metrics as (

    select

        carrier_id,
        carrier_name,
        carrier_tier,

        count(*) as total_shipments,

        count_if(shipment_status = 'Delivered')
            as delivered_shipments,

        count_if(
            shipment_status = 'Delivered'
            and is_sla_breached = false
        ) as on_time_shipments,

        count_if(is_sla_breached)
            as sla_breached_shipments,

        round(

            100.0
            * count_if(is_sla_breached)
            / nullif(count(*),0),

            2

        ) as sla_breach_pct,

        round(

            avg(

                case

                    when shipment_status = 'Delivered'

                    then actual_transit_days

                end

            ),

            2

        ) as avg_transit_days,

        round(

            avg(

                case

                    when shipment_status = 'Delivered'

                    then delay_days

                end

            ),

            2

        ) as avg_delay_days,

        round(

            sum(shipping_cost),

            2

        ) as total_shipping_cost,

        round(

            avg(shipping_cost),

            2

        ) as avg_shipping_cost,

        round(

            sum(shipping_cost)

            /

            nullif(sum(shipment_weight_kg),0),

            2

        ) as shipping_cost_per_kg

    from shipment_base

    group by

        carrier_id,
        carrier_name,
        carrier_tier

)

select *

from carrier_metrics