{{ config(
    materialized='incremental',
    unique_key='store_typology || store_country'
) }}

{% if is_incremental() %}
WITH new_avg_tran_amount AS (
    SELECT
        store_typology,
        store_country,
        AVG(transaction_amount) AS average_transaction_amount
    FROM {{ ref('fact_store_transaction_view') }}
    WHERE metadata_timestamp > (SELECT MAX(metadata_timestamp) FROM {{ this }})
    GROUP BY store_typology, store_country
),
old_data AS (
    SELECT * FROM {{ this }}
)
, union_ AS (
    SELECT store_typology, store_country, average_transaction_amount
    FROM old_data
    WHERE NOT EXISTS (
        SELECT 1
        FROM new_avg_tran_amount
        WHERE current_data.store_typology = new_avg_tran_amount.store_typology
        AND current_data.store_country = new_avg_tran_amount.store_country
    )
    UNION ALL
    SELECT * FROM new_avg_tran_amount
)
SELECT * FROM union_

{% else %}
SELECT store_typology, store_country, AVG(transaction_amount) AS average_transaction_amount
FROM {{ ref('fact_store_transaction_view') }}
GROUP BY store_typology, store_country
{% endif %}
