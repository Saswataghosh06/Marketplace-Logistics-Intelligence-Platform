{{ config(
    materialized='table'
) }}

with valid_orders as (

    select *
    from {{ ref('fct_orders') }}
    where order_date <= current_date

),

order_metrics as (

    select

        order_date,

        count(distinct order_id) as total_orders,

        count(
            distinct case
                when order_status = 'Delivered'
                then order_id
            end
        ) as delivered_orders,

        sum(order_amount) as gross_revenue,

        sum(net_amount) as net_revenue,

        avg(net_amount) as avg_order_value

    from valid_orders
    group by order_date

),

valid_shipments as (

    select *
    from {{ ref('fct_shipments') }}
    where warehouse_id is not null
      and actual_delivery_date <= current_date

),

shipment_metrics as (

    select

        dispatch_date as shipment_date,

        count(distinct shipment_id) as total_shipments,

        count(
            case
                when shipment_status = 'Delivered'
                then 1
            end
        ) as delivered_shipments,

        count(
            case
                when shipment_status = 'Delivered'
                 and is_sla_breached = false
                then 1
            end
        ) as on_time_shipments,

        count(
            case
                when is_sla_breached = true
                then 1
            end
        ) as sla_breach_shipments,

        round(
            100.0 *
            count(
                case
                    when is_sla_breached = true
                    then 1
                end
            )
            /
            nullif(count(distinct shipment_id),0),
            2
        ) as sla_breach_pct,

        sum(shipping_cost) as shipping_cost,

        avg(shipping_cost) as avg_shipping_cost,

        avg(actual_transit_days) as avg_transit_days,

        avg(delay_days) as avg_delay_days

    from valid_shipments
    group by dispatch_date

)

select

    d.date_key,
    cast(d.full_date as date) as full_date,
    d.year,
    d.quarter,
    d.month,
    d.month_name,
    d.week_of_year,

    coalesce(o.total_orders,0) as total_orders,
    coalesce(o.delivered_orders,0) as delivered_orders,

    coalesce(o.gross_revenue,0) as gross_revenue,
    coalesce(o.net_revenue,0) as net_revenue,
    coalesce(o.avg_order_value,0) as avg_order_value,

    coalesce(s.total_shipments,0) as total_shipments,
    coalesce(s.delivered_shipments,0) as delivered_shipments,
    coalesce(s.on_time_shipments,0) as on_time_shipments,

    coalesce(s.shipping_cost,0) as shipping_cost,
    coalesce(s.avg_shipping_cost,0) as avg_shipping_cost,

    coalesce(s.sla_breach_shipments,0) as sla_breach_shipments,
    coalesce(s.sla_breach_pct,0) as sla_breach_pct,

    coalesce(s.avg_transit_days,0) as avg_transit_days,
    coalesce(s.avg_delay_days,0) as avg_delay_days

from {{ ref('dim_date') }} d

left join order_metrics o
    on cast(d.full_date as date) = o.order_date

left join shipment_metrics s
    on cast(d.full_date as date) = s.shipment_date