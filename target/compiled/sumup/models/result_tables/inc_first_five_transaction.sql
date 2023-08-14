


SELECT
    store_id,
    AVG(time_diff) AS avg_time_diff
FROM (
    SELECT
        store_id,
        transaction_happened_at - LAG(transaction_happened_at, 1) OVER (PARTITION BY store_id ORDER BY transaction_happened_at) AS time_diff
    FROM "merveyasa"."dbt_merve"."fact_store_transaction_first"
) aa
GROUP BY store_id
