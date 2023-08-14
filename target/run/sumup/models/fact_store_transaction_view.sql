
  create view "merveyasa"."dbt_merve"."fact_store_transaction_view__dbt_tmp"
    
    
  as (
    

WITH store_transactions AS
(
    SELECT
        t.metadata_timestamp,
        s.store_id,
        s.store_typology,
        s.store_country,
        t.product_name,
        t.product_sku,
        t.category_name,
        t.transaction_amount,
        t.transaction_status,
        t.transaction_happened_at,
        d.device_type
    FROM
        "merveyasa"."public"."raw_transactions" t
    JOIN "merveyasa"."public"."raw_devices" d ON t.device_id = d.device_id
    JOIN "merveyasa"."public"."raw_stores" s ON d.store_id = s.store_id
)

select * from store_transactions
  );