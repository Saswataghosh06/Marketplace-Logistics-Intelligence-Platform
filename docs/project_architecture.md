# PROJECT_ARCHITECTURE.md

# Marketplace Logistics Intelligence Platform

## End to End Analytics Engineering Project

An enterprise style Analytics Engineering project that simulates a large scale e commerce marketplace logistics platform. The project follows a modern Medallion Architecture using Python, DuckDB, dbt Core, and Power BI to transform raw operational data into trusted business ready datasets for executive reporting and operational decision making.

The platform is designed to investigate the root causes of delivery delays, SLA breaches, warehouse bottlenecks, carrier performance issues, and logistics cost inefficiencies across the complete order fulfillment lifecycle.

---

# Business Problem

Large e commerce marketplaces rely on multiple sellers, warehouses, and third party logistics providers to fulfill customer orders. As shipment volume increases, operational visibility becomes increasingly difficult.

Leadership has observed:

* Increasing SLA breaches
* Rising shipping costs
* Delayed deliveries
* Uneven carrier performance
* Warehouse congestion
* Regional delivery inconsistencies

However, existing operational systems only provide isolated transactional data and do not explain why these problems occur.

The objective of this project is to build an analytics platform capable of transforming raw logistics events into business ready insights that support operational and strategic decision making.

---

# Business Objectives

The platform is designed to answer the following business questions.

## Carrier Performance

* Which carriers contribute the highest number of SLA breaches?
* Which carrier has the longest average transit time?
* Which carrier has the highest shipping cost per kilogram?
* Which carriers consistently meet delivery commitments?

## Warehouse Performance

* Which warehouses create dispatch bottlenecks?
* Which warehouses experience the highest delivery delays?
* Which fulfillment centers generate the highest logistics costs?
* How does warehouse performance differ across regions?

## Regional Operations

* Which customer regions experience the poorest delivery performance?
* Which regions generate the highest shipping costs?
* How do delivery delays vary geographically?

## Seller Operations

* Which sellers generate the largest shipment volumes?
* Which sellers experience the highest logistics risk?
* Which seller segments are most affected by SLA breaches?

## Executive Logistics

* How is the logistics network performing over time?
* What are the key operational KPIs?
* Where should leadership prioritize operational improvements?

## Financial Impact

* What is the total cost of logistics operations?
* What percentage of shipping spend is associated with delayed deliveries?
* What is the financial impact of SLA breaches?

---

# Solution Overview

The project implements an end to end Analytics Engineering workflow that converts raw operational data into trusted analytical datasets.

The architecture follows the Medallion pattern:

```
Python Synthetic Data Generator

            │

            ▼

      Bronze Layer
   Raw Operational Data

            │

            ▼

      Staging Models
   Schema Standardization

            │

            ▼

 Dimension Models + Fact Models

            │

            ▼

     Data Quality Testing

            │

            ▼

      Gold Business Marts

            │

            ▼

 Power BI Executive Dashboards
```

---

# Technology Stack

| Layer               | Technology  | Purpose                                |
| ------------------- | ----------- | -------------------------------------- |
| Data Generation     | Python      | Generate realistic logistics datasets  |
| Raw Storage         | Parquet     | Immutable source data                  |
| Analytical Database | DuckDB      | Local analytical warehouse             |
| Transformation      | dbt Core    | SQL based data transformation          |
| Data Modeling       | Star Schema | Business oriented dimensional modeling |
| Data Quality        | dbt Tests   | Automated validation and governance    |
| Visualization       | Power BI    | Executive dashboards                   |
| Version Control     | Git         | Source code management                 |
| Development         | VS Code     | Development environment                |

---

# Medallion Architecture

## Bronze Layer

### Purpose

The Bronze layer stores raw operational data exactly as generated.

No transformations or business rules are applied.

The objective is to preserve the original source data for auditability and reproducibility.

### Characteristics

* Immutable source data
* Raw business events
* No cleansing
* No filtering
* Historical traceability
* Source of truth

### Bronze Datasets

* Orders
* Order Items
* Shipments
* Tracking Events
* Customers (SCD Type 2)
* Carriers (SCD Type 2)
* Sellers
* Warehouses
* Products
* Date Dimension

---

## Silver Layer

### Purpose

The Silver layer transforms raw operational data into standardized business entities while preserving operational history and known data quality issues.

This layer forms the enterprise data warehouse.

