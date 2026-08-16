{{ config(materialized='table') }}

{# Dimensional model for item attributes or items carried #}

with flags as (
    select true as flag union all select false
),

permutations as (
    select
        *
    from (values
        (true,  true,  true ),
        (true,  true,  false),
        (true,  false, true ),
        (true,  false, false),
        (false, true,  true ),
        (false, true,  false),
        (false, false, true ),
        (false, false, false)
    ) as t (has_weapon, has_hat, has_jacket)
)

select
    {{ generate_md5_key(['has_weapon', 'has_hat', 'has_jacket']) }} as attribute_key,
    has_weapon,
    has_hat,
    has_jacket,
    (has_weapon and has_jacket and not has_hat) as has_weapon_has_jacket_no_hat,
    (
        case when has_weapon then 1 else 0 end
        + case when has_hat then 1 else 0 end
        + case when has_jacket then 1 else 0 end
    ) as attribute_count,

    coalesce(
        nullif(
            concat_ws(' + ',
                case when has_weapon then 'weapon' end,
                case when has_hat    then 'hat'    end,
                case when has_jacket then 'jacket' end
            ),
            ''
        ),
        NULL
    ) as attribute_text
from permutations
