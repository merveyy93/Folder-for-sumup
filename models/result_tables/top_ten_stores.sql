{{ config(
    materialized='table',
    unique_key = 'store_id'
) }}

WITH top_ten_stores AS 
(
    SELECT store_id, SUM(transaction_amount) AS total_transaction_amount
    FROM {{ ref('fact_store_transaction_view') }}
    GROUP BY store_id
    ORDER BY total_transaction_amount DESC
    LIMIT 10
)
SELECT * FROM top_ten_stores