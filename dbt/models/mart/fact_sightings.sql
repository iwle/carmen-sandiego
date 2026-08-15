{{ config(materialized='table') }}

{# Each row represents a unique sighting (one field report) #}

with sightings as (
    select
        *
    from
        {{ ref('int_sightings') }}
)

select

    sightings.sighting_id as sighting_key,
    {{ from_date_to_char('sightings.date_witness') }} as witness_date_key,
    {{ from_date_to_char('sightings.date_agent') }} as report_date_key,
    dim_witness.witness_key,
    dim_agent.agent_key,
    dim_agency.agency_key,
    dim_location.location_key,
    dim_behavior.behavior_key,
    dim_attribute.attribute_key,
    (sightings.date_agent - sightings.date_witness)::integer as report_lag_days

from sightings

inner join {{ ref('dim_witness') }} as dim_witness
    on sightings.witness = dim_witness.witness_name

inner join {{ ref('dim_agent') }} as dim_agent
    on sightings.agent = dim_agent.agent_name

inner join {{ ref('dim_agency') }} as dim_agency
    on sightings.city_agent = dim_agency.agency_city

inner join {{ ref('dim_location') }} as dim_location
    on sightings.city = dim_location.city
   and sightings.country = dim_location.country_code

inner join {{ ref('dim_behavior') }} as dim_behavior
    on sightings.behavior = dim_behavior.behavior

inner join {{ ref('dim_attribute') }} as dim_attribute
    on sightings.has_weapon = dim_attribute.has_weapon
   and sightings.has_hat    = dim_attribute.has_hat
   and sightings.has_jacket = dim_attribute.has_jacket
