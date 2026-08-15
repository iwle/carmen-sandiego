{{ config(materialized='table') }}

{# Location dimension of where the sighting occurred #}

with locations as (
    select distinct
        city,
        country as country_code,
        latitude,
        longitude
    from {{ ref('int_sightings') }}
)

select
    {{ generate_md5_key(['city', 'country_code']) }} as location_key,
    city,
    country_code,
    latitude,
    longitude
from locations
