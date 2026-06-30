{{ config(
    materialized = 'table'
) }}

with shipment_base as (

    select

        customer_region,

        shipment_status,
        is_sla_breached,

        actual_transit_days,
        delay_days,

        shipping_cost,
        shipment_weight_kg

    from {{ ref('fct_shipments') }}

    where customer_region is not null

),

region_metrics as (

    select

        customer_region,

        count(*) as total_shipments,

        count_if(
            shipment_status = 'Delivered'
        ) as delivered_shipments,

        count_if(

            shipment_status = 'Delivered'
            and is_sla_breached = false

        ) as on_time_shipments,

        count_if(
            is_sla_breached
        ) as sla_breached_shipments,

        round(

            100.0

            * count_if(is_sla_breached)

            /

            nullif(count(*),0),

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

    group by customer_region

)

select

    customer_region,

    total_shipments,
    delivered_shipments,

    on_time_shipments,
    sla_breached_shipments,

    sla_breach_pct,

    avg_transit_days,
    avg_delay_days,

    total_shipping_cost,
    avg_shipping_cost,

    shipping_cost_per_kg

from region_metrics