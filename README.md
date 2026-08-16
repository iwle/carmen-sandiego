# Cascade Debt Technical Task

This is a dbt project that does the following:

1. Extracts data from 8 field-report sheets.
2. Cleans and conforms them into single data dictionary.
3. Normalizes them into BCNF star schema.
4. Answer four analytical questions for the Interpol team.

## Quickstart

Run every step with `docker compose`.

```bash
# 1. Build the dbt image
docker compose build

# 2. Start Postgres in the background
docker compose up -d db

# 3. Install dbt packages (dbt_utils)
docker compose run --rm dbt deps

# 4. Load the seed CSVs
docker compose run --rm dbt seed

# 5. Run all models in DAG order
docker compose run --rm dbt run

# 6. Run the data tests
docker compose run --rm dbt test
```

Steps 4-6 can be run together by `docker compose run --rm dbt build`.

## PgAdmin

To run SQL on the tables, use the `pgadmin` service that ships with `docker compose`.

```bash
# 1. Run pgAdmin in Docker
docker compose up -d db

# 2. Start pgAdmin
docker compose up -d pgadmin
```

Then open `http://localhost:5050` in your browser and log in with:

- **Email:** `admin@example.com`
- **Password:** `admin`

After you log in, register a new server and point it at the `db` service using the *Docker network* hostname/port, not the published host port:

| Field | Value |
|---|---|
| Host name/address | `db` |
| Port | `5432` |
| Maintenance database | `carmen` |
| Username | `dbt` |
| Password | `dbt` |

The tables built by dbt live under the `raw`, `stg`, `mart`, and `analytics` schemas.

## Documentation

Generate and serve the dbt docs site with `docker compose`.

```bash
# 1. Build the catalog/manifest artifacts
docker compose run --rm dbt docs generate

# 2. Serve the docs site on http://localhost:8080
docker compose run --rm --service-ports dbt docs serve --host 0.0.0.0 --port 8080 --no-browser
```

Then open `http://localhost:8080` in your browser.

If port 8080 is already taken on your machine, publish the docs on a different host port by setting `DBT_DOCS_PORT` before the second command, e.g.:

```bash
DBT_DOCS_PORT=8081 docker compose run --rm --service-ports dbt docs serve --host 0.0.0.0 --port 8080 --no-browser
```

and open `http://localhost:8081` instead.

## Answers

a. For each month, which agency region is Carmen Sandiego most likely to be found?

```sql
select
    month_number,
    month_name,
    agency_region as most_likely_region,
    sightings
from analytics.analytics_region
where region_rank_in_month = 1
order by month_number;
```

| month_number | month_name | most_likely_region | sightings |
|---|---|---|---|
| 1 | January | AMERICA | 341 |
| 2 | February | EUROPE | 331 |
| 3 | March | AMERICA | 352 |
| 4 | April | AMERICA | 340 |
| 5 | May | EUROPE | 358 |
| 6 | June | ASIA | 345 |
| 7 | July | AMERICA | 350 |
| 8 | August | EUROPE | 391 |
| 9 | September | EUROPE | 376 |
| 10 | October | EUROPE | 362 |
| 11 | November | EUROPE | 353 |
| 12 | December | ASIA | 351 |

b. For each month, what is the probability that Ms. Sandiego is armed and wearing a jacket, but not a hat? What general observations about Ms. Sandiego can you make from this?

```sql
select
    month_number,
    month_name,
    sightings,
    matching_sightings,
    p_has_weapon_has_jacket_no_hat as probability_armed_jacket_no_hat,
    p_weapon,
    p_hat,
    p_jacket,
    expected_if_independent
from analytics.analytics_attribute
order by month_number;
```

