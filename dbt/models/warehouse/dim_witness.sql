{{ config(materialized='table') }}

{# Public witness of the sighting #}

with witnesses as (
    select distinct witness as witness_name
    from {{ ref('int_sightings') }}
)

select
    {{ generate_md5_key(['witness_name']) }} as witness_key,
    witness_name
from witnesses
