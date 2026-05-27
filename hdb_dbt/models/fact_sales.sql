WITH raw_source_with_counts as (
    SELECT *,
    -- Numbers identical matches sequentially 1 , and son on
    row_number() over (
            partition by 
                month, 
                full_address, 
                storey_range, 
                cast(resale_price as string), 
                cast(floor_area_sqm as string)
            order by (select null)
        ) as occurrence_number
    
    from {{ source('hdb_raw_staging', 'raw_enriched_transactions') }}
)

SELECT
-- 1. Create a unnique identity key for each transaction row
    md5(concat(
        coalesce(month, ''), '_', 
        coalesce(full_address, ''), '_',
        coalesce(storey_range, ''), '_',
        coalesce(cast(resale_price as string), ''), '_', 
        coalesce(cast(floor_area_sqm as string), ''), '_', -- ◄ ADDED THIS LINE
        coalesce(cast(occurrence_number as string), '')   -- ◄ ADDED THIS LINE
    )) as transaction_id,

-- 2. Foreign Keys mapping back to your star dimension folders
    md5(full_address) as property_id,
    md5(concat(closest_shopping_mall_name, '_',malls_within_1km)) as fk_retail_proximity_id,
    md5(concat(
        coalesce(closest_mrt_name, 'Unknown'), '_', 
        coalesce(cast(mrt_within_500m as string), '0'), '_',
        coalesce(cast(lrt_within_500m as string), '0')
    )) as fk_transit_proximity_id,
    md5(concat(closest_primary_school_name, '_', primary_schools_within_1km)) as fk_school_proximity_id,

-- 3. Temporal Tracking
    cast(month as string) as transaction_month,
    cast(storey_range as string) as storey_range,
    cast(flat_type as string) as flat_type,

-- 4. Key Computational Metrics / Continuous Variables
    cast( -- 1. Extract the number of years from the string text string
        cast(regexp_extract(remaining_lease, r'^(\d+)\s+years?') as int64)
        +
         -- 2. Extract the number of months, convert to a fraction, and default to 0 if missing
        coalesce(cast(regexp_extract(remaining_lease, r'(\d+)\s+months?') as int64), 0) / 12.0
    as float64) as remaining_lease_years,
    cast(resale_price as float64) as resale_price,
    cast(floor_area_sqm as float64) as floor_area_sqm,
    safe_divide(
        cast(resale_price as float64), 
        cast(floor_area_sqm as float64)
    ) as price_per_sqm,
     -- 🚀 NEW METRIC: Consumer-Facing Price Per Square Foot (PSF)
    safe_divide(
        safe_divide(cast(resale_price as float64), cast(floor_area_sqm as float64)),
        10.76391
    ) as price_per_sqft,
    cast(min_distance_to_regional_hub_km as float64) as min_distance_to_regional_hub_km,
    cast(dist_to_closest_shopping_mall_km as float64) as dist_to_closest_shopping_mall_km,
    cast(dist_to_closest_primary_school_km as float64) as dist_to_closest_primary_school_km,
    cast(dist_to_closest_mrt_km as float64) as dist_to_closest_mrt_km,
    cast(dist_to_closest_lrt_km as float64) as dist_to_closest_lrt_km


FROM raw_source_with_counts