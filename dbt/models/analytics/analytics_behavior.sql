with observations as (
    select
        dim_behavior.behavior,
        fact_sightings.sighting_key
    from {{ ref('fact_sightings') }} as fact_sightings
    inner join {{ ref('dim_behavior') }} as dim_behavior
        on fact_sightings.behavior_key = dim_behavior.behavior_key
),

number_of_sightings_per_behavior as (
    select
        behavior,
        count(*) as sightings
    from observations
    group by
        behavior
)

select
    behavior,
    sightings,
    round(sightings::numeric / sum(sightings) over (), 6) as proportion_of_all_sightings,
    row_number() over (order by sightings desc, behavior) as rank_behavior,
    (row_number() over (order by sightings desc, behavior) <= 3) as is_top_three_behavior
from number_of_sightings_per_behavior
order by rank_behavior

