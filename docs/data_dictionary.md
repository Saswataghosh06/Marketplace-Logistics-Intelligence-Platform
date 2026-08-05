# Marketplace Logistics Intelligence Platform

## Enterprise Data Dictionary

---

# Purpose

This document defines the business meaning, ownership, and analytical purpose of every dataset used throughout the Marketplace Logistics Intelligence Platform.

The data dictionary acts as the central metadata reference for Analytics Engineers, Data Analysts, Business Stakeholders, and Dashboard Developers.

Rather than documenting every technical column, this document focuses on the business meaning of each dataset, its grain, ownership, measures, and relationships that support reporting, KPI calculations, and executive decision making.

The data dictionary reflects the final Version 2 architecture of the project, which uses DuckDB as the analytical warehouse, dbt Core for transformations, an automated CI/CD pipeline using GitHub Actions and Docker for orchestration and deployment, and Gold Business Marts for dashboard visualization.

---

# Warehouse Overview

The project follows a Medallion Architecture combined with dimensional modeling.

| Layer | Purpose |
|------|---------------------------------------------|
| Bronze | Immutable raw operational Parquet datasets |
| DuckDB Bronze | Raw operational tables loaded by Python |
| Silver | Staging models, dimensions, and fact tables |
| Gold | Business-ready analytical marts |

The codebase is governed by an automated CI/CD pipeline using GitHub Actions and Docker.

```text
GitHub Actions (CI/CD)

        │

        ▼

Bronze Parquet Files

        │

        ▼

load_bronze.py

        │

        ▼

DuckDB Bronze Layer

        │

        ▼

dbt debug

        │

        ▼

dbt build

        │

        ▼

Silver Warehouse

        │

        ▼

Gold Business Marts

        │

        ▼

export_gold_marts.py

        │

        ▼

CSV Exports

        │

        ▼

Dashboard Visualization
```

---

# Bronze Layer

The Bronze layer contains immutable synthetic marketplace datasets stored as Parquet files.

These files simulate operational systems and serve as the ingestion source for DuckDB.

The Bronze layer preserves all generated records exactly as produced without applying any business transformations.

Data ingestion into DuckDB is performed by:

```text
scripts/load_bronze.py
```

## Bronze Datasets

| Dataset | Business Description |
|----------|----------------------|
| customers_scd | Customer master history with SCD Type 2 records |
| carriers_scd | Carrier master history with SCD Type 2 records |
| sellers | Marketplace seller master data |
| products | Marketplace product catalog |
| warehouses | Warehouse master data |
| regions | Geographic delivery regions |
| date_dimension | Calendar dimension |
| orders | Customer order transactions |
| order_items | Products purchased within each order |
| shipments | Shipment lifecycle information |
| tracking_events | Shipment tracking history |

---

# Silver Layer

The Silver layer represents the enterprise dimensional warehouse.

It contains reusable business entities and transactional facts that support downstream analytics.

The Silver layer is divided into three logical components.

## Staging Models

Purpose

Standardize raw operational datasets before dimensional modeling.

Responsibilities include:

* Column renaming
* Data type standardization
* Business-friendly naming
* Data validation
* Initial cleansing
* Schema consistency

---

## Dimension Tables

Dimension tables describe business entities used throughout the warehouse.

They provide descriptive attributes for slicing, filtering, grouping, and historical reporting.

---

# dim_customers

## Business Purpose

Stores customer master information while preserving historical profile changes using Slowly Changing Dimension Type 2.

## Grain

One row per customer version.

## Primary Key

customer_sk

## Source

customers_scd

## Business Owner

Customer Operations

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| customer_sk | Historical surrogate key |
| customer_id | Stable business identifier |
| customer_name | Customer full name |
| city | Customer city |
| state | Customer state |
| country | Customer country |
| customer_region | Reporting geography |
| customer_segment | Customer segment |
| signup_date | Registration date |
| effective_from | Record start date |
| effective_to | Record end date |
| is_current | Current customer version |

