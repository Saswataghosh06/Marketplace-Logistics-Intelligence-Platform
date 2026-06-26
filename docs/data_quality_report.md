# Data Quality Report

## Project

Marketplace Logistics Intelligence Platform

---

# Objective

This project intentionally simulates real world data quality challenges commonly found in large ecommerce logistics platforms.

Rather than producing a perfectly clean dataset, the project demonstrates how modern data engineering pipelines detect, document, preserve, and govern imperfect operational data.

The objective is to show enterprise level data quality practices using a Medallion Architecture.

---

# Data Quality Strategy

The project follows a layered quality approach.

| Layer | Purpose |
|----------|-------------------------------|
| Bronze | Preserve raw source data |
| Silver | Standardize, validate and document anomalies |
| Gold | Produce trusted business metrics |

Raw data is never overwritten.

Business metrics are generated only after applying governance rules.

---

# Bronze Layer

The Bronze layer stores raw generated data exactly as received.

No records are removed.

No business rules are applied.

Purpose:

* Historical traceability
* Auditability
* Raw data preservation

---

# Silver Layer

The Silver layer performs structural transformations while preserving known business anomalies.

Transformations include:

* Datatype standardization
* Business friendly column names
* Schema enforcement
* Key validation
* Basic integrity checks
* Documentation of known anomalies

Intentional data quality issues remain available for downstream analysis.

---

# Gold Layer

The Gold layer contains business ready marts.

Each mart applies KPI specific business rules.

Examples include:

* Excluding incomplete warehouse assignments
* Ignoring orphan customer relationships
* Using only delivered shipments for delivery KPIs
* Preventing duplicate shipment allocation in seller metrics

Gold models never modify source data.

Instead, they calculate trusted business metrics using governed logic.

---

# Intentional Data Quality Issues

The synthetic dataset intentionally includes operational issues that commonly occur in production systems.

| Issue | Purpose |
|---------|-----------------------------|
| Orphan customer records | Missing master data |
| Null warehouse assignments | Operational incompleteness |
| Future dated records | Timestamp synchronization issues |
| Duplicate tracking events | Event replay simulation |
| Missing product references | Catalog integrity issues |
| Negative quantities | Transaction anomalies |

These anomalies allow realistic analytics engineering scenarios.

---

# Data Quality Governance

Each anomaly follows a documented governance strategy.

| Issue | Silver | Gold |
|---------|---------|---------|
| Orphan customers | Retained | Excluded where required |
| Null warehouse | Retained | Excluded from warehouse KPIs |
| Future timestamps | Retained | Ignored in time based metrics |
| Duplicate tracking events | Retained | Handled in reporting logic |
| Missing products | Retained | Excluded where necessary |
| Negative quantities | Retained | Excluded from sales KPIs |

---

# Validation Process

Every transformation follows the same validation workflow.

1. dbt model execution
2. dbt data tests
3. SnowFlake validation queries
4. Business KPI reconciliation
5. Git version control

This validation process is repeated for every Gold mart.

---

# Data Quality Philosophy

The project follows an enterprise analytics engineering approach.

Instead of deleting imperfect operational data, anomalies are preserved for auditability and root cause analysis.

Business reporting is produced through governed transformation logic rather than destructive cleansing.

This approach mirrors production data warehouse practices used in modern analytics platforms.

---

# Summary

The project demonstrates:

* Raw data preservation
* Controlled anomaly management
* Transparent governance
* Layer specific responsibilities
* Reproducible validation
* Business ready KPI generation

The result is a reliable analytics platform that balances operational traceability with trusted business reporting.