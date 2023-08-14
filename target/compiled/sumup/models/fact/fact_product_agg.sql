


SELECT
    product_name,
    product_sku,
    COUNT(*) AS transactions_count,
    SUM(transaction_amount) AS total_transaction_amount
FROM
    "merveyasa"."dbt_merve"."raw_transactions"
WHERE
    transaction_status = 'accepted'
GROUP BY
    product_name, product_sku
