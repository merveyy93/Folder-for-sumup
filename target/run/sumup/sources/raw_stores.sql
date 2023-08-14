
      
  
    

  create  table "merveyasa"."dbt_merve"."raw_stores"
  
  
    as
  
  (
    

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
	FROM stores
WHERE metadata_timestamp > (SELECT max(metadata_timestamp) FROM "merveyasa"."dbt_merve"."raw_stores")
  );
  
  