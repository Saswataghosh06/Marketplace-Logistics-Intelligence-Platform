import duckdb
from pathlib import Path

# -------------------------------------------------------
# Paths
# -------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[1]

DB_PATH = PROJECT_ROOT / "warehouse" / "logistics.duckdb"

OUTPUT_DIR = PROJECT_ROOT / "data" / "powerbi" / "gold_exports"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# -------------------------------------------------------
# Connect DuckDB
# -------------------------------------------------------

con = duckdb.connect(DB_PATH)

# -------------------------------------------------------
# Gold Marts
# -------------------------------------------------------

GOLD_MARTS = [
    "mart_logistics_overview",
    "mart_carrier_performance",
    "mart_warehouse_performance",
    "mart_region_performance",
    "mart_seller_performance",
    "mart_financial_impact",
]

# -------------------------------------------------------
# Export each mart as CSV
# -------------------------------------------------------

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

    print(f"✓ Saved -> {output_file.name}")

con.close()

print("\nAll Gold marts exported successfully.")