{# (a) For each month, which agency region is Carmen Sandiego most likely to be found in? #}

with sightings as (
    select
        dim_temporal.month_number,
        dim_temporal.month_name,
        dim_agency.agency_region
    from {{ ref('fact_sightings') }} as fact_sightings
    inner join {{ ref('dim_temporal') }} as dim_temporal
        on fact_sightings.witness_date_key = dim_temporal.date_key
    inner join {{ ref('dim_agency') }} as dim_agency
        on fact_sightings.agency_key = dim_agency.agency_key
),

number_of_sightings_per_month_per_region as (
    select
        month_number,
        month_name,
        agency_region,
        count(*) as sightings
    from sightings
    group by month_number, month_name, agency_region
),

annual_baseline as (
    select
        agency_region,
        (count(*)::numeric) / sum(count(*)) over () as annual_share
    from sightings
    group by agency_region 
)

select
    number_of_sightings_per_month_per_region.month_number,
    number_of_sightings_per_month_per_region.month_name,
    number_of_sightings_per_month_per_region.agency_region,
    number_of_sightings_per_month_per_region.sightings,

    sum(number_of_sightings_per_month_per_region.sightings) over (
        partition by number_of_sightings_per_month_per_region.month_number
    ) as number_of_sightings_per_month,

    round(
        (number_of_sightings_per_month_per_region.sightings::numeric) / (sum(number_of_sightings_per_month_per_region.sightings) over (partition by number_of_sightings_per_month_per_region.month_number)), 4
    ) as proportion_of_month_sightings,

    rank() over (
        partition by number_of_sightings_per_month_per_region.month_number
        order by number_of_sightings_per_month_per_region.sightings desc
    ) as region_rank_in_month,

    round(annual_baseline.annual_share, 4) as annual_proportion,

    round(
        (number_of_sightings_per_month_per_region.sightings::numeric / sum(number_of_sightings_per_month_per_region.sightings) over (partition by number_of_sightings_per_month_per_region.month_number)) / annual_baseline.annual_share, 4
    ) as lift_vs_annual

from number_of_sightings_per_month_per_region
inner join annual_baseline
    on number_of_sightings_per_month_per_region.agency_region = annual_baseline.agency_region
order by
    number_of_sightings_per_month_per_region.month_number,
    proportion_of_month_sightings
    desc

