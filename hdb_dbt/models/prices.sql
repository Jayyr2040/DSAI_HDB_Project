{{ config(materialized='table', enabled=false) }}

WITH RAW AS (
    SELECT
        month,
        town,
        flat_type,
        block,
        street_name,
        storey_range,
        CAST(floor_area_sqm AS FLOAT64) AS floor_area_sqm,
        flat_model,
        lease_commence_date,
        remaining_lease,
        CAST(resale_price AS FLOAT64) AS resale_price,
        full_address,
        min_distance_to_regional_hub_km,
        closest_regional_hub_name,
        primary_schools_within_1km,
        primary_schools_within_2km,
        closest_primary_school_name,
        dist_to_closest_primary_school_km,
        mrt_within_500m,
        closest_mrt_name,
        dist_to_closest_mrt_km,
        lrt_within_500m,
        closest_lrt_name,
        dist_to_closest_lrt_km,
        malls_within_500m,
        malls_within_1km,
        closest_shopping_mall_name,
        dist_to_closest_shopping_mall_km
    FROM {{ source('hdb_raw_data', 'enriched_hdb_resale') }}
)
SELECT
    *,
    resale_price / floor_area_sqm AS price_per_sqm
FROM raw