---

# dim_carriers

## Business Purpose

Stores logistics carrier information and historical SLA configurations using Slowly Changing Dimension Type 2.

## Grain

One row per carrier version.

## Primary Key

carrier_sk

## Source

carriers_scd

## Business Owner

Logistics Operations

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| carrier_sk | Historical surrogate key |
| carrier_id | Stable carrier identifier |
| carrier_name | Logistics provider |
| carrier_tier | Service classification |
| service_type | Delivery service |
| sla_target_pct | Target SLA percentage |
| effective_from | Version start |
| effective_to | Version end |
| is_current | Current carrier version |

---

# dim_products

## Business Purpose

Stores descriptive product information used for sales, revenue, profitability, and seller analytics.

## Grain

One row per product.

## Primary Key

product_id

## Source

products

## Business Owner

Product Management

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| product_id | Product identifier |
| product_name | Product name |
| category | Product category |
| brand | Product brand |
| unit_cost | Procurement cost |

---
# dim_sellers

## Business Purpose

Stores marketplace seller information used for operational, financial, and fulfillment performance reporting.

## Grain

One row per seller.

## Primary Key

seller_id

## Source

sellers

## Business Owner

Marketplace Operations

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| seller_id | Seller identifier |
| seller_name | Marketplace seller |
| seller_tier | Marketplace tier |
| seller_region | Operating region |
| seller_category | Primary business category |
| rating_score | Marketplace seller rating |

---

# dim_warehouses

## Business Purpose

Stores warehouse attributes used for shipment routing, warehouse performance analysis, and fulfillment reporting.

## Grain

One row per warehouse.

## Primary Key

warehouse_id

## Source

warehouses

## Business Owner

Warehouse Operations

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| warehouse_id | Warehouse identifier |
| warehouse_name | Warehouse name |
| warehouse_type | Fulfillment center type |
| city | Warehouse city |
| state | Warehouse state |
| region | Warehouse region |
| capacity_units | Storage capacity |
| warehouse_rating | Operational rating |

---

# dim_regions

## Business Purpose

Stores standardized geographical regions used for regional logistics and delivery performance analysis.

## Grain

One row per region.

## Primary Key

region_id

## Source

regions

## Business Owner

Logistics Strategy

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| region_id | Region identifier |
| region_name | Business reporting region |
| country | Country |
| zone | Operational zone |

---

# dim_date

## Business Purpose

Provides a reusable calendar dimension for time based reporting across all business processes.

## Grain

One row per calendar date.

## Primary Key

date_key

## Source

date_dimension

## Business Owner

Enterprise Analytics

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| date_key | Calendar surrogate key |
| full_date | Calendar date |
| day | Day of month |
| week | ISO week |
| month | Calendar month |
| month_name | Month description |
| quarter | Calendar quarter |
| year | Reporting year |
| day_name | Weekday name |
| is_weekend | Weekend indicator |

---

# Fact Tables

Fact tables capture measurable operational business events.

Each fact table has a clearly defined grain and stores numerical measures used throughout the Gold business marts.

---

# fct_orders

## Business Purpose

Captures every customer order placed on the marketplace.

## Grain

One row per customer order.

## Primary Key

order_id

## Source

orders

## Measures

* Order Amount
* Shipping Fee
* Discount Amount
* Net Amount

## Dimensions

* Customer
* Date

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| order_id | Order identifier |
| customer_sk | Customer surrogate key |
| customer_id | Business customer identifier |
| order_date | Order creation date |
| order_status | Current order status |
| payment_method | Payment method |
| currency_code | Transaction currency |
| order_amount | Gross order value |
| shipping_fee | Shipping charge |
| discount_amount | Promotional discount |
| net_amount | Final amount paid |

---

# fct_order_items

## Business Purpose

Captures every product purchased within an order.

