


WITH pct_transaction AS 
(
    SELECT device_type, COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percentage
    FROM "merveyasa"."dbt_merve"."fact_store_transaction_view"
    GROUP BY device_type
)
SELECT * FROM pct_transaction
ORDER BY device_type
