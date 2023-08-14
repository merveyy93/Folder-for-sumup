
      
  
    

  create  table "merveyasa"."dbt_merve"."fact_store_transaction_first__dbt_tmp"
  
  
    as
  
  (
    


WITH numbered_transactions AS (
    SELECT
        store_id,
        transaction_happened_at,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY transaction_happened_at) AS rownumber
    FROM "merveyasa"."dbt_merve"."fact_store_transaction_view"
)
SELECT
    store_id,
    transaction_happened_at
FROM numbered_transactions
WHERE rownumber <= 5

  );
  
  