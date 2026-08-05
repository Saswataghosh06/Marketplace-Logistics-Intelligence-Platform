<div align="center">
  <img width="1584" height="396" alt="Image" src="https://github.com/user-attachments/assets/a7cb70aa-ec82-470f-98f8-026edcc05e53" />
</div>

<h1 align="center">Marketplace Logistics Intelligence Platform</h1>
<h3 align="center">Self-Generated 500K Shipment Dataset · Medallion Pipeline on DuckDB · 6 Gold Marts</h3>

<p align="center">
  <img alt="status" src="https://img.shields.io/badge/status-portfolio_case_study-1E56C7">
  <img alt="data" src="https://img.shields.io/badge/data-synthetic_%2F_self_generated-8B98AE">
  <img alt="stack" src="https://img.shields.io/badge/stack-dbt_%7C_DuckDB_%7C_GitHub_Actions_%7C_Docker-1E56C7">
  <img alt="quality" src="https://img.shields.io/badge/data_quality-0_nulls_%7C_0_duplicates-12A879">
</p>

<p align="center"><b>Saswata Ghosh</b><br>
<a href="https://github.com/Saswataghosh06/Marketplace-Logistics-Intelligence-Platform">GitHub Repo</a> · <a href="https://www.linkedin.com/in/saswata-ghosh06/">LinkedIn</a> · <a href="saswataghosh2022@gmail.com">Email</a></p>

---

## Overview

A Medallion Architecture data pipeline that ingests a self-generated ~500K-shipment synthetic logistics dataset into DuckDB, models it into a star schema with 7 dimensions and 4 fact tables using dbt Core, and delivers 6 business-ready Gold marts for carrier, warehouse, region, seller, financial, and enterprise-wide analytics. The codebase is governed by an automated CI/CD pipeline using GitHub Actions and Docker, and includes SCD Type 2 tracking on customers and carriers.

The dataset was designed to simulate real operational mess — missing references, late-arriving records, duplicate events, future-dated transactions — and the pipeline handles each case explicitly rather than silently dropping rows.

On the analytical side, the pipeline surfaced that premium carriers cost 5.8× more per kg than economy carriers for statistically identical SLA reliability, and that no financial penalty exists for a breached delivery. Full business analysis with recommendations → [`docs/business_insights.md`](./docs/business_insights.md)

---

## Architecture

<div align="center">
<img width="2816" height="976" alt="Image" src="https://github.com/user-attachments/assets/0317f4aa-37fc-48bb-9195-982dd6938303" />
</div>

| Layer | Purpose | Materialization | Storage |
|---|---|---|---|
| **Bronze** | Immutable raw Parquet ingestion | Table | Parquet files → DuckDB |
| **Silver** | Staging + Star Schema (7 dims, 4 facts) | Table | DuckDB |
| **Gold** | Business-ready analytical marts | Table | DuckDB → CSV exports |

**Pipeline flow:**

```
GitHub Actions (CI/CD) → load_bronze.py → dbt debug → dbt build → export_gold_marts.py
```

**Source datasets (11 Bronze tables):**

| Dataset | Business Entity |
|---|---|
| customers_scd | Customer master with SCD Type 2 history |
| carriers_scd | Carrier master with SCD Type 2 history |
| sellers | Marketplace seller master data |
| products | Product catalog |
| warehouses | Warehouse master data |
| regions | Geographic delivery regions |
| date_dimension | Calendar dimension |
| orders | Customer order transactions |
| order_items | Products purchased within each order |
| shipments | Shipment lifecycle information |
| tracking_events | Shipment tracking history |

---

## Data Model

### Star Schema

<div align="center">

</div>

### Dimensions

| Model | Primary Key | Grain | Notes |
|---|---|---|---|
| `dim_customers` | `customer_sk` | One row per customer version | SCD Type 2 — tracks profile changes over time |
| `dim_carriers` | `carrier_sk` | One row per carrier version | SCD Type 2 — tracks SLA config changes over time |
| `dim_products` | `product_id` | One row per product | Product catalog with category and brand |
| `dim_sellers` | `seller_id` | One row per seller | Marketplace seller with tier and rating |
| `dim_warehouses` | `warehouse_id` | One row per warehouse | Warehouse with capacity and rating |
| `dim_regions` | `region_id` | One row per region | Geographic reporting regions |
| `dim_date` | `date_key` | One row per calendar date | Generated calendar dimension |

### Fact Tables

