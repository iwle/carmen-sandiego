{% macro generate_schema_name(custom_alias_name=none, node=none) -%}
    {%- if custom_alias_name is not none -%}
        {{ custom_alias_name | trim }}
    {%- elif node.name.startswith('raw_') -%}
        {{ node.name[4:] }}
    {%- else -%}
        {{ node.name }}
    {%- endif -%}
{%- endmacro %}