{{ config(materialized='table') }}

with africa as (
    select * from {{ ref('stg_sightings_africa') }}
),

asia as (
    select * from {{ ref('stg_sightings_asia') }}
),

europe as (
    select * from {{ ref('stg_sightings_europe') }}
),

america as (
    select * from {{ ref('stg_sightings_america') }}
),

australia as (
    select * from {{ ref('stg_sightings_australia') }}
),

indian as (
    select * from {{ ref('stg_sightings_indian') }}
),

pacific as (
    select * from {{ ref('stg_sightings_pacific') }}
),

unioned as (
    select * from africa
    union all
    select * from asia
    union all
    select * from europe
    union all
    select * from america
    union all
    select * from australia
    union all
    select * from indian
    union all
    select * from pacific
)

select * from unioned