| month_number | month_name | sightings | matching_sightings | probability_armed_jacket_no_hat | p_weapon | p_hat | p_jacket | expected_if_independent |
|---|---|---|---|---|---|---|---|---|
| 1 | January | 1146 | 44 | 0.0384 | 0.1091 | 0.6239 | 0.9363 | 0.0384 |
| 2 | February | 1045 | 35 | 0.0335 | 0.1167 | 0.6459 | 0.9273 | 0.0383 |
| 3 | March | 1142 | 53 | 0.0464 | 0.1173 | 0.6305 | 0.9247 | 0.0401 |
| 4 | April | 1114 | 36 | 0.0323 | 0.1113 | 0.6311 | 0.9237 | 0.0379 |
| 5 | May | 1176 | 41 | 0.0349 | 0.0995 | 0.6284 | 0.9311 | 0.0344 |
| 6 | June | 1136 | 54 | 0.0475 | 0.1347 | 0.6426 | 0.9137 | 0.0440 |
| 7 | July | 1147 | 44 | 0.0384 | 0.1064 | 0.6190 | 0.9198 | 0.0373 |
| 8 | August | 1145 | 50 | 0.0437 | 0.1205 | 0.6323 | 0.9197 | 0.0408 |
| 9 | September | 1108 | 48 | 0.0433 | 0.1209 | 0.6273 | 0.9206 | 0.0415 |
| 10 | October | 1144 | 49 | 0.0428 | 0.1084 | 0.6049 | 0.9135 | 0.0391 |
| 11 | November | 1107 | 27 | 0.0244 | 0.1048 | 0.6224 | 0.9268 | 0.0367 |
| 12 | December | 1144 | 52 | 0.0455 | 0.1224 | 0.6241 | 0.9406 | 0.0433 |

Some observations about Ms. Sandiego are:

- She is usually wearing a jacket as the probability of jacket is between 91% to 94% every month.
- She is not usually armed as the probability of being armed is between 10% to 13% every month.
- She wears a hat more often than not, but not all the time, as the probability of wearing a hat is between 60% and 65% every month.
- There seems to be no correlation between the three variables (hat, jacket and being armed), as expected joint probability is approximately equal to the actual observed probability.



c. What are the three most occuring behaviors of Ms. Sandiego?

```sql
select
	*
from
	analytics.analytics_behavior
where is_top_three_behavior;
```

| behavior | sightings | proportion_of_all_sightings | rank_behavior | is_top_three_behavior |
|---|---|---|---|---|
| out-of-control | 636 | 0.046923 | 1 | true |
| complaining | 635 | 0.046850 | 2 | true |
| happy | 634 | 0.046776 | 3 | true |

d. For each month, what is the probability Ms. Sandiego exhibits one of her three most occuring behaviors?

```sql
select
    month_number,
    month_name,
    sightings,
    top_three_sightings,
    probability_top_three_behavior,
    uniform_baseline
from analytics.analytics_common_behavior
order by month_number;
```

| month_number | month_name | sightings | top_three_sightings | probability_top_three_behavior | uniform_baseline |
|---|---|---|---|---|---|
| 1 | January | 1146 | 160 | 0.1396 | 0.1304 |
| 2 | February | 1045 | 144 | 0.1378 | 0.1304 |
| 3 | March | 1142 | 170 | 0.1489 | 0.1304 |
| 4 | April | 1114 | 154 | 0.1382 | 0.1304 |
| 5 | May | 1176 | 179 | 0.1522 | 0.1304 |
| 6 | June | 1136 | 157 | 0.1382 | 0.1304 |
| 7 | July | 1147 | 160 | 0.1395 | 0.1304 |
| 8 | August | 1145 | 157 | 0.1371 | 0.1304 |
| 9 | September | 1108 | 167 | 0.1507 | 0.1304 |
| 10 | October | 1144 | 139 | 0.1215 | 0.1304 |
| 11 | November | 1107 | 160 | 0.1445 | 0.1304 |
| 12 | December | 1144 | 158 | 0.1381 | 0.1304 |


## Data Pipeline Flow

1. `carmen_sightings.xlsx`
2. `src.raw_sightings_*`, for America, Africa, Asia, Australia, Atlantic, Europe, Indian, Pacific
3. `stg.stg_sightings_*`, for America, Africa, Asia, Australia, Atlantic, Europe, Indian, Pacific
	- From `src` to `stg`, the raw data is cleaned using the `standardize`  macro, which aligns the column names and data types.
4. `int.int_sightings` is an ephemeral intermediate table, which combines all the `stg` table into a giant 1NF table that is wide and deep.
5. `mart` contains the star schema:
	- `dim_*` or dimension tables normalize the schema into properties, for agency, agent, attribute (what they carry), behavior, location, temporal (date of sighting), witness.
	- Note however that `dim_attribute` is a *junk dimension*, because it bundles together `has_weapon`, `has_hat` and `has_jacket` which are three independent booleans that describe what is carried. They are not important enough to have their own independent dimension tables, so they are rolled up into a single lookup table.
	- `fact_sightings`  is the central fact table that has foreign keys to conformed dimensions listed above.
6. `analytics.analytics_*` tables contain answers to the questions prompted.
	- `analytics_region` answers (a) for each month, which agency region is Carmen San Diego most likely to be found in?
	- `analytics_attribute` answers (b) for each month, what is the probability Ms Sandiego is armed and wearing a jacket but not a hat?
	- `analytics_behavior` answers (c) what are the three most occurring behaviors of Ms Sandiego?
	- `analytics_common_behavior` answers (d) for each month, what is the probability Ms Sandiego exhibits one of her three most occurring behaviors (which is taken from (c))?


