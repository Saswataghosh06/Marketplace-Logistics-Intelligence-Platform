# CHANGELOG

All notable changes to this project are documented in this file.

The project follows a milestone based development approach covering data generation, analytics engineering, and business intelligence.

---

# Version 1.0.0

## Project Initialization

### Added

* Repository structure
* Project documentation
* Development roadmap
* Git workflow
* Project architecture

---

# Version 1.1.0

## Bronze Layer

### Added

* Python synthetic data generator
* Marketplace logistics dataset
* Parquet based Bronze layer
* Eleven Bronze datasets

### Dataset Includes

* Orders
* Order Items
* Shipments
* Tracking Events
* Products
* Customers
* Sellers
* Warehouses
* Carriers
* Date Dimension

---

# Version 1.2.0

## Silver Layer

### Added

#### Staging Models

* stg_orders
* stg_order_items
* stg_shipments
* stg_tracking_events

#### Dimension Models

* dim_customers
* dim_products
* dim_sellers
* dim_warehouses
* dim_carriers
* dim_date

#### Fact Models

* fct_orders
* fct_order_items
* fct_shipments
* fct_tracking_events

### Implemented

* Data type standardization
* Business rule validation
* Naming standardization
* Data quality validation
* Source documentation
* dbt testing

---

# Version 1.3.0

## Gold Layer

### Added

### Mart 1

**mart_logistics_overview**

Business Purpose

Executive overview of marketplace logistics performance.

---

### Mart 2

**mart_carrier_performance**

Business Purpose

Analyze carrier SLA performance, delivery efficiency, and shipping costs.

---

### Mart 3

**mart_warehouse_performance**

Business Purpose

Identify warehouse bottlenecks and operational performance.

Enhancements

* Warehouse attributes
* Warehouse metadata
* Capacity information
* Warehouse rating

---

### Mart 4

**mart_region_performance**

Business Purpose

Analyze logistics performance across customer regions.

Metrics

* Regional SLA performance
* Shipping costs
* Transit times
* Delivery delays

---

### Mart 5

**mart_seller_performance**

Business Purpose

Evaluate seller operational performance and logistics impact.

Enhancements

* Seller revenue metrics
* Shipment allocation logic for multi seller orders
* Seller metadata
* SLA performance
* Shipping costs

---

### Mart 6

**mart_financial_impact**

Business Purpose

Measure the financial impact of marketplace logistics operations.

Metrics

* Total shipping cost
* Cost of SLA breached shipments
* Cost of on time shipments
* Breach cost percentage
* Average shipping costs
* Transit and delay metrics

---

# Version 1.4.0

## Data Quality Governance

### Added Documentation

* Silver Data Quality Audit
* Data Quality Report
* Data Dictionary
* Data Model
* Project Architecture
* Dashboard Design Guide

### Implemented

* Controlled anomaly preservation
* Gold KPI filtering strategy
* Business rule documentation

---

# Version 1.5.0

## Testing and Validation

### Completed

* dbt source tests
* dbt model tests
* Relationship tests
* Unique tests
* Not Null tests
* DuckDB validation
* Metric reconciliation
* Business KPI validation

---

# Current Status

## Bronze Layer

Completed

## Silver Layer

Completed

## Gold Layer

Completed

* Logistics Overview
* Carrier Performance
* Warehouse Performance
* Region Performance
* Seller Performance
* Financial Impact

## Documentation

Completed

* Project Architecture
* Data Model
* Data Dictionary
* Data Quality Report
* Silver Data Quality Audit
* Dashboard Design Guide
* Change Log

---

# Next Phase

## Power BI Dashboard Development

Planned Dashboard Pages

1. Executive Logistics Overview
2. Carrier Performance
3. Warehouse Performance
4. Regional Logistics Performance
5. Seller Performance
6. Financial Impact

Future Enhancements

* Reverse Logistics Analysis
* Returns Analysis
* Snowflake Warehouse Migration
* Production Orchestration
* CI/CD Pipeline
