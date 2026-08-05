# Marketplace Logistics Intelligence Platform

## Dimensional Data Model

---

# Purpose

This document describes the logical and physical dimensional data model used in the Marketplace Logistics Intelligence Platform.

The platform follows a modern Medallion Architecture combined with a Star Schema dimensional warehouse.

The pipeline transforms raw marketplace logistics data through Bronze, Silver, and Gold layers before producing business ready datasets for dashboard visualization.

---

# Data Warehouse Architecture

```text
                Bronze Layer
        (11 Raw Parquet Datasets)

                    │

                    ▼

               Silver Layer

      Staging → Dimensions → Facts

                    │

                    ▼

              Gold Business Marts

                    │

                    ▼

        Dashboard Visualization
```

---

# Technology Stack

| Layer | Technology |
|---------|------------|
| Bronze | Python + Parquet |
| Warehouse | DuckDB |
| Transformations | dbt Core |
| Orchestration | GitHub Actions |
| Deployment | Docker |
| Reporting | Dashboard Visualization |

---

# Modeling Approach

The warehouse follows a Star Schema consisting of reusable dimensions and transactional fact tables.

```text
                Dimension Tables

Customers
Products
Sellers
Carriers
Warehouses
Regions
Date

            │

            ▼

           Fact Tables

Orders
Order Items
Shipments
Tracking Events

            │

            ▼

          Gold Marts

Executive Overview

Carrier Performance

Warehouse Performance

Region Performance

Seller Performance

Financial Impact
```

---

# Bronze Layer

The Bronze layer contains immutable raw operational datasets stored as Parquet files.

Current datasets

* Customers
* Products
* Sellers
* Orders
* Order Items
* Shipments
* Tracking Events
* Warehouses
* Regions
* Carriers
* Date

Total Bronze datasets

**11**

---

# Silver Layer

The Silver layer represents the enterprise dimensional warehouse.

It contains reusable staging models, dimensions, and fact tables.

---

# Staging Models

Responsibilities

* Standardize column names
* Data type conversion
* Basic cleaning
* Prepare reusable datasets

---

# Dimension Tables

Dimension tables describe business entities.

| Dimension | Grain |
|------------|--------|
| dim_customers | One row per customer |
| dim_products | One row per product |
| dim_sellers | One row per seller |
| dim_carriers | One row per carrier |
| dim_warehouses | One row per warehouse |
| dim_regions | One row per region |
| dim_date | One row per calendar date |

Total Dimensions

**7**

---

# Fact Tables

Fact tables capture measurable business events.

---

## fct_orders

Grain

One row per order

Measures

* Order Amount
* Shipping Fee
* Discount
* Net Amount

Dimensions

* Customer
* Date

---

## fct_order_items

Grain

One row per product purchased

Measures

* Quantity
* Revenue
* Unit Price

Dimensions

* Product
* Seller
* Order

---

## fct_shipments

Grain

One row per shipment

Measures

* Shipping Cost
* Transit Days
* Delay Days
* Shipment Weight
* SLA Breach

Dimensions

* Carrier
* Warehouse
* Region
* Order

---

## fct_tracking_events

Grain

One row per shipment event

Measures

* Operational Events

Dimensions

* Shipment
* Carrier
* Date

Total Fact Tables

**4**

---

# Entity Relationship

```text
dim_customers
        │
        ▼
fct_orders
        │
        ▼
fct_order_items
      ┌─┴─────────────┐
      ▼               ▼
dim_products     dim_sellers
        │
        ▼
fct_shipments
 ┌─────┼──────────┬─────────┐
 ▼     ▼          ▼         ▼
Carrier Warehouse Region Order
        │
        ▼
fct_tracking_events
```

---

# Slowly Changing Dimensions

Historical tracking is implemented using SCD Type 2 where appropriate.

| Dimension | Type |
|------------|------|
| Customers | SCD Type 2 |
| Carriers | SCD Type 2 |

---

# Gold Layer

Gold marts aggregate Silver facts into business ready analytical datasets.

| Gold Mart | Grain |
|------------|--------|
| mart_logistics_overview | One row per calendar date |
| mart_carrier_performance | One row per carrier |
| mart_warehouse_performance | One row per warehouse |
| mart_region_performance | One row per region |
| mart_seller_performance | One row per seller |
| mart_financial_impact | Executive KPI summary |

Total Gold Marts

**6**

---

# Business Event Flow

```text
Customer

      │

      ▼

Order Created

      │

      ▼

Order Items Created

      │

      ▼

Shipment Generated

      │

      ▼

Tracking Events Recorded

      │

      ▼

Shipment Delivered

      │

      ▼

Business Marts Generated

      │

      ▼

Dashboard Visualization
```

---

# Pipeline Integration

The warehouse is refreshed through an automated CI/CD pipeline using GitHub Actions and Docker.

```text
GitHub Actions (CI/CD)

        │

        ▼

load_bronze.py

        │

        ▼

dbt debug

        │

        ▼

dbt build

        │

        ▼

export_gold_marts.py

        │

        ▼

Dashboard Visualization
```

---

# Design Decisions

## Star Schema

Chosen for

* Fast analytical queries
* Simple joins
* Business friendly reporting

---

## Surrogate Keys

Used where historical tracking is required.

---

## Fact Separation

Orders, shipments, order items, and tracking events represent independent business processes.

---

## Gold Marts

Designed around business domains rather than transactional detail.

---

# Summary

The Marketplace Logistics Intelligence Platform implements a modern dimensional warehouse using DuckDB and dbt.

The solution transforms 11 raw Bronze datasets into 7 reusable dimensions, 4 transactional fact tables, and 6 business ready Gold marts.

An automated CI/CD pipeline using GitHub Actions and Docker orchestrates the complete ELT pipeline. The resulting datasets support dashboard visualization and executive analytics through a scalable Analytics Engineering architecture.