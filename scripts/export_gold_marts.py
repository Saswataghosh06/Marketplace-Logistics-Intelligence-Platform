import duckdb
from pathlib import Path

# -----------------------------------------------------
# Project Paths
# -----------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[1]

DB_PATH = PROJECT_ROOT / "warehouse" / "logistics.duckdb"

OUTPUT_DIR = PROJECT_ROOT / "data" / "gold"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# -----------------------------------------------------
# Connect DuckDB
# -----------------------------------------------------

con = duckdb.connect(DB_PATH)

# -----------------------------------------------------
# Gold Marts
# -----------------------------------------------------

GOLD_MARTS = [

    "mart_logistics_overview",

    "mart_carrier_performance",

    "mart_warehouse_performance",

    "mart_region_performance",

    "mart_seller_performance",

    "mart_financial_impact",

]

# -----------------------------------------------------
# Export
# -----------------------------------------------------

for mart in GOLD_MARTS:

    output_file = OUTPUT_DIR / f"{mart}.csv"

    print(f"Exporting {mart}...")

    con.execute(f"""
        COPY (

            SELECT *
            FROM main_gold.{mart}

        )

        TO '{output_file.as_posix()}'

        (
            FORMAT CSV,
            HEADER TRUE
        );
    """)

    print(f"✓ Saved -> {output_file}")

con.close()

print("\n===================================")
print("All Gold marts exported successfully.")
print("===================================")