| Model | Primary Key | Grain | Key Measures |
|---|---|---|---|
| `fct_orders` | `order_id` | One row per order | Order amount, shipping fee, discount, net amount |
| `fct_order_items` | `order_item_id` | One row per line item | Quantity, unit cost, unit price, line revenue |
| `fct_shipments` | `shipment_id` | One row per shipment | Shipping cost, transit days, delay days, SLA breach flag |
| `fct_tracking_events` | `tracking_event_id` | One row per tracking event | Operational event status, exception flag |

### Gold Marts

| Mart | Grain | Business Domain |
|---|---|---|
| `mart_logistics_overview` | One row per calendar date | Enterprise-wide logistics KPIs |
| `mart_carrier_performance` | One row per carrier | Carrier SLA, transit time, cost efficiency |
| `mart_warehouse_performance` | One row per warehouse | Warehouse throughput, utilization, dispatch time |
| `mart_region_performance` | One row per region | Regional delivery performance and cost |
| `mart_seller_performance` | One row per seller | Seller fulfillment efficiency and SLA contribution |
| `mart_financial_impact` | Executive summary | Logistics cost, SLA financial impact, cost per kg |

### Key Modeling Decisions

| Decision | Why |
|---|---|
| **SCD Type 2 on `dim_customers` and `dim_carriers`** | Customer profiles and carrier SLA configurations change over time. Without historical tracking, period-over-period reporting would be inaccurate. Surrogate key (`customer_sk`, `carrier_sk`) allows multiple versions per entity. |
| **Unknown row in `dim_customers`** | Shipments with missing customer references are preserved in Silver but excluded from customer KPIs in Gold. The Unknown row (`customer_id = -1`) ensures referential integrity without silently dropping rows. |
| **Separate facts for orders, shipments, and tracking events** | Each represents an independent business process. Combining them into one table would create a messy grain and make KPIs unreliable. |
| **6 domain-specific marts instead of one big mart** | Each mart answers a specific business question for a specific audience. A single mart would duplicate logic and be harder to maintain. |
| **Tables everywhere (no views)** | DuckDB is an embedded engine — no shared compute cluster to worry about. Tables provide faster query performance for BI and guarantee consistent results between pipeline runs. |

### Sample Model: `dim_customers` (with Unknown row)

<details>
<summary><b>📂 Click to expand: dim_customers.sql</b></summary>

```sql
select
    customer_sk,
    customer_id,
    customer_name,
    email,
    phone,
    city,
    state,
    country,
    customer_segment,
    cast(signup_date as date) as signup_date,
    cast(effective_from as date) as effective_from,
    cast(effective_to as date) as effective_to,
    is_current,
    cast(created_at as timestamp) as created_at

from {{ source('bronze', 'dim_customers_scd') }}

union all

select
    -1 as customer_sk,
    -1 as customer_id,
    'Unknown Customer' as customer_name,
    null as email,
    null as phone,
    'Unknown' as city,
    'Unknown' as state,
    'Unknown' as country,
    'Unknown' as customer_segment,
    null as signup_date,
    cast('1900-01-01' as date) as effective_from,
    cast('9999-12-31' as date) as effective_to,
    true as is_current,
    current_timestamp as created_at
```

</details>

### Sample Model: `mart_financial_impact`

<details>
<summary><b>📂 Click to expand: mart_financial_impact.sql</b></summary>

