{{
    standardize_raw(
        relation = ref('raw_sightings_asia'),
        region   = 'ASIA',
        mapping  = {
        'date_witness': 'sighting',
        'witness'     : 'citizen',
        'agent'       : 'officer',
        'date_agent'  : '报道',
        'city_agent'  : 'city_interpol',
        'country'     : 'nation',
        'city'        : 'city',
        'latitude'    : '纬度',
        'longitude'   : '经度',
        'has_weapon'  : 'has_weapon',
        'has_hat'     : 'has_hat',
        'has_jacket'  : 'has_jacket',
        'behavior'    : 'behavior'
        }
    )
}}