### Responsibilities

* Standardize schemas
* Apply business friendly column names
* Enforce data types
* Build dimension tables
* Build fact tables
* Implement Slowly Changing Dimensions
* Preserve operational anomalies
* Create reusable analytical models

### Silver Model Structure

```
Bronze Sources

        │

        ▼

Staging Models

        │

        ▼

Dimension Models

        │

        ▼

Fact Models
```

### Dimension Tables

* dim_customers
* dim_carriers
* dim_products
* dim_sellers
* dim_warehouses
* dim_date

### Fact Tables

* fct_orders
* fct_order_items
* fct_shipments
* fct_tracking_events

---

## Gold Layer

### Purpose

The Gold layer contains business ready marts optimized for reporting, KPI monitoring, and executive dashboards.

Unlike the Silver layer, Gold models aggregate operational events into trusted business metrics.

Each mart answers a specific business question.

### Gold Business Marts

| Gold Mart                  | Primary Business Purpose                 |
| -------------------------- | ---------------------------------------- |
| mart_logistics_overview    | Executive logistics KPI monitoring       |
| mart_carrier_performance   | Carrier SLA analysis                     |
| mart_warehouse_performance | Warehouse bottleneck analysis            |
| mart_region_performance    | Regional delivery analysis               |
| mart_seller_performance    | Seller logistics analysis                |
| mart_financial_impact      | Financial impact of logistics operations |

---

# Data Flow

```
Python

        │

        ▼

Parquet Files

        │

        ▼

Bronze Sources

        │

        ▼

Staging Models

        │

        ▼

Dimensions

        │

        ▼

Facts

        │

        ▼

Gold Business Marts

        │

        ▼

Power BI Dashboards
```

---

# Data Quality Strategy

The architecture separates operational data from business reporting.

## Bronze

Stores raw data exactly as received.

## Silver

Standardizes data while intentionally preserving realistic operational anomalies including:

* Missing warehouse assignments
* Orphan customer references
* Duplicate tracking events
* Future dated transactions
* Missing product references
* Negative quantities

These anomalies simulate real production systems and support realistic analytics engineering scenarios.

## Gold

Business rules are applied to produce trusted KPIs without modifying operational history.

Examples include:

* Excluding future dated records from trend analysis
* Ignoring incomplete warehouse assignments for warehouse reporting
* Calculating transit metrics only for delivered shipments
* Preventing double counting in seller shipment allocation

---

# Analytics Engineering Principles

The project follows modern Analytics Engineering best practices.

* Modular dbt models
* Layered Medallion Architecture
* Star schema dimensional modeling
* Reusable dimensions
* Business driven fact tables
* Automated data quality testing
* Version controlled transformations
* Business ready KPI marts
* Clear data lineage
* Reproducible pipelines

---

# Business Value

The completed platform enables stakeholders to:

* Monitor logistics KPIs through executive dashboards
* Identify operational bottlenecks
* Compare carrier performance
* Evaluate warehouse efficiency
* Analyze regional delivery performance
* Measure seller logistics performance
* Quantify the financial impact of delivery failures
* Support data driven operational decisions

---

# Current Project Status

| Component              | Status      |
| ---------------------- | ----------- |
| Python Data Generation | Complete    |
| Bronze Layer           | Complete    |
| Silver Layer           | Complete    |
| Data Quality Testing   | Complete    |
| Gold Business Marts    | Complete    |
| dbt Documentation      | Complete    |
| Power BI Dashboard     | In Progress |
| Project Documentation  | In Progress |

---

# Repository Workflow

```
Python Data Generation

        │

        ▼

Bronze Layer

        │

        ▼

dbt Staging

        │

        ▼

Dimensions

        │

        ▼

Facts

        │

        ▼

Gold Business Marts

        │

        ▼

dbt Tests

        │

        ▼

Power BI

        │

        ▼

Business Insights
```

---

# Architecture Summary

The Marketplace Logistics Intelligence Platform demonstrates a complete Analytics Engineering workflow from raw operational data to executive decision support.

The architecture separates raw ingestion, business transformations, governed analytical models, and reporting into independent layers, ensuring scalability, maintainability, traceability, and consistent KPI definitions.

The final platform provides a production inspired foundation for logistics analytics, enabling root cause analysis of delivery performance, operational efficiency, and financial impact across carriers, warehouses, sellers, and regions.
