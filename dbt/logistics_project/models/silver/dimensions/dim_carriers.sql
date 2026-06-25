select
    carrier_sk,
    carrier_id,

    carrier_name,
    carrier_tier,
    service_type,

    sla_target_pct,

    cast(effective_from as date) as effective_from,

    cast(effective_to as date) as effective_to,

    is_current,

    cast(created_at as timestamp) as created_at

from {{ source('bronze', 'dim_carriers_scd') }}