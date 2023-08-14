

SELECT 
    metadata_timestamp,
    device_id, 
    device_type, 
    store_id
FROM devices
WHERE metadata_timestamp > (SELECT max(metadata_timestamp) FROM "merveyasa"."dbt_merve"."raw_devices")