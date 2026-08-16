{#  QUESTION (d) For each month, what is the probability Ms. Sandiego exhibits one of her three most occurring behaviours? #}

with top_three_behavior as (
    select behavior_key
    from {{ ref('dim_behavior') }} as dim_behavior
    where dim_behavior.behavior in (
        select behavior
        from {{ ref('analytics_behavior') }}
        where is_top_three_behavior
    )
),

observations as (
    select
        dim_temporal.month_number,
        dim_temporal.month_name,
        (fact_sightings.behavior_key in (select behavior_key from top_three_behavior)) as is_top_three_behavior
    from {{ ref('fact_sightings') }} as fact_sightings
    inner join {{ ref('dim_temporal') }} as dim_temporal
        on fact_sightings.witness_date_key = dim_temporal.temporal_key
),

top_three_behavior_sightings_per_month as (
    select
        month_number,
        month_name,
        count(*) as sightings,
        count(*) filter (where is_top_three_behavior) as top_three_sightings
    from observations
    group by
        month_number,
        month_name
)

select
    month_number,
    month_name,
    sightings,
    top_three_sightings,
    round(top_three_sightings::numeric / sightings, 4) as probability_top_three_behavior,
    round(3.0 / (select count(distinct behavior) from {{ ref('dim_behavior') }})::numeric, 4) as uniform_baseline
from top_three_behavior_sightings_per_month
order by month_number

