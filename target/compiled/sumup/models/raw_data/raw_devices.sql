

WITH code AS (
    SELECT 
    metadata_timestamp,
    device_id, 
    device_type, 
    store_id
FROM "merveyasa"."public"."devices"
)


  SELECT * FROM code
