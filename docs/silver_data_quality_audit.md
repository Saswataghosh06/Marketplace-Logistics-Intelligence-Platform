# DATA_QUALITY_REPORT

Data quality issues were intentionally injected during synthetic data generation to simulate real-world ecommerce logistics challenges. These anomalies are preserved in the Silver layer and governed through business rules in the Gold layer.

## Project
Logistics Analytics Portfolio Project

## Layer
Silver Layer Validation

## Validation Date
June 2026

---

# fct_orders

## PASS

| Check | Result |
|---------|---------|
| Duplicate order_id | 0 |
| Null order_id | 0 |
| Null customer_sk | 0 |
| Negative net_amount | 0 |

## KNOWN DATA QUALITY ISSUES

| Issue | Count | Percentage |
|---------|---------|---------|
| Orphan customer orders | 7,500 | 1.5% |
| Future dated orders | 500 | 0.1% |

## Decision

Retain records in Silver layer.

These records were intentionally injected during Bronze data generation to simulate real world data quality issues.

Exclude from Gold KPI calculations where appropriate.

---

# fct_order_items

## PASS

| Check | Result |
|---------|---------|
| Duplicate order_item_id | 0 |
| Negative unit_price | 0 |

## KNOWN DATA QUALITY ISSUES

| Issue | Count | Percentage |
|---------|---------|---------|
| Null product_id | 13,305 | 1.0% |
| Negative quantity | 2,661 | 0.2% |

## Decision

Retain records in Silver layer.

These records were intentionally injected during Bronze data generation to simulate catalog and transaction quality issues.

Exclude from Gold KPI calculations where appropriate.

---

# fct_shipments

## PASS

| Check | Result |
|---------|---------|
| Duplicate shipment_id | 0 |
| Null carrier_id | 0 |
| Negative shipping_cost | 0 |

## KNOWN DATA QUALITY ISSUES

| Issue | Count | Percentage |
|---------|---------|---------|
| Null warehouse_id | 9,956 | 1.99% |
| Future delivery dates | 453 | 0.09% |

## Decision

Retain records in Silver layer.

Null warehouse assignments represent incomplete operational records.

Future delivery dates represent intentionally injected temporal anomalies.

Exclude from Gold KPI calculations where appropriate.

---

# fct_tracking_events

## PASS

| Check | Result |
|---------|---------|
| Null shipment_id | 0 |
| Null order_id | 0 |

## KNOWN DATA QUALITY ISSUES

| Issue | Count | Percentage |
|---------|---------|---------|
| Duplicate tracking event rows | 53,350 | 0.99% |
| Future event timestamps | 5,380 | 0.10% |

## Decision

Retain records in Silver layer.

Duplicate tracking events simulate operational system duplication and event replay scenarios.

Future event timestamps simulate timestamp synchronization issues.

Exclude from Gold KPI calculations where appropriate.

---

# Silver Layer Summary

## Fact Tables Validated

| Table | Status |
|---------|---------|
| fct_orders | PASS |
| fct_order_items | PASS |
| fct_shipments | PASS |
| fct_tracking_events | PASS |

## Total Records

| Table | Rows |
|---------|---------|
| fct_orders | 500,000 |
| fct_order_items | 1,330,512 |
| fct_shipments | 500,000 |
| fct_tracking_events | 5,388,350 |

## Silver Layer Philosophy

The Silver layer performs:

- Datatype standardization
- Schema enforcement
- Business rule alignment
- Data quality validation
- Controlled anomaly preservation

Intentional data quality issues generated during Bronze creation are preserved in Silver to support realistic analytics scenarios.

Data cleansing for business reporting occurs in the Gold layer through KPI specific filtering and metric definitions.

This approach mirrors enterprise data warehouse practices where raw operational anomalies remain traceable while business metrics are calculated from governed datasets.