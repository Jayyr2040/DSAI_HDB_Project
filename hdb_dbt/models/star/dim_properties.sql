WITH ranked_properties as (
    SELECT
    md5(full_address) as property_id,
    cast(town as string) as town,
    cast(block as string) as block,
    cast(street_name as string) as street_name,
    cast(storey_range as string) as storey_range,
    cast(flat_type as string) as flat_type,
    cast(flat_model as string) as flat_model,
    cast(lease_commence_date as int64) as lease_commence_date,
    cast(x as float64) as coordinate_x,
    cast(y as float64) as coordinate_y,
    -- include clean regex for remaining lease
    cast(
        cast(regexp_extract(remaining_lease, r'^(\d+)\s+years?') as int64)
        +
        coalesce(cast(regexp_extract(remaining_lease, r'(\d+)\s+months?') as int64), 0) / 12.0
    as float64) as remaining_lease_years,

    row_number() over (
        partition by full_address
        order by month desc
    ) as row_num

from {{ source('hdb_raw_staging', 'raw_enriched_transactions') }}
)

SELECT
    property_id,
    town,
    block,
    street_name,
    storey_range,
    flat_type,
    flat_model,
    lease_commence_date,
    coordinate_x,
    coordinate_y,
    remaining_lease_years
from ranked_properties
where row_num = 1
