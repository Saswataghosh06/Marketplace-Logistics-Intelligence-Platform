import duckdb
from pathlib import Path

# 1. Define paths relative to the project root
ROOT_DIR = Path(__file__).resolve().parent.parent
DB_PATH = ROOT_DIR / "warehouse" / "logistics.duckdb"
BRONZE_PATH = ROOT_DIR / "data" / "bronze"

def load_bronze_layer():
    # Ensure warehouse directory exists at the root
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    
    print(f"Looking for data in: {BRONZE_PATH}")
    
    # Connecting to DuckDB
    with duckdb.connect(str(DB_PATH)) as con:
        
        con.execute("CREATE SCHEMA IF NOT EXISTS bronze")
        
        # Process files
        parquet_files = list(BRONZE_PATH.glob("*.parquet"))
        
        if not parquet_files:
            print(f"⚠️ No parquet files found in {BRONZE_PATH}")
            return

        for file in parquet_files:
            table_name = file.stem
            # 'CREATE OR REPLACE' drops the old table and loads the new parquet
            con.execute(f"""
                CREATE OR REPLACE TABLE bronze.{table_name} AS 
                SELECT * FROM read_parquet('{file.as_posix()}')
            """)
            print(f"✅ Successfully refreshed: {table_name}")

if __name__ == "__main__":
    load_bronze_layer()