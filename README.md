Take Home Challenge - Store Transactions Analysis
Overview
This project showcases an end-to-end ELT pipeline to answer specific questions about stores, products, and devices using Python, SQL, and DBT. The aim is to analyze the data to determine which stores, products, and devices are the most efficient and how long it takes for a store to adopt devices.

Assumptions

* Data Integrity: The provided datasets are assumed to be complete, consistent, and free from duplication.
* Scalability: The code and design are optimized for large datasets but tested on a smaller sample.
* Time Zones: All transactions are considered to be in a uniform time zone.
* Currency: Transactions are handled in same currency.
* Device Classification: Devices are classified into types 1 to 5 and are tied to specific stores.

Design
The project is designed in three main phases:

* Data Ingestion: Using Python, CSV data is ingested into a PostgreSQL database. Tables for stores, devices, and transactions are created and populated. You can see below the stages of the python script;
    * Firstly python script connects to a PostgreSQL database and initially checks whether specific tables for stores, devices, and transactions exist. If these tables don't exist, it creates them using predefined SQL commands. 
    * The script then defines paths to CSV files containing the corresponding data and loads the data into the database tables. 
    * Additionally, a timestamp column is added to each table to record when the data was loaded. 
    * If any error occurs during these operations, the script prints an error message and rolls back the changes to ensure the database remains consistent. 
    * Finally, the connection to the database is closed, and a message indicating that the CSV loading is finished is printed.

