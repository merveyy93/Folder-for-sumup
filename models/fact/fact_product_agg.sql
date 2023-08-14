{{ config(
    materialized='incremental'
) }}

{% if is_incremental() %}
WITH new_data AS (
    SELECT
        product_name,
        product_sku,
        COUNT(*) AS transactions_count,
        SUM(transaction_amount) AS total_transaction_amount
    FROM
        {{ ref('raw_transactions') }}
    WHERE
        transaction_status = 'accepted'
        AND metadata_timestamp > (SELECT MAX(metadata_timestamp) FROM {{ this }})
    GROUP BY
        product_name, product_sku
),
old_data AS (
    SELECT * FROM {{ this }}
    WHERE NOT EXISTS (
        SELECT 1
        FROM new_data
        WHERE old_data.product_name = new_data.product_name
        AND old_data.product_sku = new_data.product_sku
    )
),
union_ AS (
    SELECT * FROM old_data
    UNION ALL
    SELECT * FROM new_data
)

SELECT 
    product_name,
    product_sku,
    SUM(transactions_count) AS transactions_count,
    SUM(total_transaction_amount) AS total_transaction_amount
FROM 
    union_
GROUP BY
    product_name, product_sku
{% else %}
SELECT
    product_name,
    product_sku,
    COUNT(*) AS transactions_count,
    SUM(transaction_amount) AS total_transaction_amount
FROM
    {{ ref('raw_transactions') }}
WHERE
    transaction_status = 'accepted'
GROUP BY
    product_name, product_sku
{% endif %}
