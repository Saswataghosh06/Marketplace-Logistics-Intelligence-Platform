{{ config(
    materialized = 'table'
) }}

with warehouse_dim as (

    select

        warehouse_id,
        warehouse_name,
        warehouse_type,

        city,
        state,
        region,

        capacity_units,
        warehouse_rating

    from {{ ref('dim_warehouses') }}

),

shipment_base as (

    select

        warehouse_id,

        shipment_status,
        is_sla_breached,

        actual_transit_days,
        delay_days,

        shipping_cost,
        shipment_weight_kg

    from {{ ref('fct_shipments') }}

    where warehouse_id is not null

),

warehouse_metrics as (

    select

        warehouse_id,

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

    group by warehouse_id

)

select

    d.warehouse_id,

    d.warehouse_name,
    d.warehouse_type,

    d.city,
    d.state,
    d.region,

    d.capacity_units,
    d.warehouse_rating,

    coalesce(m.total_shipments,0)
        as total_shipments,

    coalesce(m.delivered_shipments,0)
        as delivered_shipments,

    coalesce(m.on_time_shipments,0)
        as on_time_shipments,

    coalesce(m.sla_breached_shipments,0)
        as sla_breached_shipments,

    coalesce(m.sla_breach_pct,0)
        as sla_breach_pct,

    coalesce(m.avg_transit_days,0)
        as avg_transit_days,

    coalesce(m.avg_delay_days,0)
        as avg_delay_days,

    coalesce(m.total_shipping_cost,0)
        as total_shipping_cost,

    coalesce(m.avg_shipping_cost,0)
        as avg_shipping_cost,

    coalesce(m.shipping_cost_per_kg,0)
        as shipping_cost_per_kg,

    round(

        100.0
        * coalesce(m.total_shipments,0)

        /

        nullif(d.capacity_units,0),

        2

    ) as warehouse_utilization_pct

from warehouse_dim d

left join warehouse_metrics m

    on d.warehouse_id = m.warehouse_id