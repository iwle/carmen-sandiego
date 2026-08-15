{{
    standardize_raw(
        relation = ref('raw_sightings_australia'),
        region   = 'AUSTRALIA',
        mapping  = {
        'date_witness': 'witnessed',
        'witness'     : 'observer',
        'agent'       : 'field_chap',
        'date_agent'  : 'reported',
        'city_agent'  : 'interpol_spot',
        'country'     : 'nation',
        'city'        : 'place',
        'latitude'    : 'lat',
        'longitude'   : 'long',
        'has_weapon'  : 'has_weapon',
        'has_hat'     : 'has_hat',
        'has_jacket'  : 'has_jacket',
        'behavior'    : 'state_of_mind'
        }
    )
}}
