import duckdb
from pathlib import Path

# 1. Defining paths relative to the project root
PROJECT_ROOT = Path(__file__).resolve().parent.parent
DB_PATH = PROJECT_ROOT / "warehouse" / "logistics.duckdb"
OUTPUT_DIR = PROJECT_ROOT / "data" / "gold"

# List of marts to export
GOLD_MARTS = [
    "mart_logistics_overview",
    "mart_carrier_performance",
    "mart_warehouse_performance",
    "mart_region_performance",
    "mart_seller_performance",
    "mart_financial_impact",
]

def export_gold_marts():
    # Ensure directory exists at the root
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    print(f"Connecting to database at: {DB_PATH}")
    
    # 2. Use 'with' for safe connection management
    with duckdb.connect(str(DB_PATH)) as con:
        
        for mart in GOLD_MARTS:
            output_file = OUTPUT_DIR / f"{mart}.csv"
            
            try:
                print(f"Exporting {mart}...")
                # 3. Export query
                con.execute(f"""
                    COPY (
                        SELECT * FROM main_gold.{mart}
                    )
                    TO '{output_file.as_posix()}'
                    (FORMAT CSV, HEADER TRUE);
                """)
                print(f"  ✅ Saved -> {output_file.name}")
            except Exception as e:
                print(f"  ❌ Error exporting {mart}: {e}")

if __name__ == "__main__":
    export_gold_marts()
    print("\n===================================")
    print("Export process complete.")
    print("===================================")