
      
  
    

  create  table "merveyasa"."dbt_merve"."raw_devices__dbt_tmp"
  
  
    as
  
  (
    

WITH code AS (
    SELECT 
    metadata_timestamp,
    device_id, 
    device_type, 
    store_id
FROM "merveyasa"."public"."devices"
)


  SELECT * FROM code

  );
  
  