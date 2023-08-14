{{ config(
    materialized='incremental',
) }}

{% if is_incremental() %}
WITH new_transactions AS (
    SELECT device_type, COUNT(*) AS new_count
    FROM {{ ref('fact_store_transaction_view') }}
    WHERE metadata_timestamp > (SELECT MAX(metadata_timestamp) FROM {{ this }})
    GROUP BY device_type
),
entire_transactions AS (
    SELECT device_type, COUNT(*) AS total_count
    FROM {{ ref('fact_store_transaction_view') }}
    GROUP BY device_type
),
updated_counts AS (
    SELECT 
        e.device_type, 
        (n.new_count + COALESCE(e.total_count, 0)) AS updated_count
    FROM new_transactions n
    LEFT JOIN entire_transactions e ON n.device_type = e.device_type
)
SELECT 
    u.device_type, 
    u.updated_count * 100.0 / SUM(u.updated_count) OVER () AS percentage
FROM updated_counts u
ORDER BY u.device_type
{% else %}
WITH pct_transaction AS 
(
    SELECT device_type, COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS percentage
    FROM {{ ref('fact_store_transaction_view') }}
    GROUP BY device_type
)
SELECT * FROM pct_transaction
ORDER BY device_type
{% endif %}
