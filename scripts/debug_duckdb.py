import duckdb

con = duckdb.connect("warehouse/logistics.duckdb")

result = con.execute("""
SELECT
    sla_breach_flag,
    COUNT(*) AS shipments
FROM bronze.fact_shipments
GROUP BY sla_breach_flag
ORDER BY sla_breach_flag;
""").fetchdf()

print(result)

con.close()