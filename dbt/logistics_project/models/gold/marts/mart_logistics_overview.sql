{{ config(
    materialized = 'table'
) }}

with calendar as (

    select

        date_key,
        cast(full_date as date) as full_date,

        year,
        quarter,
        month,
        month_name,
        week_of_year

    from {{ ref('dim_date') }}

),

orders as (

    select

        order_date,

        count(distinct order_id)
            as total_orders,

        count_if(
            order_status = 'Delivered'
        ) as delivered_orders,

        round(
            sum(order_amount),
            2
        ) as gross_revenue,

        round(
            sum(net_amount),
            2
        ) as net_revenue,

        round(
            avg(net_amount),
            2
        ) as avg_order_value

    from {{ ref('fct_orders') }}

    where order_date <= current_date

    group by order_date

),

shipments as (

    select

        dispatch_date,

        count(distinct shipment_id)
            as total_shipments,

        count_if(
            shipment_status = 'Delivered'
        ) as delivered_shipments,

        count_if(

            shipment_status = 'Delivered'
            and is_sla_breached = false

        ) as on_time_shipments,

        count_if(
            is_sla_breached
        ) as sla_breach_shipments,

        round(

            100.0 *

            count_if(is_sla_breached)

            /

            nullif(
                count(distinct shipment_id),
                0
            ),

            2

        ) as sla_breach_pct,

        round(
            sum(shipping_cost),
            2
        ) as shipping_cost,

        round(
            avg(shipping_cost),
            2
        ) as avg_shipping_cost,

        round(
            avg(
                actual_transit_days
            ),
            2
        ) as avg_transit_days,

        round(
            avg(
                delay_days
            ),
            2
        ) as avg_delay_days

    from {{ ref('fct_shipments') }}

    where

        dispatch_date <= current_date
        and warehouse_id is not null

    group by dispatch_date

)

select

    c.date_key,
    c.full_date,

    c.year,
    c.quarter,
    c.month,
    c.month_name,
    c.week_of_year,

    coalesce(o.total_orders,0)
        as total_orders,

    coalesce(o.delivered_orders,0)
        as delivered_orders,

    coalesce(o.gross_revenue,0)
        as gross_revenue,

    coalesce(o.net_revenue,0)
        as net_revenue,

    coalesce(o.avg_order_value,0)
        as avg_order_value,

    coalesce(s.total_shipments,0)
        as total_shipments,

    coalesce(s.delivered_shipments,0)
        as delivered_shipments,

    coalesce(s.on_time_shipments,0)
        as on_time_shipments,

    coalesce(s.sla_breach_shipments,0)
        as sla_breach_shipments,

    coalesce(s.sla_breach_pct,0)
        as sla_breach_pct,

    coalesce(s.shipping_cost,0)
        as shipping_cost,

    coalesce(s.avg_shipping_cost,0)
        as avg_shipping_cost,

    coalesce(s.avg_transit_days,0)
        as avg_transit_days,

    coalesce(s.avg_delay_days,0)
        as avg_delay_days

from calendar c

left join orders o

    on c.full_date = o.order_date

left join shipments s

    on c.full_date = s.dispatch_date