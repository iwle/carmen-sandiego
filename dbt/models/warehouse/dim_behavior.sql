{{ config(materialized='table') }}

with behaviors as (
    select distinct behavior
    from {{ ref('int_sightings') }}
)

select
    {{ generate_md5_key(['behavior']) }} as behavior_key,
    behavior
from behaviors
