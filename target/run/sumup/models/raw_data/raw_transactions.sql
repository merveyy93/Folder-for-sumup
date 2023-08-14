
      
  
    

  create  table "merveyasa"."dbt_merve"."raw_transactions__dbt_tmp"
  
  
    as
  
  (
    

WITH code as 
(
    SELECT 
    metadata_timestamp,
    transaction_id, 
    device_id, 
    LOWER(REGEXP_REPLACE(product_name, '[^a-zA-Z\s]+', '', 'g')) as product_name, 
    (CASE 
            WHEN product_sku ~ E'^\\d+\\.\\d+E\\+\\d+$' 
            THEN LTRIM(TO_CHAR(CAST(product_sku AS DOUBLE PRECISION), '9999999999999999999999999'))
            ELSE product_sku
        END) as product_sku, 
    LOWER(REGEXP_REPLACE(category_name, '[^a-zA-Z\s]+', '', 'g')) as category_name, 
    transaction_amount, 
    transaction_status, 
    CASE 
        WHEN card_number ~ E'^\\d+\\.\\d+E\\+\\d+$' THEN 
            LTRIM(TO_CHAR(CAST(card_number AS DOUBLE PRECISION), '9999999999999999999'))
        ELSE 
            REPLACE(card_number, ' ', '') 
    END as card_number, 
    cvv, 
    transaction_created_at, 
    transaction_happened_at
	FROM "merveyasa"."public"."transactions"

)


  SELECT * FROM code

  );
  
  