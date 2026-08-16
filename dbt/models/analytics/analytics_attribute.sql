{# (b) For each month, what is the probability Ms. Sandiego is armed AND wearing a jacket but NOT a hat? #}

with observations as (
    select
        dim_temporal.month_number,
        dim_temporal.month_name,
        dim_attribute.has_weapon,
        dim_attribute.has_hat,
        dim_attribute.has_jacket,
        dim_attribute.has_weapon_has_jacket_no_hat
    from {{ ref('fact_sightings') }} as fact_sightings
    inner join {{ ref('dim_temporal') }} as dim_temporal
        on fact_sightings.witness_date_key = dim_temporal.date_key
    inner join {{ ref('dim_attribute') }} as dim_attribute
        on fact_sightings.attribute_key = dim_attribute.attribute_key
),

aggregated as (
    select
        month_number,
        month_name,
        count(*) as sightings,
        count(*) filter (where has_weapon_has_jacket_no_hat) as matching_sightings,
        avg(case when has_weapon then 1.0 else 0.0 end) as p_weapon,
        avg(case when has_hat    then 1.0 else 0.0 end) as p_hat,
        avg(case when has_jacket then 1.0 else 0.0 end) as p_jacket
    from observations
    group by month_number, month_name
) 

select
    month_number,
    month_name,
    sightings,
    matching_sightings,
    round(matching_sightings::numeric / sightings, 4) as p_has_weapon_has_jacket_no_hat,
    round(p_weapon, 4) as p_weapon,
    round(p_hat, 4) as p_hat,
    round(p_jacket, 4) as p_jacket,
    round(p_weapon * p_jacket * (1 - p_hat) , 4) as expected_if_independent
from aggregated
order by month_number

