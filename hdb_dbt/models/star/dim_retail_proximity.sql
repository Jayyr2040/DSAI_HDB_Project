SELECT DISTINCT
    md5(concat(closest_shopping_mall_name,'_',malls_within_1km)) as retail_proximity_id,
    cast(closest_shopping_mall_name as string) as closest_shopping_mall_name,
    cast(malls_within_1km as int64) as malls_within_1km

FROM {{ source('hdb_raw_staging', 'raw_enriched_transactions') }}