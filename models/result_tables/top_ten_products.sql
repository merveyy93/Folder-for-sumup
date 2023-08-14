{{ config(
    materialized='table',
    unique_key='product_name || product_sku'
) }}

WITH top_ten_products AS (
    SELECT
        product_name,
        product_sku,
        transactions_count,
        total_transaction_amount
    FROM {{ ref('fact_product_agg') }}
    ORDER BY
        transactions_count DESC
    LIMIT 10
)

SELECT * FROM top_ten_products