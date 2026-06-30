import duckdb
from pathlib import Path

# Connect to the exact file
con = duckdb.connect('warehouse/logistics.duckdb')

# Create the schema
con.execute("CREATE SCHEMA IF NOT EXISTS bronze")

# Load parquet files

bronze_path = Path("data/bronze")
for file in bronze_path.glob("*.parquet"):
    table_name = file.stem
    con.execute(f"CREATE OR REPLACE TABLE bronze.{table_name} AS SELECT * FROM read_parquet('{file}')")
    print(f"✅ Loaded: {table_name}")

con.close()