## Grain

One row per purchased product.

## Primary Key

order_item_id

## Source

order_items

## Measures

* Quantity
* Unit Cost
* Unit Price
* Line Revenue

## Dimensions

* Product
* Seller
* Order

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| order_item_id | Order line identifier |
| order_id | Parent order |
| seller_id | Selling merchant |
| product_id | Purchased product |
| quantity | Units sold |
| unit_cost | Procurement cost |
| unit_price | Selling price |
| line_amount | Revenue generated |

---

# fct_shipments

## Business Purpose

Captures the complete shipment lifecycle from warehouse dispatch to final customer delivery.

## Grain

One row per shipment.

## Primary Key

shipment_id

## Source

shipments

## Measures

* Shipping Cost
* Shipment Weight
* Actual Transit Days
* Delay Days
* SLA Breach Indicator

## Dimensions

* Carrier
* Warehouse
* Region
* Order

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| shipment_id | Shipment identifier |
| order_id | Parent order |
| warehouse_id | Dispatch warehouse |
| carrier_id | Logistics carrier |
| region_id | Delivery region |
| dispatch_date | Dispatch date |
| promised_delivery_date | SLA commitment |
| actual_delivery_date | Delivery completion |
| shipment_status | Shipment lifecycle status |
| shipment_weight_kg | Shipment weight |
| shipping_cost | Shipment cost |
| actual_transit_days | Transit duration |
| delay_days | Delivery delay |
| is_sla_breached | SLA breach indicator |

---

# fct_tracking_events

## Business Purpose

Stores operational shipment tracking events recorded throughout the delivery lifecycle.

## Grain

One row per tracking event.

## Primary Key

tracking_event_id

## Source

tracking_events

## Measures

This table contains operational events rather than additive business measures.

It supports shipment traceability, exception monitoring, and operational analytics.

## Dimensions

* Shipment
* Carrier
* Date

## Important Fields

| Column | Business Meaning |
|---------|------------------|
| tracking_event_id | Tracking event identifier |
| shipment_id | Shipment reference |
| order_id | Related order |
| carrier_id | Logistics carrier |
| event_timestamp | Event timestamp |
| event_date | Event date |
| event_hour | Event hour |
| event_name | Tracking event |
| event_status | Event status |
| event_location | Event location |
| is_exception | Operational exception indicator |
| is_delivery_event | Delivery completion indicator |

---
# Gold Business Marts

The Gold layer contains business ready analytical datasets designed for executive reporting, operational monitoring, and dashboard visualization.

Each mart answers a specific business problem while exposing governed KPIs built from the Silver warehouse.

---

# mart_logistics_overview

## Business Purpose

Provides enterprise level logistics KPIs across the complete marketplace.

## Grain

One row per reporting date.

## Primary Business Users

* Executive Leadership
* Operations Managers
* Business Analysts

## Example KPIs

* Total Orders
* Total Revenue
* Average Order Value
* Average Delivery Time
* SLA Compliance
* On Time Delivery Rate
* Late Deliveries
* Total Shipping Cost

---

# mart_carrier_performance

## Business Purpose

Measures logistics carrier performance and SLA compliance.

## Grain

One row per carrier.

## Primary Business Users

* Logistics Managers
* Carrier Operations

## Example KPIs

* Shipments Delivered
* Average Transit Time
* Delay Days
* SLA Achievement %
* Average Shipping Cost
* Late Shipment Rate

---

# mart_warehouse_performance

## Business Purpose

Evaluates warehouse operational efficiency.

## Grain

One row per warehouse.

## Primary Business Users

* Warehouse Managers
* Supply Chain Operations

## Example KPIs

* Orders Processed
* Shipments Dispatched
* Average Dispatch Time
* Warehouse Utilization
* Delivery Performance

---

# mart_region_performance

## Business Purpose

Measures logistics performance across geographic regions.

## Grain

One row per region.

