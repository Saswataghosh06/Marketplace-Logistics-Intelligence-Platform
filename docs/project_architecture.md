# Project Architecture

## Overview

The Logistics Analytics Platform follows a modern Medallion Architecture combined with production-style orchestration using an automated CI/CD pipeline with GitHub Actions and Docker.

The architecture is designed to separate raw ingestion, business transformations, orchestration, and reporting into independent layers.

The complete pipeline is automated from data ingestion through business-ready analytics.

---

# High Level Architecture

<details>
<summary><b>📂 Click to expand: High Level Architecture Flow</b></summary>

```text
                    Source Dataset (Parquet) [Synthetic Raw Dataset generated via Python]
                          │
                          ▼
                Stored in Data/Bronze folder
                          │
                          ▼
              load_bronze.py (Python)
                          │
                          ▼
──────────────────────────────────────────────────────
                Bronze Layer (Parquet)
──────────────────────────────────────────────────────
Customers.parquet
Orders.parquet
Order_Items.parquet
Products.parquet
Shipments.parquet
Tracking_Events.parquet
Warehouses.parquet
Regions.parquet
Carriers.parquet
Sellers.parquet

                          │
                          ▼

                    dbt debug
                          │
                          ▼

                    dbt build
                          │
                          ▼

──────────────────────────────────────────────────────
             Silver Layer (DuckDB + dbt)
──────────────────────────────────────────────────────

Staging Models
    │
    ├── stg_orders
    ├── stg_order_items
    ├── stg_shipments
    └── stg_tracking_events

Dimension Models
    │
    ├── dim_customers
    ├── dim_products
    ├── dim_regions
    ├── dim_sellers
    ├── dim_carriers
    ├── dim_warehouses
    └── dim_date

Fact Models
    │
    ├── fct_orders
    ├── fct_order_items
    ├── fct_shipments
    └── fct_tracking_events

                          │
                          ▼

──────────────────────────────────────────────────────
                Gold Layer (Business Marts)
──────────────────────────────────────────────────────

mart_logistics_overview
mart_carrier_performance
mart_region_performance
mart_seller_performance
mart_warehouse_performance
mart_financial_impact

                          │
                          ▼

export_gold_marts.py

                          │
                          ▼

CSV Exports
data/gold/

                          │
                          ▼

Dashboard Layer

Power BI
or

HTML / Streamlit Dashboard
```

</details>

---

# Environment Portability

To ensure the pipeline is reproducible across development (Windows) and production (Linux/Docker) environments, the architecture implements environment-agnostic configuration. By leveraging environment variables for file paths, the dbt transformation layer dynamically adapts to the host system without requiring manual code changes.

---

# Data Contracts (Quality Gates)

Data quality is enforced via dbt Tests defined in YAML schemas. These tests act as a "contract" for downstream consumers.

Unique/Not-Null: Assert primary keys and mandatory fields.

Relationships: Ensure referential integrity between Fact and Dimension tables.

Accepted Values: Validate categorical fields (e.g., status, payment methods) to prevent data drift.

Medallion Architecture Layers
Bronze (Ingestion): Raw, immutable Parquet files. Serves as the immutable source of truth.

Silver (Warehouse): Standardized, cleaned, and modeled data. Implements Star Schema and SCD Type 2 dimensions for historical tracking.

Gold (Marts): Aggregated, business-logic-ready datasets. Each mart is optimized to answer specific business KPIs (e.g., mart_carrier_performance).

---

---

# CI/CD Orchestration

The codebase is governed by an automated CI/CD pipeline using GitHub Actions and Docker.

Pipeline execution order

<details>
<summary><b>📂 Click to expand: Pipeline Execution Flow</b></summary>

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

Each task executes only after the previous task completes successfully.

---

# Docker Architecture

<details>
<summary><b>📂 Click to expand: Docker & CI/CD Architecture</b></summary>

```text
GitHub Actions (CI/CD)
│
└── Docker Container (ubuntu-latest)
       │
       ├── Checkout Repository
       │
       ├── Install Dependencies
       │      (dbt-duckdb, duckdb, pandas, pyarrow)
       │
       └── Execute Pipeline Steps
              │
              ├── python scripts/load_bronze.py
              ├── dbt debug
              ├── dbt build
              └── python scripts/export_gold_marts.py
```

</details>

---

# Data Flow

<details>
<summary><b>📂 Click to expand: Data Flow Diagram</b></summary>

```text
Parquet Datasets

↓

Bronze Parquet Files

↓

Silver SQL ETL (In DBT-Core)

↓

dbt  Staging

↓

dbt SQL Dimensions

↓

dbt Facts

↓

Gold Business Marts

↓

Gold CSV Exports

↓

Dashboard
```

</details>

---

# Technology Stack

| Layer | Technology |
|---------|------------|
| Programming | Python / SQL |
| Warehouse | DuckDB |
| Transformation | dbt Core |
| Governance | Yaml Schemas |
| Orchestration | GitHub Actions |
| Containers | Docker |
| Data Format | Parquet |
| Output | CSV |
| Dashboard | Power BI / HTML / Streamlit |
| Versioning | Git |

---

# Folder Responsibilities

<details>
<summary><b>📂 Click to expand: Folder Structure</b></summary>

```text
scripts/
│
├── load_bronze.py
└── export_gold_marts.py

dbt/
└── logistics_project/
      ├── staging/
      ├── dimensions/
      ├── facts/
      └── marts/

warehouse/
└── logistics.duckdb

data/
├── bronze/
└── gold/

.github/
└── workflows/
      └── logistics_pipeline.yml
```

</details>

---

# Design Principles

• Modular ETL design

• Medallion Architecture

• Star Schema Modeling

• Idempotent pipeline execution

• Automated orchestration

• Containerized deployment

• Separation of ingestion, transformation and presentation

• Business-ready analytical marts

• Reproducible local development environment

• Production-oriented project structure