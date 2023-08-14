{{ config(
    materialized='incremental'
) }}

{% if is_incremental() %}
WITH new_transactions AS (
    SELECT
        store_id,
        transaction_happened_at,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY transaction_happened_at) AS rownumber
    FROM {{ ref('fact_store_transaction_view') }}
    WHERE metadata_timestamp > (SELECT MAX(metadata_timestamp) FROM {{ this }})
),
old_transactions AS (
    SELECT
        store_id,
        transaction_happened_at,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY transaction_happened_at) AS rownumber
    FROM {{ this }}
),
union_ AS (
    SELECT * FROM new_transactions
    UNION ALL
    SELECT * FROM current_data
)
SELECT
    store_id,
    transaction_happened_at
FROM (
    SELECT
        store_id,
        transaction_happened_at,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY transaction_happened_at) AS rownumber
    FROM union_
) aa
WHERE rownumber <= 5

{% else %}
WITH numbered_transactions AS (
    SELECT
        store_id,
        transaction_happened_at,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY transaction_happened_at) AS rownumber
    FROM {{ ref('fact_store_transaction_view') }}
)
SELECT
    store_id,
    transaction_happened_at
FROM numbered_transactions
WHERE rownumber <= 5
{% endif %}