```sql
{{ config(materialized = 'table') }}

with shipment_base as (
    select
        shipment_id,
        shipment_status,
        shipping_cost,
        shipment_weight_kg,
        actual_transit_days,
        delay_days,
        is_sla_breached
    from {{ ref('fct_shipments') }}
),

shipment_metrics as (
    select
        count(*) as total_shipments,
        count_if(shipment_status = 'Delivered') as delivered_shipments,
        count_if(shipment_status = 'Delivered' and is_sla_breached = false) as on_time_shipments,
        count_if(is_sla_breached) as sla_breached_shipments,
        round(100.0 * count_if(is_sla_breached) / nullif(count(*),0), 2) as sla_breach_pct,
        round(avg(case when shipment_status = 'Delivered' then actual_transit_days end), 2) as avg_transit_days,
        round(avg(case when shipment_status = 'Delivered' then delay_days end), 2) as avg_delay_days
    from shipment_base
),

financial_metrics as (
    select
        round(sum(shipping_cost), 2) as total_shipping_cost,
        round(avg(shipping_cost), 2) as avg_shipping_cost,
        round(sum(case when is_sla_breached then shipping_cost else 0 end), 2) as breached_shipping_cost,
        round(sum(case when shipment_status = 'Delivered' and is_sla_breached = false then shipping_cost else 0 end), 2) as on_time_shipping_cost,
        round(100.0 * sum(case when is_sla_breached then shipping_cost else 0 end) / nullif(sum(shipping_cost),0), 2) as breached_cost_pct,
        round(avg(case when is_sla_breached then shipping_cost end), 2) as avg_breached_shipping_cost,
        round(avg(case when shipment_status = 'Delivered' and is_sla_breached = false then shipping_cost end), 2) as avg_on_time_shipping_cost,
        round(sum(shipping_cost) / nullif(sum(shipment_weight_kg),0), 2) as shipping_cost_per_kg
    from shipment_base
)

select
    s.total_shipments,
    s.delivered_shipments,
    s.on_time_shipments,
    s.sla_breached_shipments,
    s.sla_breach_pct,
    s.avg_transit_days,
    s.avg_delay_days,
    f.total_shipping_cost,
    f.avg_shipping_cost,
    f.breached_shipping_cost,
    f.on_time_shipping_cost,
    f.breached_cost_pct,
    f.avg_breached_shipping_cost,
    f.avg_on_time_shipping_cost,
    f.shipping_cost_per_kg
from shipment_metrics s
cross join financial_metrics f
```

</details>

---

## Data Quality

The dataset was designed with intentional operational anomalies to simulate real production systems. The pipeline handles each case explicitly rather than silently dropping rows. Full audit → [`docs/data_quality_audit.md`](./docs/data_quality_audit.md)

### Intentional Anomalies & Handling

| Anomaly | Business Scenario | Silver Handling | Gold Handling |
|---|---|---|---|
| Missing customer reference | Delayed customer synchronization | Preserved | Excluded from customer KPIs via Unknown row |
| Missing warehouse assignment | Shipment not allocated | Preserved | Excluded from warehouse reporting |
| Future-dated orders | Clock synchronization issues | Preserved | Excluded from trend reporting |
| Future tracking events | Event ingestion timing | Preserved | Excluded from historical KPIs |
| Duplicate tracking events | Event replay | Preserved | Aggregated appropriately |
| Missing product references | Catalog synchronization failure | Preserved | Excluded from product-level reporting |
| Negative quantities | Transaction correction | Preserved | Excluded from revenue calculations |

### Validation Results (Gold Marts)

| Check | Result |
|---|---|
| Missing values across all 6 Gold marts | **0** |
| Duplicate records across all 6 Gold marts | **0** |
| Grain validated per mart | **Confirmed** — one row per entity |
| Referential integrity (Orders↔Customers, Shipments↔Carriers/Warehouses, etc.) | **Passed** via dbt tests |
| Business-rule bounds (utilization 0–100%, ratings 1–5, costs ≥ 0) | **Passed** via dbt tests |

### Gold-Mart Governance Rules

| Mart | Governance Rule |
|---|---|
| `mart_logistics_overview` | Filters invalid operational records, calculates executive KPIs |
| `mart_carrier_performance` | Uses delivered shipments only for SLA, transit time, and cost calculations |
| `mart_warehouse_performance` | Excludes shipments without warehouse assignment |
| `mart_region_performance` | Aggregates shipment performance by customer region |
| `mart_seller_performance` | Prevents duplicate shipment allocation across sellers |
| `mart_financial_impact` | Calculates logistics cost, SLA financial impact, and cost per kg |

---

## Pipeline & CI/CD

### CI/CD Workflow: `logistics_pipeline`

<div align="center">
<b>dbt Lineage Graph</b><br><sub>Bronze sources → staging → dimensions/facts → 6 Gold marts</sub><br><br>
<img width="1280" height="720" alt="Image" src="https://github.com/user-attachments/assets/01792c1f-c585-4fa7-8ae8-7cc1dda803a0" alt="dbt lineage graph" />
</div>

