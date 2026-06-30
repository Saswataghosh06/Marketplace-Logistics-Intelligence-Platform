{{ config(
    materialized = 'table'
) }}

with seller_order_bridge as (

    select distinct

        order_id,
        seller_id

    from {{ ref('fct_order_items') }}

),

seller_count_per_order as (

    select

        order_id,

        count(distinct seller_id)
            as seller_count

    from seller_order_bridge

    group by order_id

),

seller_sales as (

    select

        seller_id,

        count(order_item_id)
            as total_order_items,

        sum(quantity)
            as total_quantity_sold,

        round(
            sum(line_amount),
            2
        ) as total_revenue,

        round(
            avg(line_amount),
            2
        ) as avg_order_item_value

    from {{ ref('fct_order_items') }}

    group by seller_id

),

seller_logistics as (

    select

        b.seller_id,

        sum(
            1.0 / c.seller_count
        ) as total_shipments,

        sum(

            case

                when s.shipment_status = 'Delivered'

                then 1.0 / c.seller_count

                else 0

            end

        ) as delivered_shipments,

        sum(

            case

                when s.shipment_status = 'Delivered'
                 and s.is_sla_breached = false

                then 1.0 / c.seller_count

                else 0

            end

        ) as on_time_shipments,

        sum(

            case

                when s.is_sla_breached

                then 1.0 / c.seller_count

                else 0

            end

        ) as sla_breached_shipments,

        round(

            100.0 *

            sum(

                case

                    when s.is_sla_breached

                    then 1.0 / c.seller_count

                    else 0

                end

            )

            /

            nullif(

                sum(
                    1.0 / c.seller_count
                ),

                0

            ),

            2

        ) as sla_breach_pct,

        round(

            avg(

                case

                    when s.shipment_status = 'Delivered'

                    then s.actual_transit_days

                end

            ),

            2

        ) as avg_transit_days,

        round(

            avg(

                case

                    when s.shipment_status = 'Delivered'

                    then s.delay_days

                end

            ),

            2

        ) as avg_delay_days,

        round(

            sum(

                s.shipping_cost
                / c.seller_count

            ),

            2

        ) as total_shipping_cost,

        round(

            avg(

                s.shipping_cost
                / c.seller_count

            ),

            2

        ) as avg_shipping_cost

    from seller_order_bridge b

    inner join seller_count_per_order c

        on b.order_id = c.order_id

    inner join {{ ref('fct_shipments') }} s

        on b.order_id = s.order_id

    group by b.seller_id

)

select

    d.seller_id,

    d.seller_name,

    d.seller_tier,

    d.seller_region,

    d.seller_category,

    d.rating_score,

    coalesce(s.total_order_items,0)
        as total_order_items,

    coalesce(s.total_quantity_sold,0)
        as total_quantity_sold,

    coalesce(s.total_revenue,0)
        as total_revenue,

    coalesce(s.avg_order_item_value,0)
        as avg_order_item_value,

    coalesce(l.total_shipments,0)
        as total_shipments,

    coalesce(l.delivered_shipments,0)
        as delivered_shipments,

    coalesce(l.on_time_shipments,0)
        as on_time_shipments,

    coalesce(l.sla_breached_shipments,0)
        as sla_breached_shipments,

    coalesce(l.sla_breach_pct,0)
        as sla_breach_pct,

    coalesce(l.avg_transit_days,0)
        as avg_transit_days,

    coalesce(l.avg_delay_days,0)
        as avg_delay_days,

    coalesce(l.total_shipping_cost,0)
        as total_shipping_cost,

    coalesce(l.avg_shipping_cost,0)
        as avg_shipping_cost

from {{ ref('dim_sellers') }} d

left join seller_sales s

    on d.seller_id = s.seller_id

left join seller_logistics l

    on d.seller_id = l.seller_id