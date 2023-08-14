


SELECT store_typology, store_country, AVG(transaction_amount) AS average_transaction_amount
FROM "merveyasa"."dbt_merve"."fact_store_transaction_view"
GROUP BY store_typology, store_country
