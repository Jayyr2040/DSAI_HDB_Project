SELECT DISTINCT
    -- 1. Create one unified trsansit hash key for the star join connection
    md5(concat(
    coalesce(closest_mrt_name, 'Unknown'), '_', 
    coalesce(cast(mrt_within_500m as string), '0'), '_',
    coalesce(cast(lrt_within_500m as string), '0')
    )) as transit_proximity_id,
    -- 2. Descriptive context columns
    cast(closest_mrt_name as string) as closest_transit_station_name,
    cast(mrt_within_500m as int64) as mrt_stations_within_500m,
    -- 3. LRT flag markers 
    cast(lrt_within_500m as int64) as lrt_stations_within_500m

FROM {{ source('hdb_raw_staging', 'raw_enriched_transactions') }}
