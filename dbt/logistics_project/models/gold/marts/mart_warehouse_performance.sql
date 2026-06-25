with shipments as (

    select *
    from {{ ref('fct_shipments') }}

),

warehouses as (

    select *
    from {{ ref('dim_warehouses') }}

),

warehouse_metrics as (

    select

        s.warehouse_id,
        w.warehouse_name,
        w.warehouse_type,
        w.city,
        w.state,
        w.region,
        w.capacity_units,
        w.warehouse_rating,

        count(*) as total_shipments,

        sum(
            case
                when s.shipment_status = 'Delivered'
                then 1
                else 0
            end
        ) as delivered_shipments,

        sum(
            case
                when s.is_sla_breached = false
                     and s.shipment_status = 'Delivered'
                then 1
                else 0
            end
        ) as on_time_shipments,

        sum(
            case
                when s.is_sla_breached = true
                then 1
                else 0
            end
        ) as sla_breached_shipments,

        round(
            100.0 *
            sum(
                case
                    when s.is_sla_breached = true
                    then 1
                    else 0
                end
            )
            / count(*),
            2
        ) as sla_breach_pct,

        round(avg(s.actual_transit_days), 2) as avg_transit_days,

        round(avg(s.delay_days), 2) as avg_delay_days,

        round(sum(s.shipping_cost), 2) as total_shipping_cost,

        round(avg(s.shipping_cost), 2) as avg_shipping_cost,

        round(
            sum(s.shipping_cost)
            /
            nullif(sum(s.shipment_weight_kg), 0),
            2
        ) as shipping_cost_per_kg

    from shipments s

    left join warehouses w
        on s.warehouse_id = w.warehouse_id

    where s.warehouse_id is not null

    group by

        s.warehouse_id,
        w.warehouse_name,
        w.warehouse_type,
        w.city,
        w.state,
        w.region,
        w.capacity_units,
        w.warehouse_rating

)

select *

from warehouse_metrics