SELECT DISTINCT
    md5(concat(closest_primary_school_name,'_',primary_schools_within_1km)) as school_proximity_id,
    cast(closest_primary_school_name as string) as closest_primary_school_name,
    cast(primary_schools_within_1km as int64) as primary_schools_within_1km

FROM {{ source('hdb_raw_staging', 'raw_enriched_transactions') }}