<details>
<summary><b>📂 Click to expand: GitHub Actions Workflow YAML</b></summary>

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  lint-python-code:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.9'

      - name: Install Flake8
        run: pip install flake8

      - name: Lint Scripts Folder
        # Using --exit-zero so minor formatting issues don't crash the pipeline tonight
        run: flake8 scripts/ --count --select=E9,F63,F7,F82 --show-source --statistics --exit-zero

  build-and-push-docker:
    needs: lint-python-code
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and Push Docker Image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ secrets.DOCKER_USERNAME }}/logistics-pipeline:latest

         
```

</details>

| Setting | Value |
|---|---|
| Schedule | Daily (cron: `0 0 * * *`) |
| Runner | Ubuntu (GitHub-hosted) |
| Containerized | Yes (Docker) |
| Trigger | Schedule + Manual dispatch |

### dbt Project Configuration

<details>
<summary><b>📂 Click to expand: dbt_project.yml</b></summary>

```yaml
models:
  logistics_project:
    silver:
      +materialized: table
      staging:
        +schema: silver
      dimensions:
        +schema: silver
      facts:
        +schema: silver
    gold:
      +materialized: table
      marts:
        +schema: gold
```

</details>

---

## Technical Decisions & Trade-offs

| Decision | Alternative Considered | Why This Choice |
|---|---|---|
| DuckDB | Snowflake / BigQuery | This project was originally built on Snowflake and migrated to DuckDB once trial access ran out. Same SQL ergonomics, zero infrastructure to manage. The dbt models don't reference anything DuckDB-specific — pointing at Snowflake or BigQuery is a config change, not a rewrite. |
| Self-generated synthetic data | Public Kaggle dataset | Real operational data is messy. Public datasets are too clean. I wanted data that behaves like a real system — with missing references, late-arriving records, and duplicate events — so the pipeline would need to handle actual edge cases, not just happy-path transformations. |
| Tables everywhere (no views) | Views for staging/intermediate | DuckDB is embedded — no shared compute cluster. Tables provide faster BI queries and guarantee consistent results between pipeline runs. No downside since there's no storage cost concern. |
| 6 domain-specific marts | One big mart / flat table | Each mart serves a specific audience (logistics ops, finance, warehouse managers). A single mart would duplicate logic and be harder to maintain or extend. |
| GitHub Actions CI/CD | Simple shell scripts | GitHub Actions provides automated scheduling, retries, observability, and execution logging. A shell script would work but doesn't demonstrate production-style orchestration. |
| SCD Type 2 on customers and carriers | SCD Type 1 (overwrite) | Customer profiles and carrier SLA configs change over time. Without historical tracking, period-over-period reporting would be inaccurate. |

### What I'd Change in Production

| Area | Current State | Production Change |
|---|---|---|
| **Cloud warehouse** | DuckDB (embedded, local) | Move back to Snowflake or BigQuery for distributed compute, concurrency, and managed infrastructure |
| **Source freshness** | No freshness monitoring | Add `freshness:` blocks to dbt source YAML with SLA thresholds and alerting |
| **Orchestration** | GitHub Actions CI/CD | Add retry policies, failure alerts, and pipeline monitoring for production-grade reliability |
| **Cross-mart validation** | Tests within each model only | Add integration tests verifying counts agree across marts (e.g., total shipments in carrier mart ≈ financial mart) |
| **Incremental models** | All models are full-refresh | Make Gold marts incremental — append new data rather than rebuilding entire marts daily |
| **Data observability** | No monitoring or alerting | Add pipeline failure alerts, row-count anomaly checks, and data drift detection |

---

## Key Findings

> These findings are produced by the pipeline. Full analysis with evidence, charts, and prioritized recommendations → [`docs/business_insights.md`](./docs/business_insights.md)

<table align="center">
<tr>
<td align="center" width="20%"><h2>1.87%</h2><sub>Avg. warehouse utilization<br>across 120 facilities</sub></td>
<td align="center" width="20%"><h2>6.97%</h2><sub>Network-wide SLA<br>breach rate</sub></td>
<td align="center" width="20%"><h2>5.8×</h2><sub>Premium vs. Economy<br>carrier cost per kg</sub></td>
<td align="center" width="20%"><h2>₹6.88M</h2><sub>Cost of SLA-breached<br>shipments (of ₹98.6M spend)</sub></td>
<td align="center" width="20%"><h2>0–23%</h2><sub>Seller SLA breach<br>spread (2,000 sellers)</sub></td>
</tr>
</table>

**Headline finding:** the network is not capacity-constrained. It's allocation-constrained. Warehouses run at under 2% of built capacity while SLA breaches still spike to 13% on peak days. Premium carriers cost 5.8× more without delivering measurably better reliability. A 23-point SLA spread across sellers is invisible to anyone only looking at carrier or warehouse reports.

### Carrier Performance: Premium Doesn't Buy Reliability

<div align="center">
<img width="1314" height="647" alt="Image" src="https://github.com/user-attachments/assets/104f2089-4d9b-4e07-829f-e03f575a0bd9" />
</div>

| Metric | Value |
|---|---|
| Avg. cost per kg — Premium tier | ₹41.00 (5.8× Economy) |
| Avg. SLA breach — Premium tier | 7.22% (not meaningfully better than Economy's 6.99%) |
| Carrier SLA range | 6.55% – 7.73% (under 1.2 points across all 25 carriers) |

Carriers differentiate on speed, not reliability. Premium buys a faster average, not a safer one.

### Financial Impact: No Penalty for Failure

<div align="center">
<img width="1320" height="649" alt="Image" src="https://github.com/user-attachments/assets/7c71338f-e0c1-45d5-911e-84fb825f7145" />
</div>

| Metric | Value |
|---|---|
| Total logistics spend | ₹98.57M |
| Cost of SLA-breached shipments | ₹6.88M (6.98% of spend) |
| Avg. cost — breached vs. on-time | ₹197.77 vs. ₹197.24 (virtually identical) |

A breached shipment costs the same as a successful one. Performance-linked carrier contracts would target exactly this gap.

---

## Repository Structure

<details>
<summary><b>📂 Click to expand: Repository Structure</b></summary>

```
marketplace-logistics-intelligence-platform/
├── data/{bronze, gold}
├── python/{generators, exports, utilities}
├── warehouse/logistics.duckdb
├── dbt/logistics_project/models/{bronze, silver, gold}
├── .github/workflows/
├── dashboards/
├── docs/
├── images/
├── README.md
└── SETUP.md
```

</details>

---

## Caveats & Assumptions

- **All data is synthetic.** Every figure — the ₹98.57M spend, the 6.97% breach rate, the 22.99% seller outlier — comes from a dataset I designed and generated myself in Python. It is not a real company's financials, and I'm stating that plainly here rather than letting the findings read as market research.
- **What is real:** the architecture decisions, the data quality problems built in on purpose (and how they're handled), and the cross-mart analytical method — that part is meant to transfer directly to a real job.
- **Shipment totals don't fully agree across marts, and that's disclosed, not hidden.** Carrier and Financial marts total 499,500 shipments; Warehouse totals 494,505 (−1.0%); Overview totals 493,940 (−1.1%); Region totals 492,002 (−1.5%). This follows each mart's own governance rules (a shipment with no assigned warehouse is excluded from the Warehouse mart, etc.) rather than being an error. Both totals are correct for what they're measuring, they're just not the same denominator.
- **This reflects one pipeline run, one point in time.** A production version would track KPI drift across runs, not a single snapshot.
- **The CI/CD pipeline runs via GitHub Actions with Docker containers**, demonstrating automated deployment and orchestration. It does not claim production-scale scheduling experience.
- **SCD Type 2** is implemented correctly on `dim_customers` and `dim_carriers`, but the underlying change events are synthetically generated so the logic has something to track — happy to walk through that distinction directly.
- **On DuckDB vs. a cloud warehouse:** this project was originally built against Snowflake and moved to DuckDB once trial access ran out. The dbt models don't reference anything DuckDB-specific. Pointing this project at Snowflake or BigQuery is a config change, not a rewrite.

---

## Documentation Index

| Document | What's in it |
|---|---|
| [`docs/business_insights.md`](./docs/business_insights.md) | Full business analysis — carrier, warehouse, region, seller, financial deep dives, and prioritized recommendations |
| [`docs/data_model.md`](./docs/data_model.md) | ERD, star schema, SCD Type 2 design and rationale |
| [`docs/data_dictionary.md`](./docs/data_dictionary.md) | Column-level definitions for every dimension, fact, and Gold mart |
| [`docs/data_quality_audit.md`](./docs/data_quality_audit.md) | Full data quality framework, anomaly injection and handling rules |
| [`docs/project_architecture.md`](./docs/project_architecture.md) | Full pipeline architecture, CI/CD pipeline design, Docker setup |
| [`docs/project_structure.md`](./docs/project_structure.md) | Repository layout and folder responsibilities |
| [`SETUP.md`](./SETUP.md) | How to reproduce the full pipeline locally |

---

<p align="center"><sub>Questions about any specific number, modeling decision, or the engineering behind a claim above — happy to walk through it.</sub></p>