-- sighting,报道,citizen,officer,纬度,经度,city,nation,city_interpol,has_weapon,has_hat,has_jacket,behavior
with source as (

    select * from {{ ref('raw_sightings_asia') }}

),

renamed as (

    select
        cast(nullif(trim(cast("sighting" as varchar)), '') as date) as date_witness,
        cast(nullif(trim(cast("报道" as varchar)), '') as date) as date_agent,
        nullif(trim(cast("citizen" as varchar)), '') as witness,
        nullif(trim(cast("officer" as varchar)), '') as agent,
        nullif(trim(cast("city_interpol" as varchar)), '') as city_agent,

        -- NOT nullif'd against 'NA': that is Namibia's ISO-3166 alpha-2 code.
        nullif(trim(cast("nation" as varchar)), '') as country,

        nullif(trim(cast("city" as varchar)), '') as city,
        cast(nullif(trim(cast("纬度" as varchar)), '') as double precision) as latitude,
        cast(nullif(trim(cast("经度" as varchar)), '') as double precision) as longitude,

        -- Held as raw tokens here; resolved to booleans in the next CTE.
        lower(nullif(trim(cast("has_weapon" as varchar)), '')) as has_weapon,
        lower(nullif(trim(cast("has_hat" as varchar)), '')) as has_hat,
        lower(nullif(trim(cast("has_jacket" as varchar)), '')) as has_jacket,

        lower(nullif(trim(cast("behavior" as varchar)), '')) as behavior,

        'ASIA' as agency_region

    from source

),

parsed as (

    select
        renamed.date_witness,
        renamed.date_agent,
        renamed.witness,
        renamed.agent,
        renamed.city_agent,
        renamed.country,
        renamed.city,
        renamed.latitude,
        renamed.longitude,
        renamed.has_weapon,
        renamed.has_hat,
        renamed.has_jacket,
        renamed.behavior,
        renamed.agency_region

    from renamed
),

final as (

    select
        md5(
            coalesce(cast(agency_region as varchar), '<<null>>') || '||' ||
            coalesce(cast(date_witness  as varchar), '<<null>>') || '||' ||
            coalesce(cast(date_agent    as varchar), '<<null>>') || '||' ||
            coalesce(cast(witness       as varchar), '<<null>>') || '||' ||
            coalesce(cast(agent         as varchar), '<<null>>') || '||' ||
            coalesce(cast(city_agent    as varchar), '<<null>>') || '||' ||
            coalesce(cast(country       as varchar), '<<null>>') || '||' ||
            coalesce(cast(city          as varchar), '<<null>>') || '||' ||
            coalesce(cast(has_weapon    as varchar), '<<null>>') || '||' ||
            coalesce(cast(has_hat       as varchar), '<<null>>') || '||' ||
            coalesce(cast(has_jacket    as varchar), '<<null>>') || '||' ||
            coalesce(cast(behavior      as varchar), '<<null>>')
        ) as sighting_id,

        agency_region,
        date_witness,
        witness,
        agent,
        date_agent,
        city_agent,
        country,
        city,
        latitude,
        longitude,
        has_weapon,
        has_hat,
        has_jacket,
        behavior,

        (date_agent - date_witness) as days_to_file

    from parsed

)

select * from final
