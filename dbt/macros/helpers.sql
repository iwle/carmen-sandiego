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
