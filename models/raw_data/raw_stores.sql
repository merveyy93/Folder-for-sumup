{{ config(
    materialized='incremental'
) }}

WITH code as (
    SELECT 
    metadata_timestamp,
    store_id, 
    store_name, 
    store_address, 
    REGEXP_REPLACE(store_city, '[^a-zA-Z\s]', '', 'g') as store_city, 
    store_country, 
    store_created_at, 
    store_typology, 
    customer_id
	FROM {{ source('public', 'stores') }}
)

{% if is_incremental() %}
  SELECT * FROM code
  WHERE metadata_timestamp > (SELECT max(metadata_timestamp) FROM {{ this }})
{% else %}
  SELECT * FROM code
{% endif %}