* DBT Models: There are 3 stages of this project’s data modelling. 

    * Raw Data: Processing raw data for devices, stores, and transactions with incremental materialization. In this stage data cleaning was done for some columns.
        * raw_devices: Processes device information, including metadata timestamp.
            * This is an incremental model.
            * Explanation: First it creates a CTE named code. If it works incremental it only selects the rows from the ‘code’ CTE where the metadata_timestamp is greater than the maximum metadata_timestamp in the existing data. If it work with full refresh then it gets all the data from ‘code’ CTE 
        * raw_stores: Processes store information, including metadata timestamp.
            * This is an incremental model.
            * Explanation: First it creates a CTE named code. If it works incremental it only selects the rows from the ‘code’ CTE where the metadata_timestamp is greater than the maximum metadata_timestamp in the existing data. If it work with full refresh then it gets all the data from ‘code’ CTE 
        * raw_transactions: Processes transaction data, including cleaning up fields like product names and card numbers.
            * This is an incremental model.
            * Explanation: First it creates a CTE named code. If it works incremental it only selects the rows from the ‘code’ CTE where the metadata_timestamp is greater than the maximum metadata_timestamp in the existing data. If it work with full refresh then it gets all the data from ‘code’ CTE 

    * Fact Tables: Creating aggregate information related to products, store transactions, and related views.
        * fact_product_agg: Aggregates transaction data by products.
            * This is an incremental model.
            * If it works incremental then 
                * New_data CTE gets the accepted transactions that have a metadata_timestamp greater than the maximum timestamp in the existing data. It groups the data by product_name and product_sku, summing the transaction amounts and counting the transactions.
                * Old_data CTE retrieves the existing data, but filters out any records that match the product_name and product_sku in the new_data.
                * Union_ CTE combines the old and new data with an union.
                * The main select statement the results by product_name and product_sku, summing the transaction counts and amounts, which effectively updates the existing data with the new transactions.
            * If it did not work in incremental , the query groups all accepted transactions from the raw_transactions reference by product_name and product_sku, summing the transaction amounts and counting the transactions.
        * fact_Store_transaction_first: Retrieves the first five transactions per store.
            * This is an incremental model.
            * If it works incremental then, 
                * New_transactions CTE selects transactions that have a metadata_timestamp greater than the maximum timestamp in the existing data, and then numbers these rows for each store_id, ordered by transaction_happened_at.
                * old_transactions CTE retrieves existing transactions and similarly numbers the rows for each store_id.
                * union_ CTE combines the new and existing transactions.
                * The main select statement assigns row numbers again for each store_id in the combined data and then filters to keep only the first 5 rows for each store_id.
            * If it did not work incremental, 	
                * Numbered_transactions CTE give rownumber for each store_id, ordered by transaction_happened_at, for all transactions.
                * Main select statement filters to keep only the first 5 rows for each store_id. 
        * fact_store_transaction_view: Combines transactions, devices, and stores information into an incremental table for further analysis.
            * This is an incremental model.
            * If it works incremental then, 
                * Store_transactions CTE joins transactions, devices, and stores data, including several selected fields. It filters the transactions to include only those that have a metadata_timestamp greater than the maximum timestamp in the existing data. 
                * Main select statement selects all rows from the store_transactions CTE, thus returning the newly found transactions.
            * If it did not work incremental, 	
                * Store_transactions CTE joins transactions, devices, and stores data, including several selected fields but without the metadata_timestamp filtering. 
                * Main select statement selects all rows from the store_transactions CTE.

    * Result Tables: Creating summaries and result tables such as top ten products, top ten stores, average transaction amount per store, and percentage of transactions by device type.
        * avg_transaction_amount: Computes average transacted amount per store typology and country
            * This is an incremental model.
            * If it works incremental then,
                * New_avg_tran_amount CTE calculates the average transaction amount from the reference table fact_store_transaction_view, but only for the transactions that have a metadata_timestamp greater than the maximum timestamp in the existing data. 
                * Old_data CTE selects all existing rows in the current model.
                * Union_ CTE performs an union operation between the old_data (but only where there's no matching new data for the same store_typology and store_country) and the new_avg_tran_amount. This way, it includes both the newly computed averages and the previously computed ones, without duplication.
                * Main select statement returns all rows from the union_ CTE.
            * If it did not work incremental, 	
                * It calculates the average transaction amount for each combination of store_typology and store_country from the fact_store_transaction_view table.
        * inc_first_five_transaction: Calculates average time for a store to perform its 5 first transactions
            * This is a table
            * It computes the time difference between each transaction and the preceding transaction for the same store. This is done using the LAG window function, which looks at the previous row within the specified partition (store_id) and order (transaction_happened_at) and calculate timediff.
            * The main select statement takes the inner table which explained above and calculates the average time difference (avg_time_diff) for each store.
        * pct_transaction: Calculates percentage of transactions per device type
            * This is an incremental model.
            * If it works incremental then,
                * New_transactions CTE selects new transactions based on the metadata_timestamp and groups them by device_type, calculating the count of new transactions for each device type.
                * Entire_transactions CTE selects all transactions from the fact_store_transaction_view and groups them by device_type, calculating the total count for each device type.
                * Updated_counts CTE joins the new_transactions and entire_transactions CTEs on device_type. The coalesce function is used to handle situations where a device type appears in the new transactions but not in the entire transactions. It adds the new count to the total count, resulting in the updated_count.
                * The main select statement calculates the percentage for each device_type, based on the updated_count. It uses a window function to calculate the sum of all updated_count. The result is ordered by device_type.
            * If it did not work incremental,
                * Pct_transaction CTE groups transactions by device_type and calculates the percentage of transactions for each device type. It uses the window function to calculate the total count of transactions.
                * The main select statement simply retrieves the result from the pct_transaction CTE, ordering by device_type.
        * top_ten_products: Identifies top 10 products sold
                * This is a table
                * Top_ten_products CTE selects the top ten products based on the transactions_count from the fact_product_agg table. It includes the product name, SKU, transactions count, and total transaction amount.
                * The main query retrieves the result from the top_ten_products CTE.
        * top_ten_stores: Identifies top 10 stores per transacted amount
                * This is a table 
                * Top_ten_stores CTE selects the top ten stores based on the total transaction amount from the fact_store_transaction_view table. It includes the store ID and total transaction amount, summed across all transactions for that store.
                * The main query retrieves the result from the top_ten_stores CTE.

* An approach for sharing your output with other teams. How do you ensure you are still able to make changes in a controlled way in your models without potentially causing downstream (child) model failures as a result of the change?

First of all with the version control, code/model changes are tracked and managed systematically. Teams can work on different versions or branches of the code, making changes in isolated environments. Many companies using GitHub for specific requirement. An other point is the Circle Ci which work in coordinate with GitHub. Automated tests can be configured in CircleCI to run whenever changes are made. These tests can validate that changes to model / code do not inadvertently break other dependent parts. This helps to catch potential downstream failures before they become a problem. Additionally the most important thing is communication and documentation. With GitHub and circle ci you can set up notifications for build successes or failures, teams are kept in the loop about changes and can collaborate to address any issues that arise. 

* How do you ensure that your data can be trusted by your stakeholders and downstream consumers? 

To be ensure that data can be trusted by stakeholders and downstream consumers we need to put dbt tests which validate data integrity, relationships, and constraints. For example not null , greater than 0 for amounts and some custom tests. Dbtutils package can be used for dbt tests. Another important point is monitoring and logging to detect any anomalies or issues in the data processing. Additionally the most important point is documentation of the models. While creating a model if you document every point of the model and columns, stakeholders and downstream consumers can easily understand and trust the data.

