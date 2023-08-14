{{ config(
    materialized='incremental',
    unique_key='store_id, transaction_happened_at'
) }}

{% if is_incremental() %}
    WITH store_transactions AS
    (
        SELECT
            t.metadata_timestamp,
            s.store_id,
            s.store_typology,
            s.store_country,
            t.product_name,
            t.product_sku,
            t.category_name,
            t.transaction_amount,
            t.transaction_status,
            t.transaction_happened_at,
            d.device_type
        FROM
            {{ ref('raw_transactions') }} t
        JOIN {{ ref('raw_devices') }} d ON t.device_id = d.device_id
        JOIN {{ ref('raw_stores') }} s ON d.store_id = s.store_id
        WHERE t.metadata_timestamp > (SELECT MAX(metadata_timestamp) FROM {{ this }})
    )
    select * from store_transactions
{% else %}

    WITH store_transactions AS
    (
        SELECT
            t.metadata_timestamp,
            s.store_id,
            s.store_typology,
            s.store_country,
            t.product_name,
            t.product_sku,
            t.category_name,
            t.transaction_amount,
            t.transaction_status,
            t.transaction_happened_at,
            d.device_type
        FROM
            {{ ref('raw_transactions') }} t
        JOIN {{ ref('raw_devices') }} d ON t.device_id = d.device_id
        JOIN {{ ref('raw_stores') }} s ON d.store_id = s.store_id
    )
    select * from store_transactions
{% endif %}

