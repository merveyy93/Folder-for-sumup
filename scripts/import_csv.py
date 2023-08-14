import csv
import psycopg2
from datetime import datetime

# Check if the table exists or not

def create_table_if_not_exists(cur, table_name, table_creation_command):
    cur.execute(f"""
        SELECT EXISTS(
            SELECT FROM information_schema.tables 
            WHERE table_name = '{table_name}'
        );
    """)
    exists = cur.fetchone()[0]
    if not exists:
        cur.execute(table_creation_command)
        print(f"Table {table_name} created successfully.")
    else:
        print(f"Table {table_name} already exists. Skipping creation.")

# Connect to my database in local

conn = psycopg2.connect(
    dbname="merveyasa",
    user="merveyasa",
    password="sy1968",
    host="localhost",
    port="5433"
)

# Create a cursor object

cur = conn.cursor()

# Define the CSV file paths
csv_files = {
    'stores': '/Users/merveyasa/Desktop/SumUpCase/stores.csv',
    'devices': '/Users/merveyasa/Desktop/SumUpCase/devices.csv',
    'transactions': '/Users/merveyasa/Desktop/SumUpCase/transactions.csv'
}

# Define the SQL commands to create tables
create_tables = {
    'stores': "CREATE TABLE stores (store_id INT, store_name VARCHAR, store_address VARCHAR,store_city VARCHAR,store_country VARCHAR,store_created_at TIMESTAMP,store_typology VARCHAR,customer_id INT);",
    'devices': "CREATE TABLE devices (device_id INT, device_type INT, store_id INT);",
    'transactions': "CREATE TABLE transactions (transaction_id INT, device_id INT, product_name VARCHAR, product_sku VARCHAR, category_name VARCHAR, transaction_amount FLOAT, transaction_status VARCHAR, card_number VARCHAR, cvv INT, transaction_created_at TIMESTAMP, transaction_happened_at TIMESTAMP);"
}

try:
# Create tables if it is not exist

    for table, command in create_tables.items():
        create_table_if_not_exists(cur, table, command)
    
# Load data into the tables

    for table, file_path in csv_files.items():
        with open(file_path, 'r') as f:
            cur.copy_expert(sql=f"COPY {table} FROM stdin WITH CSV HEADER", file=f)

# Add metadata_timestamp
    for table, _ in create_tables.items():
        cur.execute(f"ALTER TABLE {table} ADD COLUMN metadata_timestamp TIMESTAMP DEFAULT NOW();")

# Commit the changes

    conn.commit()

# Error line
except Exception as e:
    print(f"Error: {e}")

# Rollback 

    conn.rollback()  

finally:

 # Close the cursor and the connection

    cur.close()
    conn.close()

print("CSV loading is finished.")