## Step 1. Extraction
`scripts/extract_.py` is used to write one CSV per sheet, which forms the data to seed the dbt process.

Note that:

* Headers are preserved as they are.
* Each column is converted to `varchar` datatype.

### Header titles are preserved
This includes column names such as ‘armed?’ or non-Latin characters such as ‘报道’. I preserved the header titles because renaming during the extraction would violate the data flow. The function of the extraction layer in ETL is to produce a faithful *copy* of the source data.

The seed data is then configured using `quote_columns: true` to escape any strings which may cause issues when reading them later.

### Columns are converted to `varchar` only
Similarly, any type conversion would violate the data flow. At the extract stage, we do not need to infer types or do any type casts as the objective is to preserve a copy of the source data.

## Step 2. Conformation
After examining the data, it was found that each agency has the same underlying data dictionary, but uses their own versions of headers. The following mapping table shows the differences in terminology.

| - | EUROPE | ASIA | AFRICA / AMERICA / ATLANTIC / INDIAN | AUSTRALIA | PACIFIC |
|---|---|---|---|---|---|
| `date_witness` | `date_witness` | `sighting` | `date_witness` | `witnessed` | `sight_on` |
| `witness` | `witness` | `citizen` | `witness` | `observer` | `sighter` |
| `agent` | `agent` | `officer` | `agent` | `field_chap` | `filer` |
| `date_agent` | `date_filed` | `报道` | `date_agent` | `reported` | `file_on` |
| `city_agent` | `region_hq` | `city_interpol` | `region_hq` | `interpol_spot` | `report_office` |
| `country` | `country` | `nation` | `country` | `nation` | `nation` |
| `city` | `city` | `city` | `city` | `place` | `town` |
| `latitude` | `lat_` | `纬度` | `latitude` | `lat` | `lat` |
| `longitude` | `long_` | `经度` | `longitude` | `long` | `long` |
| `has_weapon` | `armed?` | `has_weapon` | `has_weapon` | `has_weapon` | `has_weapon` |
| `has_hat` | `chapeau?` | `has_hat` | `has_hat` | `has_hat` | `has_hat` |
| `has_jacket` | `coat?` | `has_jacket` | `has_jacket` | `has_jacket` | `has_jacket` |
| `behavior` | `observed_action` | `behavior` | `behavior` | `state_of_mind` | `behavior` |

At first, I wrote three identical `SELECT` lists. However, after refactoring the code, I created a macro to handle the standardization of the headers. This is found in `dbt/macros/standardize.sql`. After that, all `stg` tables would call the `standardize` function while providing a mapping dictionary.

This has two advantages:

1. *Extensibility*. If the model adds new details in the future, I will change the macro and then subsequently add the mapping to each of the existing models in a clearer way.
2. *Modularity*. The standardization function does only the work of standardizing, while the `stg` files do the work of defining the mapping table. This makes the separation of concerns clearer.

### Truthiness
I observed that there were different linguistic equivalences for `true` and `false`, provided in different languages. An example would be: ‘是’ and ‘ja’ both meaning `true`.

Refactoring further, I created the `to_boolean` function to convert these texts into a boolean variable, instead of leaving them as `char`  types.

There was also some confusion over the term ‘NA’. However, because it is a varchar, it did not raise any errors. The term ‘NA’ in this sense refers to Namibia, and not “N/A” as in not applicable, which ordinarily would be converted to the `NULL` value.

## Step 3. Normalizing beyond 1NF
The `stg` tables are all 1NF. Each row in the table repeats the witness’ name, agent’s name, HQ city, country, city, coordinates (latitude, longitude) and behavior.

## Entity-Relationship Diagram
The Carmen project has a star schema:

- Source
- Staging
- Intermediate (ephemeral table)
- Mart
- Analytics

The entity-relationship diagram is as follows.

![Entity Relationship Diagram](./erd.svg)

### Generating the diagram

```bash
# 1. Regenerate the manifest so it reflects the current relationships tests
docker compose run --rm dbt docs generate

# 2. Install dbterd (a local Python CLI, not a dbt package)
pip install dbterd

# 3. Render the mart-layer star schema as a Mermaid ER diagram
cd dbt
python -m dbterd run -t mermaid --artifacts-dir target -s "schema:mart" -o . -ofn erd.md
```
