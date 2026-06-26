with shipments as (

    select *

    from {{ ref('fct_shipments') }}

),

financial_metrics as (

    select

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
                when is_sla_breached = true
                then 1
                else 0
            end
        ) as breached_shipments,

        sum(
            case
                when shipment_status = 'Delivered'
                     and is_sla_breached = false
                then 1
                else 0
            end
        ) as on_time_shipments,

        round(
            100.0 *
            sum(
                case
                    when is_sla_breached = true
                    then 1
                    else 0
                end
            )
            /
            count(*),
            2
        ) as breach_rate_pct,

        round(sum(shipping_cost),2) as total_shipping_cost,

        round(
            sum(
                case
                    when is_sla_breached = true
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
                    when is_sla_breached = true
                    then shipping_cost
                    else 0
                end
            )
            /
            nullif(sum(shipping_cost),0),
            2
        ) as breached_cost_pct,

        round(avg(shipping_cost),2) as avg_shipping_cost,

        round(
            avg(
                case
                    when is_sla_breached = true
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

        round(avg(actual_transit_days),2) as avg_transit_days,

        round(avg(delay_days),2) as avg_delay_days

    from shipments

)

select *

from financial_metrics