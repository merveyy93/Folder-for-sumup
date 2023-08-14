{{ config(
    materialized='incremental'
) }}

WITH code AS (
    SELECT 
    metadata_timestamp,
    device_id, 
    device_type, 
    store_id
FROM {{ source('public', 'devices') }}
)

{% if is_incremental() %}
  SELECT * FROM code
  WHERE metadata_timestamp > (SELECT max(metadata_timestamp) FROM {{ this }})
{% else %}
  SELECT * FROM code
{% endif %}