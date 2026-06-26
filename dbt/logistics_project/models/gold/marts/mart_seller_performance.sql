with order_seller_bridge as (

    select distinct

        order_id,
        seller_id

    from {{ ref('fct_order_items') }}

),

seller_revenue as (

    select

        seller_id,

        count(order_item_id) as total_order_items,

        sum(quantity) as total_quantity_sold,

        round(sum(line_amount), 2) as total_revenue,

        round(avg(line_amount), 2) as avg_order_item_value

    from {{ ref('fct_order_items') }}

    group by seller_id

),

seller_counts as (

    select

        order_id,
        count(distinct seller_id) as seller_count

    from order_seller_bridge

    group by order_id

),

seller_logistics as (

    select

        b.seller_id,

        sum(1.0 / sc.seller_count) as total_shipments,

        sum(
            case
                when s.shipment_status = 'Delivered'
                then 1.0 / sc.seller_count
                else 0
            end
        ) as delivered_shipments,

        sum(
            case
                when s.shipment_status = 'Delivered'
                     and s.is_sla_breached = false
                then 1.0 / sc.seller_count
                else 0
            end
        ) as on_time_shipments,

        sum(
            case
                when s.is_sla_breached = true
                then 1.0 / sc.seller_count
                else 0
            end
        ) as sla_breached_shipments,

        round(
            100.0 *
            sum(
                case
                    when s.is_sla_breached = true
                    then 1.0 / sc.seller_count
                    else 0
                end
            )
            /
            nullif(
                sum(1.0 / sc.seller_count),
                0
            ),
            2
        ) as sla_breach_pct,

        round(avg(s.actual_transit_days), 2) as avg_transit_days,

        round(avg(s.delay_days), 2) as avg_delay_days,

        sum(
            s.shipping_cost / sc.seller_count
        ) as total_shipping_cost,

        round(
            avg(
                s.shipping_cost / sc.seller_count
            ),
            2
        ) as avg_shipping_cost

    from order_seller_bridge b

    inner join seller_counts sc
        on b.order_id = sc.order_id

    inner join {{ ref('fct_shipments') }} s
        on b.order_id = s.order_id

    group by b.seller_id

)

select

    ds.seller_id,
    ds.seller_name,
    ds.seller_tier,
    ds.seller_region,
    ds.seller_category,
    ds.rating_score,

    coalesce(sr.total_order_items, 0) as total_order_items,
    coalesce(sr.total_quantity_sold, 0) as total_quantity_sold,
    coalesce(sr.total_revenue, 0) as total_revenue,
    coalesce(sr.avg_order_item_value, 0) as avg_order_item_value,

    coalesce(sl.total_shipments, 0) as total_shipments,
    coalesce(sl.delivered_shipments, 0) as delivered_shipments,
    coalesce(sl.on_time_shipments, 0) as on_time_shipments,
    coalesce(sl.sla_breached_shipments, 0) as sla_breached_shipments,
    coalesce(sl.sla_breach_pct, 0) as sla_breach_pct,
    coalesce(sl.avg_transit_days, 0) as avg_transit_days,
    coalesce(sl.avg_delay_days, 0) as avg_delay_days,
    coalesce(sl.total_shipping_cost, 0) as total_shipping_cost,
    coalesce(sl.avg_shipping_cost, 0) as avg_shipping_cost

from {{ ref('dim_sellers') }} ds

left join seller_revenue sr
    on ds.seller_id = sr.seller_id

left join seller_logistics sl
    on ds.seller_id = sl.seller_id