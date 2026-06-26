# PROJECT_ARCHITECTURE

# Marketplace Logistics Intelligence Platform

End to End Analytics Engineering Project using a modern Medallion Architecture to identify the root causes of delivery delays, SLA breaches, warehouse bottlenecks, carrier performance issues, and logistics cost inefficiencies.

---

# Project Objective

This project simulates an enterprise scale ecommerce logistics platform where millions of logistics events are transformed into business ready datasets for analytics.

The platform answers key operational questions such as:

* Which carriers contribute most to SLA breaches?
* Which warehouses create dispatch bottlenecks?
* Which regions experience the highest delivery delays?
* What is the financial impact of logistics failures?
* Which sellers are most affected by logistics performance?

The project follows a Medallion Architecture with Bronze, Silver, and Gold layers.

---

# Architecture Overview

```
                      Python Data Generator
                              │
                              ▼
                     Bronze Layer (Parquet)
                Raw Synthetic Operational Data
                              │
                              ▼
                  DuckDB Bronze Views (dbt Sources)
                              │
                              ▼
                  Silver Layer (dbt Transformations)

            Staging Models
                    │
                    ▼
            Dimension Models
                    │
                    ▼
               Fact Models
                    │
                    ▼
             Data Quality Validation
                    │
                    ▼
               Gold Business Marts
                    │
                    ▼
                 Power BI Dashboard
```

---

# Technology Stack

| Layer | Technology |
|----------|------------|
| Data Generation | Python |
| Storage | Parquet |
| Development Warehouse | DuckDB |
| Analytics Engineering | dbt Core |
| Version Control | Git |
| Reporting | Power BI |
| IDE | VS Code |

---

# Medallion Architecture

## Bronze Layer

Purpose

Store raw source data exactly as generated.

Characteristics

* Immutable
* No transformations
* No business rules
* Source of truth
* Stored as Parquet files

Datasets

* Orders
* Order Items
* Shipments
* Tracking Events
* Customers
* Sellers
* Warehouses
* Products
* Carriers
* Date Dimension

---

## Silver Layer

Purpose

Clean, standardize, and validate operational data while preserving intentional data quality issues.

Transformations

* Data type standardization
* Schema enforcement
* Business rule alignment
* SCD Type 2 implementation
* Key validation
* Data quality auditing

Important Design Decision

The Silver layer intentionally retains known data quality issues.

Examples include:

* Orphan customer orders
* Future dated orders
* Null product IDs
* Negative quantities
* Null warehouse assignments
* Duplicate tracking events
* Future tracking timestamps

These anomalies simulate real enterprise operational systems and improve interview realism.

---

## Gold Layer

Purpose

Create business ready marts optimized for reporting and decision making.

Business rules are applied here to ensure KPIs are calculated using governed data.

Completed Gold Marts

* mart_logistics_overview
* mart_carrier_performance
* mart_warehouse_performance
* mart_region_performance
* mart_seller_performance
* mart_financial_impact

Future Optional Marts

* mart_returns_analysis
* mart_customer_analysis

These will only be added if supported by available data and aligned with the project scope.

---

# Silver Layer Model Flow

```
Bronze Sources

        │

        ▼

Staging Models

stg_orders
stg_order_items
stg_shipments
stg_tracking_events

        │

        ▼

Dimension Models

dim_customers
dim_carriers
dim_products
dim_sellers
dim_warehouses
dim_date

        │

        ▼

Fact Models

fct_orders
fct_order_items
fct_shipments
fct_tracking_events

        │

        ▼

Gold Business Marts
```

---

# Gold Layer Business Flow

```
Fact Tables
        │
        ▼
Business Aggregations
        │
        ▼
KPI Calculations
        │
        ▼
Business Marts
        │
        ▼
Power BI Dashboards
```

---

# Git Workflow

Every feature follows the same workflow.

```
main

      │

      ▼

Create Feature Branch

      │

      ▼

Develop Gold Mart

      │

      ▼

dbt Run

      │

      ▼

dbt Test

      │

      ▼

SnowFlake Validation

      │

      ▼

Git Commit

      │

      ▼

Merge into Main
```

---

# Data Quality Strategy

The project intentionally separates operational data quality from business reporting.

Bronze

Raw operational data.

Silver

Validated and standardized data with intentional anomalies preserved.

Gold

Business metrics calculated using governed business rules.

This mirrors enterprise data warehouse practices where operational history remains traceable while business reporting remains accurate.

---

# Business Problems Addressed

Carrier Performance

* SLA breach analysis
* Carrier reliability
* Shipping performance

Warehouse Operations

* Dispatch bottlenecks
* Warehouse utilization
* Processing efficiency

Regional Logistics

* Regional delivery delays
* Geographic logistics performance
* Cost by region

Seller Operations

* Revenue contribution
* Logistics performance
* Shipping efficiency

Financial Impact

* Cost of SLA breaches
* Shipping expenditure
* Operational logistics costs

---

# Project Status

| Layer | Status |
|----------|--------|
| Bronze | Complete |
| Silver | Complete |
| Gold | Complete |
| Power BI | In Progress |
| Documentation | In Progress |

---

# Architecture Principles

* Layered Medallion Architecture
* Modular dbt models
* Business driven Gold marts
* Reproducible transformations
* Version controlled development
* Data quality transparency