## Primary Business Users

* Regional Operations
* Business Strategy

## Example KPIs

* Orders
* Revenue
* Delivery Time
* Shipping Cost
* SLA Compliance
* Customer Distribution

---

# mart_seller_performance

## Business Purpose

Measures seller fulfillment efficiency and logistics contribution.

## Grain

One row per seller.

## Primary Business Users

* Marketplace Operations
* Seller Success Team

## Example KPIs

* Orders Fulfilled
* Revenue
* Average Delivery Time
* Shipping Cost
* Customer Rating

---

# mart_financial_impact

## Business Purpose

Summarizes logistics related financial performance.

## Grain

Executive summary.

## Primary Business Users

* Finance
* Executive Leadership

## Example KPIs

* Total Revenue
* Total Shipping Cost
* Average Shipping Cost
* Logistics Cost %
* Delayed Shipment Cost
* On Time Shipment Cost

---

# Warehouse Platform

The Marketplace Logistics Intelligence Platform combines multiple modern analytics technologies.

| Component | Technology |
|------------|------------|
| Storage | Parquet |
| Warehouse | DuckDB |
| Transformation | dbt Core |
| Orchestration | GitHub Actions |
| Containerization | Docker |
| Business Output | Gold Business Marts |
| Dashboard Layer | Dashboard Visualization (Power BI, Streamlit, HTML, etc.) |

---

# Data Lineage

The complete data lineage follows the ELT workflow below.

```text
GitHub Actions (CI/CD)

        │

        ▼

Bronze Parquet Files

        │

        ▼

load_bronze.py

        │

        ▼

DuckDB Bronze Tables

        │

        ▼

dbt debug

        │

        ▼

dbt build

        │

        ▼

Silver Layer

        │

        ▼

Gold Business Marts

        │

        ▼

export_gold_marts.py

        │

        ▼

CSV Business Marts

        │

        ▼

Dashboard Visualization
```

---

# Data Ownership

| Dataset | Business Owner |
|----------|----------------|
| Customers | Customer Operations |
| Sellers | Marketplace Operations |
| Products | Product Management |
| Warehouses | Warehouse Operations |
| Carriers | Logistics Operations |
| Orders | Sales Operations |
| Shipments | Logistics Operations |
| Tracking Events | Delivery Operations |
| Gold Business Marts | Enterprise Analytics |

---

# Business Rules

The warehouse follows governed business definitions to ensure consistent reporting.

## Customer History

Historical customer attributes are preserved using Slowly Changing Dimension Type 2.

---

## Carrier History

Historical carrier SLA configurations are preserved using Slowly Changing Dimension Type 2.

---

## Shipment KPIs

Delivery performance metrics are calculated only for completed shipments.

---

## Financial Metrics

Revenue and logistics costs are calculated from governed Gold marts rather than raw operational tables.

---

## Dashboard Consumption

Business users consume only Gold Business Marts.

Operational investigations and root cause analysis are performed using Silver dimensions and facts.

---

# Naming Conventions

| Prefix | Meaning |
|---------|----------|
| stg_ | Staging Model |
| dim_ | Dimension Table |
| fct_ | Fact Table |
| mart_ | Gold Business Mart |

---

# Summary

The Marketplace Logistics Intelligence Platform implements a production style Analytics Engineering architecture built on DuckDB, dbt Core, GitHub Actions, and Docker.

The warehouse contains:

* **11 Bronze operational datasets**
* **7 reusable dimension tables**
* **4 transactional fact tables**
* **6 governed Gold business marts**

Data flows through an automated CI/CD pipeline using GitHub Actions and Docker:

**GitHub Actions (CI/CD) → load_bronze.py → dbt debug → dbt build → export_gold_marts.py**

The resulting Gold Business Marts provide trusted datasets for dashboard visualization, executive reporting, KPI monitoring, and business decision making while maintaining complete traceability back to the original operational data.