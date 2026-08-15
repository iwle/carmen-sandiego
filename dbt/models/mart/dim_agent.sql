{{ config(materialized='table') }}

{# Field agent that files report #}

with agents as (
    select
        distinct agent as agent_name
    from {{ ref('int_sightings') }}
)

select
    {{ generate_md5_key(['agent_name']) }} as agent_key
    ,agent_name
from agents
