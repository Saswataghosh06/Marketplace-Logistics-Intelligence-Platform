# Marketplace Logistics Intelligence Platform

## Repository Structure

---

# Purpose

This document explains how the project repository is organized and why each component exists.

The repository follows a modular Analytics Engineering workflow where every stage of the data lifecycle is separated into independent, reusable components.

This structure improves:

* Maintainability
* Collaboration
* Version control
* Testing
* Documentation
* Production readiness

---

# Repository Overview

<details>
<summary><b>📂 Click to expand: Directory Structure</b></summary>

```text
marketplace-logistics-intelligence-platform/

│
├── data/
│   ├── bronze/(python generated raw synthetic parquet datasets) 
│   └── gold/(exported CSV files)
│
├── .github/
│   └── workflows/ (GitHub Actions CI/CD pipelines)
│
├── notebooks/
│
├── python/
│   ├── generators/
│   ├── exports/
│   └── utilities/
│
├── warehouse/
│   └── logistics.duckdb
│
├── dbt/
│   └── logistics_project/
│
├── docs/
│
├── dashboards/
│
├── images/
├── README.md
└── requirements.txt
```

</details>

---

# Python

## Purpose

Responsible for synthetic data generation and export.

The Python layer simulates a real marketplace logistics platform by generating realistic operational data before loading it into the warehouse.

Typical responsibilities include:

* Customer generation
* Order generation
* Shipment simulation
* Tracking event generation
* Carrier simulation
* Warehouse simulation
* Export to Parquet

---

# Data

## Purpose

Stores generated datasets before ingestion into DuckDB.

### raw/

Contains intermediate generated files.

### bronze/

Contains immutable Parquet files loaded by dbt sources.

---

# Warehouse

## logistics.duckdb

Acts as the analytical warehouse.

Responsibilities include:

* Bronze schemas
* Silver warehouse
* Gold marts
* Query execution
* Power BI connection

---

# dbt Project

The dbt project contains all transformation logic.

<details>
<summary><b>📂 Click to expand: dbt Models Structure</b></summary>

```text
models/

    bronze/

    silver/

        staging/

        dimensions/

        facts/

    gold/

    sources.yml

    schema.yml
```

</details>

---

# Bronze Models

Purpose

Expose raw Parquet files as source tables.

Characteristics

* No transformations
* Source definitions only

---

# Silver Models

Purpose

Create reusable analytical datasets.

## Staging

Responsibilities

* Rename columns
* Standardize data types
* Basic cleaning
* Preserve operational history

---

## Dimensions

Reusable business entities.

Examples

* Customers
* Carriers
* Products
* Sellers
* Warehouses
* Date

---

## Facts

Business events.

Examples

* Orders
* Order Items
* Shipments
* Tracking Events

---

# Gold Models

Purpose

Produce business ready analytical marts.

Current marts include:

* mart_logistics_overview
* mart_carrier_performance
* mart_warehouse_performance
* mart_region_performance
* mart_seller_performance
* mart_financial_impact

These marts are optimized for Power BI.

---

# Documentation

The docs directory contains project documentation.

Current documentation includes:

* Project Architecture
* Data Model
* Data Dictionary
* Data Quality Report
* Gold Layer Business Marts
* Repository Structure

Future documentation may include:

* Dashboard Guide
* Business Glossary
* KPI Definitions
* Validation Guide

---

# Dashboards

Contains exported Power BI assets.

Typical contents:

* PBIX file
* Dashboard screenshots
* Executive presentation images

---

# Images

Stores visual assets used throughout documentation.

Examples:

* Architecture diagrams
* Star schema diagrams
* Dashboard previews
* Data flow illustrations

---

# Tests

Validation assets.

Includes:

* dbt tests
* Business validation SQL
* KPI reconciliation queries

---

# Pipeline & Orchestration

The codebase is governed by an automated CI/CD pipeline using GitHub Actions and Docker.

<details>
<summary><b>📂 Click to expand: Pipeline Flow</b></summary>

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
```

</details>

---

# Development Workflow

Every feature follows the same lifecycle.

<details>
<summary><b>📂 Click to expand: Development Workflow</b></summary>

```text
Generate Data

        │

        ▼

Export Parquet

        │

        ▼

Load Bronze

        │

        ▼

Build Silver

        │

        ▼

Run dbt Tests

        │

        ▼

Build Gold

        │

        ▼

Validate KPIs

        │

        ▼

Power BI Dashboard

        │

        ▼

Documentation

        │

        ▼

Git Commit
```

</details>

---

# Design Principles

The repository follows several engineering principles.

## Modular

Each component has a single responsibility.

## Reusable

Dimensions and facts can support multiple downstream marts.

## Testable

Every transformation is validated through automated dbt tests.

## Documented

Every major component has supporting documentation.

## Scalable

New business marts can be added without changing the existing warehouse design.

---

# Summary

The repository is organized using modern Analytics Engineering practices that separate data generation, storage, transformation, governance, reporting, and documentation into clearly defined components.

This structure supports reproducible development, reliable analytics, and straightforward collaboration while remaining easy to extend for future business requirements.