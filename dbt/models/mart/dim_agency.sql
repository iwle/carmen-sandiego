{{ config(materialized='table') }}

{# Interpol HQ that field agent files to #}

with reports as (
    select distinct
        city_agent as agency_city,
        agency_region
    from {{ ref('int_sightings') }}
)

select
    {{ generate_md5_key(['agency_city']) }} as agency_key,
    agency_city,
    agency_region
from reports
