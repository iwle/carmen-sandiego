{{
    standardize_raw(
        relation = ref('raw_sightings_europe'),
        region   = 'EUROPE',
        mapping  = {
        'date_witness': 'date_witness',
        'witness'     : 'witness',
        'agent'       : 'agent',
        'date_agent'  : 'date_filed',
        'city_agent'  : 'region_hq',
        'country'     : 'country',
        'city'        : 'city',
        'latitude'    : 'lat_',
        'longitude'   : 'long_',
        'has_weapon'  : 'armed?',
        'has_hat'     : 'chapeau?',
        'has_jacket'  : 'coat?',
        'behavior'    : 'observed_action'
        }
    )
}}
