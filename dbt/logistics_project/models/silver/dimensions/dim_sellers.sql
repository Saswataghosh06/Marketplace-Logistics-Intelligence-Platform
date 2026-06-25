select
    seller_id,
    seller_name,

    seller_tier,
    seller_region,
    seller_category,

    cast(onboarding_date as date) as onboarding_date,

    rating_score,
    is_active,

    cast(created_at as timestamp) as created_at

from {{ source('bronze', 'dim_sellers') }}