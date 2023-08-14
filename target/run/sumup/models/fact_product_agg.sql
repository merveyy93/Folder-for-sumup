
  create view "merveyasa"."dbt_merve"."fact_product_agg__dbt_tmp"
    
    
  as (
    

WITH products_aggregated AS
(
    SELECT
        product_name,
        product_sku,
        COUNT(*) AS transactions_count,
        SUM(transaction_amount) AS total_transaction_amount
    FROM
        "merveyasa"."public"."raw_transactions"
    WHERE
        transaction_status = 'accepted' 
    GROUP BY
        product_name, product_sku
)
select * from products_aggregated
  );