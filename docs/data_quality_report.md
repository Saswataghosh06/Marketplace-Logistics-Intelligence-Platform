# DATA_QUALITY_REPORT.md

# Marketplace Logistics Intelligence Platform

## Data Quality and Governance Report

---

# Purpose

This document describes the data quality strategy implemented throughout the Marketplace Logistics Intelligence Platform.

Rather than forcing every dataset to become perfectly clean, the project follows an enterprise data governance approach where operational data is preserved while business reporting is governed through layered transformations.

The objective is to balance:

* Operational traceability
* Historical accuracy
* Data quality transparency
* Trusted business reporting

---

# Data Quality Philosophy

Production systems rarely contain perfect data.

Operational platforms often contain:

* Missing master data
* Late arriving records
* Duplicate events
* Invalid references
* Future dated transactions
* Incomplete operational updates

Instead of deleting these records, enterprise data warehouses preserve them for auditing while ensuring that executive KPIs remain reliable.

This project follows the same philosophy.

---

# Layer Responsibilities

## Bronze Layer

### Objective

Preserve source data exactly as generated.

### Characteristics

* No transformations
* No filtering
* No business rules
* Immutable source layer
* Complete historical traceability

Every generated record is retained regardless of quality.

---

## Silver Layer

### Objective

Standardize operational data while preserving business anomalies.

Responsibilities include:

* Schema standardization
* Data type enforcement
* Business friendly naming
* Surrogate key generation
* Slowly Changing Dimensions
* Referential integrity validation
* Business rule implementation

Known operational anomalies remain available for downstream investigation.

---

## Gold Layer

### Objective

Produce trusted business metrics.

Gold models apply reporting specific business rules while preserving the underlying operational history in Silver.

Business users consume only Gold marts.

Operational investigations use Silver.

---

# Data Quality Framework

```id="ewovju"
Raw Operational Data

        │

        ▼

Bronze

Preserve Everything

        │

        ▼

Silver

Standardize

Validate

Document

        │

        ▼

Gold

Govern

Aggregate

Report
```

---

# Data Quality Checks

The project implements automated validation using dbt tests.

Validation categories include:

## Structural Validation

* Primary key uniqueness
* Mandatory field validation
* Data type consistency

## Referential Integrity

Relationships between:

* Orders and Customers
* Orders and Sellers
* Shipments and Carriers
* Shipments and Warehouses
* Order Items and Products

## Domain Validation

Accepted values for:

* Shipment Status
* Order Status
* Payment Method
* Carrier Tier
* Customer Segment
* Tracking Event Status

---

# Intentional Operational Anomalies

The synthetic dataset intentionally includes realistic operational issues.

These simulate production systems and create opportunities for root cause analysis.

| Anomaly                      | Business Scenario                | Silver    | Gold                               |
| ---------------------------- | -------------------------------- | --------- | ---------------------------------- |
| Missing customer reference   | Delayed customer synchronization | Preserved | Excluded from customer KPIs        |
| Missing warehouse assignment | Shipment not allocated           | Preserved | Excluded from warehouse reporting  |
| Future dated orders          | Clock synchronization issues     | Preserved | Excluded from trend reporting      |
| Future tracking events       | Event ingestion timing           | Preserved | Excluded from historical KPIs      |
| Duplicate tracking events    | Event replay                     | Preserved | Aggregated appropriately           |
| Missing product references   | Catalog synchronization          | Preserved | Excluded where required            |
| Negative quantities          | Transaction correction           | Preserved | Excluded from revenue calculations |

---

# Slowly Changing Dimensions

Historical accuracy is maintained through Slowly Changing Dimension Type 2.

Implemented for:

* Customers
* Carriers

Benefits include:

* Historical reporting
* Accurate KPI reconstruction
* Auditability
* Time aware analytics

---

# Data Quality Decisions

## Customer Orphans

Some orders intentionally reference customers that no longer exist in the current master dataset.

Reason:

Simulates delayed master data synchronization.

Handling:

* Retained in Silver
* Excluded from customer performance KPIs
* Documented through dbt relationship tests

---

## Missing Warehouse Assignments

Some shipments have no warehouse allocation.

Reason:

Represents incomplete operational processing.

Handling:

* Preserved in Silver
* Excluded from warehouse performance mart

---

## Future Dated Transactions

Some operational timestamps occur after the current reporting date.

Reason:

Simulates timezone differences and delayed ingestion.

Handling:

* Preserved in Silver
* Filtered from time based Gold KPIs

---

## Duplicate Tracking Events

Multiple identical tracking events intentionally exist.

Reason:

Represents event replay commonly found in event driven architectures.

Handling:

* Preserved in Silver
* Aggregated safely during reporting

---

## Invalid Product References

Some order items intentionally reference missing products.

Reason:

Simulates catalog synchronization failures.

Handling:

* Preserved for auditing
* Excluded from product level reporting

---

# Gold Layer Governance Rules

Each Gold mart applies reporting specific business rules.

| Gold Mart                  | Governance Rule                                                                   |
| -------------------------- | --------------------------------------------------------------------------------- |
| mart_logistics_overview    | Excludes future dated operational records                                         |
| mart_carrier_performance   | Calculates transit metrics using delivered shipments                              |
| mart_warehouse_performance | Excludes shipments without warehouse assignment                                   |
| mart_region_performance    | Ignores unknown customer regions                                                  |
| mart_seller_performance    | Prevents double counting through proportional shipment allocation                 |
| mart_financial_impact      | Includes all shipment costs while separating breached and on time logistics spend |

---

# Validation Workflow

Every transformation follows the same validation process.

```id="vfhw4o"
dbt Build

        │

        ▼

Schema Tests

        │

        ▼

Relationship Tests

        │

        ▼

Business Validation Queries

        │

        ▼

Gold KPI Verification

        │

        ▼

Power BI Validation
```

---

# Automated Testing

The warehouse currently validates:

* Primary key uniqueness
* Foreign key relationships
* Null constraints
* Accepted values
* Domain integrity
* Historical dimension consistency

All production models successfully pass automated dbt testing after governance rules are applied.

---

# Business Impact

Separating operational quality from reporting quality provides several advantages.

Operational teams can:

* Investigate failures
* Audit historical events
* Trace upstream issues

Business users receive:

* Trusted KPIs
* Consistent metrics
* Accurate executive dashboards
* Reliable decision support

---

# Summary

The Marketplace Logistics Intelligence Platform follows enterprise data governance principles rather than simplistic data cleansing.

Operational anomalies are intentionally preserved to maintain traceability, while business reporting is governed through layered transformations and validated KPI definitions.

This approach reflects modern Analytics Engineering practices used in large scale production data warehouses where transparency, auditability, and business trust are equally important.
