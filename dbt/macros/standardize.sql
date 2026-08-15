{% macro generate_md5_key(fields) -%}
    md5(
        {%- for field in fields %}
        coalesce(cast({{ field }} as varchar), '<<null>>')
        {%- if not loop.last %} || '||' || {% endif %}
        {%- endfor %}
    )
{%- endmacro %}

{% macro to_date(column) -%}
    nullif(trim(cast({{ column }} as varchar)), '')::date
{%- endmacro %}

{% macro to_float(column) -%}
    nullif(trim(cast({{ column }} as varchar)), '')::double precision
{%- endmacro %}

{% macro to_boolean(column) -%}
    case lower(trim(cast({{ column }} as varchar)))
        when 'true'  then true
        when 't'     then true
        when '1'     then true
        when 'yes'   then true
        when 'false' then false
        when 'f'     then false
        when '0'     then false
        when 'no'    then false
        else null
    end
{%- endmacro %}

{% macro clean_string(column) -%}
    nullif(trim(cast({{ column }} as varchar)), '')
{%- endmacro %}


{% macro extract_date_key(column) -%}
    (to_char({{ column }}, 'YYYYMMDD'))::integer
{%- endmacro %}

{% macro standardize_raw(relation, region, mapping) %}
    {%- set column_names = [
        'date_witness',
        'witness',
        'agent',
        'date_agent',
        'city_agent',
        'country',
        'city',
        'latitude',
        'longitude',
        'has_weapon',
        'has_hat',
        'has_jacket',
        'behavior'
    ] -%}

    {%- set q = {} -%}
    {%- for key in column_names -%}
        {%- set _ = q.update({key: mapping[key]}) -%}
    {%- endfor -%}

with source as (
    select * from {{ relation }}
),

columns_renamed as (
    select
        '{{ region }}'                              as agency_region,
        {{ to_date(q['date_witness']) }}            as date_witness,
        {{ clean_string(q['witness']) }}            as witness,
        {{ clean_string(q['agent']) }}              as agent,
        {{ to_date(q['date_agent']) }}              as date_agent,
        {{ clean_string(q['city_agent']) }}         as city_agent,
        {{ clean_string(q['country']) }}            as country,
        {{ clean_string(q['city']) }}               as city,
        {{ to_float(q['latitude']) }}               as latitude,
        {{ to_float(q['longitude']) }}              as longitude,
        {{ to_boolean(q['has_weapon']) }}           as has_weapon,
        {{ to_boolean(q['has_hat']) }}              as has_hat,
        {{ to_boolean(q['has_jacket']) }}           as has_jacket,
        {{ clean_string(q['behavior']) }}           as behavior
    from source
),

columns_renamed_with_key as (
    select
        {{ generate_md5_key([
            'agency_region',
            'date_witness',
            'date_agent',
            'witness',
            'agent',
            'city',
            'country',
            'latitude',
            'longitude',
            'has_weapon',
            'has_hat',
            'has_jacket',
            'behavior'
        ]) }} as sighting_id,
        *
    from columns_renamed
)

select * from columns_renamed_with_key

{% endmacro %}
