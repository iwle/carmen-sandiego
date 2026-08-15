{{
    standardize_raw(
        relation = ref('raw_sightings_america'),
        region   = 'AMERICA',
        mapping  = {
        'date_witness': 'date_witness',
        'witness'     : 'witness',
        'agent'       : 'agent',
        'date_agent'  : 'date_agent',
        'city_agent'  : 'region_hq',
        'country'     : 'country',
        'city'        : 'city',
        'latitude'    : 'latitude',
        'longitude'   : 'longitude',
        'has_weapon'  : 'has_weapon',
        'has_hat'     : 'has_hat',
        'has_jacket'  : 'has_jacket',
        'behavior'    : 'behavior'
        }
    )
}}
