{{ config(materialized='table') }}

{#
    Temporal dimension - date. Note: this is a "date" dimension, not a "time" dimension.
    This is used for time-series analysis, expanding the date range of the sightings data
    to include all dates between the first and last sighting, which in turn allows us to
    join the sightings data to a complete date dimension for time-series analysis.
#}

with bounds as (
    select
        min(least(date_witness, date_agent)) as first_day,
        max(greatest(date_witness, date_agent)) as last_day
    from {{ ref('int_sightings') }}
),

spine as (
    select generate_series(first_day, last_day, interval '1 day')::date as date_day
    from bounds
)

select
    {{ from_date_to_char('date_day') }} as temporal_key,
    date_day,
    extract(year    from date_day)::integer as calendar_year,
    extract(quarter from date_day)::integer as calendar_quarter,
    extract(month   from date_day)::integer as month_number,
    to_char(date_day, 'FMMonth') as month_name,
    to_char(date_day, 'Mon') as month_abbreviation,
    extract(day     from date_day)::integer as day_of_month,
    extract(isodow  from date_day)::integer as iso_day_of_week,
    to_char(date_day, 'FMDay') as day_name,
    extract(week    from date_day)::integer as iso_week,
    (extract(isodow from date_day) >= 6) as is_weekend
from spine
