
  
    

  create  table "merveyasa"."dbt_merve"."top_ten_products__dbt_tmp"
  
  
    as
  
  (
    

WITH top_ten_products AS (
    SELECT
        product_name,
        product_sku,
        transactions_count,
        total_transaction_amount
    FROM "merveyasa"."dbt_merve"."fact_product_agg"
    ORDER BY
        transactions_count DESC
    LIMIT 10
)

SELECT * FROM top_ten_products
  );
  