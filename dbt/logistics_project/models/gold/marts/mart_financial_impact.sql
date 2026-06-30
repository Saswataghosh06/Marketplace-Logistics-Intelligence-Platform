{{ config(
    materialized = 'table'
) }}

with shipment_base as (

    select

        shipment_id,
        shipment_status,

        shipping_cost,
        shipment_weight_kg,

        actual_transit_days,
        delay_days,

        is_sla_breached

    from {{ ref('fct_shipments') }}

),

shipment_metrics as (

    select

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

        ) as avg_delay_days

    from shipment_base

),

financial_metrics as (

    select

        round(

            sum(shipping_cost),

            2

        ) as total_shipping_cost,

        round(

            avg(shipping_cost),

            2

        ) as avg_shipping_cost,

        round(

            sum(

                case
                    when is_sla_breached
                    then shipping_cost
                    else 0
                end

            ),

            2

        ) as breached_shipping_cost,

        round(

            sum(

                case
                    when shipment_status = 'Delivered'
                     and is_sla_breached = false
                    then shipping_cost
                    else 0
                end

            ),

            2

        ) as on_time_shipping_cost,

        round(

            100.0 *

            sum(

                case
                    when is_sla_breached
                    then shipping_cost
                    else 0
                end

            )

            /

            nullif(sum(shipping_cost),0),

            2

        ) as breached_cost_pct,

        round(

            avg(

                case
                    when is_sla_breached
                    then shipping_cost
                end

            ),

            2

        ) as avg_breached_shipping_cost,

        round(

            avg(

                case
                    when shipment_status = 'Delivered'
                     and is_sla_breached = false
                    then shipping_cost
                end

            ),

            2

        ) as avg_on_time_shipping_cost,

        round(

            sum(shipping_cost)

            /

            nullif(sum(shipment_weight_kg),0),

            2

        ) as shipping_cost_per_kg

    from shipment_base

)

select

    s.total_shipments,
    s.delivered_shipments,
    s.on_time_shipments,
    s.sla_breached_shipments,
    s.sla_breach_pct,

    s.avg_transit_days,
    s.avg_delay_days,

    f.total_shipping_cost,
    f.avg_shipping_cost,

    f.breached_shipping_cost,
    f.on_time_shipping_cost,

    f.breached_cost_pct,

    f.avg_breached_shipping_cost,
    f.avg_on_time_shipping_cost,

    f.shipping_cost_per_kg

from shipment_metrics s

cross join financial_metrics f