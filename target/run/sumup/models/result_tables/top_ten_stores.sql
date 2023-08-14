
  
    

  create  table "merveyasa"."dbt_merve"."top_ten_stores__dbt_tmp"
  
  
    as
  
  (
    

WITH top_ten_stores AS 
(
    SELECT store_id, SUM(transaction_amount) AS total_transaction_amount
    FROM "merveyasa"."dbt_merve"."fact_store_transaction_view"
    GROUP BY store_id
    ORDER BY total_transaction_amount DESC
    LIMIT 10
)
SELECT * FROM top_ten_stores
  );
  