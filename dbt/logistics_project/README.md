# Marketplace Logistics Intelligence Platform

**An end-to-end analytics engineering case study diagnosing operational inefficiency across a national e-commerce logistics network**

<p>
  <img alt="status" src="https://img.shields.io/badge/status-portfolio_case_study-blue">
  <img alt="architecture" src="https://img.shields.io/badge/architecture-medallion_(bronze--silver--gold)-informational">
  <img alt="stack" src="https://img.shields.io/badge/stack-dbt_%7C_DuckDB_%7C_Airflow_%7C_Docker-orange">
  <img alt="records" src="https://img.shields.io/badge/gold_records-500K%2B_shipments-success">
  <img alt="quality" src="https://img.shields.io/badge/data_quality-0_nulls_%7C_0_duplicates-brightgreen">
</p>

**Author:** Saswata Ghosh · [GitHub](https://github.com/Saswataghosh06/Marketplace-Logistics-Intelligence-Platform) · [LinkedIn](#) · [Email](#)
**Setup & reproduction instructions:** see [`SETUP.md`](./SETUP.md)

---

## How to Read This Repository

This is not a "tools" project. It is a **business diagnostic** built the way a consulting analytics team would build one — data engineering as the foundation, business questions as the driver, and executive recommendations as the output.

If you are a **hiring manager or recruiter**, start with the [Executive Summary](#executive-summary) and [Cross-Mart Findings](#chapter-6-cross-mart-synthesis-the-part-most-projects-skip).
If you are a **technical reviewer**, start with [Architecture](#chapter-2-architecture) and [Data Quality & Governance](#chapter-4-data-quality--governance).
If you want the **full narrative**, read top to bottom — it is written as a chaptered case study, the same way a Deloitte or McKinsey engagement deck would be structured.

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Chapter 1 — Business Problem](#chapter-1-business-problem)
3. [Chapter 2 — Architecture](#chapter-2-architecture)
4. [Chapter 3 — Data Model](#chapter-3-data-model)
5. [Chapter 4 — Data Quality & Governance](#chapter-4-data-quality--governance)
6. [Chapter 5 — Mart-by-Mart Findings](#chapter-5-mart-by-mart-findings)
7. [Chapter 6 — Cross-Mart Synthesis](#chapter-6-cross-mart-synthesis-the-part-most-projects-skip)
8. [Chapter 7 — Executive Recommendations & Roadmap](#chapter-7-executive-recommendations--roadmap)
9. [Chapter 8 — Engineering Challenges & Decisions](#chapter-8-engineering-challenges--decisions)
10. [Chapter 9 — Limitations & Honest Caveats](#chapter-9-limitations--honest-caveats)
11. [Chapter 10 — What This Project Demonstrates](#chapter-10-what-this-project-demonstrates)
12. [Repository Structure](#repository-structure)
13. [Roadmap / Future Work](#roadmap--future-work)

---

## Executive Summary

A national e-commerce logistics network processes **499,500 shipments** across 25 carriers, 120 fulfillment centers, 5 regions, and 2,000 marketplace sellers. Leadership can see individual operational dashboards — carrier scorecards, warehouse reports, seller ratings — but has no single view connecting *why* delivery promises are broken 6.97% of the time despite a network that looks, on paper, well-resourced.

This project was built to answer one question a real operations executive would ask:

> **"We have the infrastructure. Why isn't it performing? And what should we fix first?"**

I built a governed, testable dimensional warehouse (Bronze → Silver → Gold) from 11 raw operational datasets, orchestrated with Apache Airflow, and used the resulting six Gold marts to run a structured diagnostic — the same method used in a logistics network optimization engagement.

**Headline findings, verified directly against the exported Gold data (not assumed):**

| Finding | Evidence |
|---|---|
| The network has capacity, not a capacity problem | Average warehouse utilization is **1.87%** (max 5.53%) across 120 facilities with combined capacity of ~34.7M units |
| Premium logistics spend does not buy premium reliability | Premium carriers cost **₹41.0/kg** vs. Economy at **₹7.1/kg** (~5.8x) while SLA breach rates are statistically indistinguishable (Premium 7.22% avg vs. Economy 6.99% avg) |
| Demand and infrastructure are geographically misaligned | South India generates the highest shipment volume (130,844) at only **1.17% warehouse utilization**, while East India runs at **4.18% utilization** with the highest SLA breach rate (7.07%) |
| Seller-side delay is a material, isolable risk | Seller SLA breach rates range from **0% to 22.99%** across 2,000 sellers (network average 6.91%) — a 20+ point spread invisible in any single carrier or warehouse report |
| SLA failures carry a quantifiable cost | Breached shipments account for **₹6.88M** (6.98%) of the **₹98.57M** total logistics spend |

Full reasoning, evidence chains, and prioritized recommendations are documented in [Chapter 6](#chapter-6-cross-mart-synthesis-the-part-most-projects-skip) and [Chapter 7](#chapter-7-executive-recommendations--roadmap).

---

## Chapter 1: Business Problem

E-commerce logistics networks generate enormous operational exhaust — orders, shipments, tracking events, seller activity, carrier performance — but that volume of data rarely translates into decision-ready insight. Most organizations end up with the same five symptoms:

- **High logistics cost** without clear visibility into what's driving it
- **Inconsistent delivery performance** across carriers, warehouses, and sellers with no shared root cause
- **Underutilized infrastructure** that keeps getting funding requests for expansion anyway
- **Fragmented reporting** — carrier teams, warehouse teams, and finance each have their own numbers that don't reconcile
- **No single executive view** connecting operational performance to financial impact

### Business Objectives

| # | Objective | Owner |
|---|---|---|
| 1 | Understand root causes of SLA breaches and improve delivery reliability | COO / Ops |
| 2 | Identify and eliminate unnecessary logistics spend | Finance |
| 3 | Evaluate warehouse utilization and regional capacity alignment | Fulfillment |
| 4 | Measure carrier efficiency (volume, cost, transit time, SLA) | Procurement |
| 5 | Provide a governed, single source of truth for executive reporting | Leadership |

### Guiding Business Questions

**Network & Operations** — Which carriers underperform? Which warehouses are under-utilized? Which regions carry the highest operational pressure? Is capacity allocated efficiently?

**Financial** — Where is spend concentrated? What does an SLA breach actually cost? Which activities generate cost without generating service quality?

**Seller / Marketplace** — Which sellers drive revenue vs. risk? Does seller behavior materially affect the customer experience?

**Executive** — Is the network scalable? Does it hold up under peak demand? Where should the next dollar of investment go?

---

## Chapter 2: Architecture

The platform follows a **Medallion Architecture** (Bronze → Silver → Gold) with a **Star Schema** dimensional warehouse, orchestrated end-to-end and containerized for reproducibility — the same pattern used in production analytics engineering teams, scaled down to a portfolio-appropriate footprint.

```
Python Synthetic Data Generator (11 operational entities)
            │
            ▼
   Bronze Layer — Raw Parquet (immutable, no transformation)
            │
            ▼
   load_bronze.py  →  DuckDB Bronze Schema
            │
            ▼
   dbt debug  →  dbt build
            │
            ▼
   Silver Layer (DuckDB + dbt)
     staging/  →  dimensions/  →  facts/
            │
            ▼
   Gold Layer — 6 Business Marts (dbt + schema tests)
            │
            ▼
   export_gold_marts.py  →  CSV Exports (data/gold/)
            │
            ▼
   Dashboard Layer (HTML / Power BI)
```

**Orchestration:** the full pipeline is a single Apache Airflow DAG (`logistics_pipeline`) with four sequential tasks — `load_bronze → dbt_debug → dbt_build → export_gold` — each gated on the successful completion of the previous task, running inside Docker for environment parity between development and "production."

> 📸 **[Placeholder — Airflow DAG Graph View]**
> `images/airflow_dag_success.png`
> *Shows the 4-task DAG (`load_bronze`, `dbt_debug`, `dbt_build`, `export_gold`) all in a successful state.*

> 📸 **[Placeholder — dbt Lineage Graph]**
> `images/dbt_lineage_graph.png`
> *Full lineage from Bronze sources → staging → dimensions/facts → six Gold marts, generated via `dbt docs generate`.*

**Environment portability:** file paths are resolved through environment variables rather than hardcoded paths, so the same dbt project runs unmodified on Windows (local development) and Linux/Docker (orchestrated execution) — a distinction that mattered in practice (see [Chapter 8](#chapter-8-engineering-challenges--decisions)).

### Technology Stack

| Layer | Technology | Why |
|---|---|---|
| Data generation | Python | Simulates realistic operational entities and intentional data-quality anomalies |
| Storage (raw) | Parquet | Columnar, immutable Bronze source of truth |
| Warehouse | DuckDB | Embedded OLAP engine — fast local analytics without infrastructure overhead |
| Transformation | dbt Core | Version-controlled SQL, testing, documentation, lineage |
| Orchestration | Apache Airflow | Production-pattern DAG scheduling, retries, dependency management |
| Containerization | Docker + Docker Compose | Environment parity, reproducible deployment |
| Metadata store | PostgreSQL | Airflow's backing metadata database |
| Governance | dbt YAML schema tests | Enforced data contracts between layers |
| Reporting | HTML dashboard / Power BI | Business-facing visualization layer |
| Version control | Git / GitHub | Full history, commit discipline |

---

## Chapter 3: Data Model

The warehouse is modeled as a **Star Schema**: 7 conformed dimensions feeding 4 fact tables, which in turn roll up into 6 business-domain Gold marts.

```
Dimensions                          Facts                         Gold Marts
─────────────                       ─────────                     ──────────────────────
dim_customers  (SCD Type 2)   ┐
dim_products                  ├──►  fct_orders        ┐
dim_sellers                   │     fct_order_items    ├──► mart_logistics_overview
dim_carriers   (SCD Type 2)   │     fct_shipments       ├──► mart_carrier_performance
dim_warehouses                │     fct_tracking_events ├──► mart_warehouse_performance
dim_regions                   │                         ├──► mart_region_performance
dim_date                      ┘                         ├──► mart_seller_performance
                                                         └──► mart_financial_impact
```

| Layer | Object | Grain |
|---|---|---|
| Bronze | 11 raw datasets | Source-native |
| Silver | 7 dimensions | One row per business entity |
| Silver | 4 facts | `fct_orders` (1/order), `fct_order_items` (1/line item), `fct_shipments` (1/shipment), `fct_tracking_events` (1/event) |
| Gold | 6 marts | See table below |

**Slowly Changing Dimensions:** `dim_customers` and `dim_carriers` are implemented as **SCD Type 2** to preserve historical accuracy — e.g., a carrier's tier or a customer's segment can change over time without overwriting history, which matters for accurate point-in-time KPI reconstruction.

### Gold Mart Summary (verified against exported CSVs)

| Gold Mart | Grain | Records | Columns | Primary Stakeholder |
|---|---|---|---|---|
| `mart_logistics_overview` | Daily | 1,461 | 21 | COO / Operations |
| `mart_carrier_performance` | Carrier | 25 | 13 | Logistics / Procurement |
| `mart_warehouse_performance` | Warehouse | 120 | 19 | Warehouse Manager |
| `mart_region_performance` | Region | 5 | 11 | Regional Operations |
| `mart_seller_performance` | Seller | 2,000 | 19 | Seller Success |
| `mart_financial_impact` | Enterprise summary | 1 | 15 | Finance Leadership |

*Every figure above was independently recomputed from the raw CSV exports in this repository, not copied from a prior draft — see [Chapter 4](#chapter-4-data-quality--governance) for validation methodology.*

---

## Chapter 4: Data Quality & Governance

Production data is never perfect, and pretending otherwise produces analytics that fall apart under scrutiny. This project deliberately injects realistic operational anomalies at the source (missing references, future-dated records, duplicate events, negative quantities) and then applies a **governance philosophy** rather than a "delete anything messy" philosophy:

| Layer | Philosophy |
|---|---|
| **Bronze** | Preserve everything, exactly as generated. No filtering, no business rules. Full auditability. |
| **Silver** | Standardize types/names, generate surrogate keys, apply SCD Type 2, validate referential integrity — but *keep* known anomalies visible for operational investigation. |
| **Gold** | Apply governance rules so only clean, business-valid records reach executive KPIs. Operational teams still have Silver for root-cause work. |

### Known Anomalies and Their Handling

| Anomaly | Business Scenario Simulated | Silver | Gold |
|---|---|---|---|
| Missing customer reference | Delayed CRM sync | Preserved | Excluded from customer KPIs |
| Missing warehouse assignment | Unallocated shipment | Preserved | Excluded from warehouse mart |
| Future-dated orders | Clock/timezone sync issues | Preserved | Excluded from trend KPIs |
| Duplicate tracking events | Event-stream replay | Preserved | Aggregated safely |
| Missing product references | Catalog sync failure | Preserved | Excluded where required |
| Negative quantities | Transaction correction | Preserved | Excluded from revenue calc |

### Gold-Layer Validation (independently re-verified)

| Gold Mart | Missing Values | Duplicate Records | Grain Verified |
|---|---|---|---|
| Logistics Overview | 0 | 0 | ✅ 1,461 unique dates, 2022-01-01 → 2025-12-31, no gaps |
| Carrier Performance | 0 | 0 | ✅ 25 unique carriers |
| Warehouse Performance | 0 | 0 | ✅ 120 unique warehouses |
| Region Performance | 0 | 0 | ✅ 5 unique regions |
| Seller Performance | 0 | 0 | ✅ 2,000 unique seller IDs |
| Financial Impact | 0 | 0 | ✅ single enterprise summary row |

### Business Rule / Domain Validation

Enforced via dbt generic + custom tests: primary key uniqueness, not-null constraints on mandatory fields, referential integrity (Orders↔Customers, Order Items↔Products/Sellers, Shipments↔Warehouses/Carriers/Regions, Tracking Events↔Shipments), and accepted-value checks on categorical fields (shipment status, order status, payment method, carrier tier, customer segment).

| Business Rule | Status |
|---|---|
| Shipment volume ≥ 0 | ✅ Passed |
| Revenue ≥ 0 | ✅ Passed |
| Shipping cost ≥ 0 | ✅ Passed |
| Warehouse utilization between 0–100% | ✅ Passed |
| SLA breach % between 0–100% | ✅ Passed |
| Transit days > 0 | ✅ Passed |
| Seller ratings between 1–5 | ✅ Passed |

> 📸 **[Placeholder — VS Code project structure / dbt schema tests]**
> `images/vscode_project_structure.png`

> **Methodology note:** Regional shipment totals differ by a small margin (~1,050 shipments, <1%) depending on whether they are rolled up from `mart_warehouse_performance` (warehouse → region) or read directly from `mart_region_performance` (customer's assigned region on the order). This is expected — a shipment's *fulfilling warehouse region* and the *customer's region* are not always identical — and is flagged here rather than silently reconciled, consistent with the project's "preserve and disclose" data quality philosophy.

---

## Chapter 5: Mart-by-Mart Findings

Each subsection below states the business purpose of the mart, then the findings — every number pulled directly from the Gold CSV exports.

### 5.1 Carrier Performance

**Purpose:** Evaluate 25 third-party carriers across 4 service tiers (Economy, Standard, Express, Premium) to support carrier evaluation, contract negotiation, and routing strategy.

- Shipment volume is concentrated in **Standard** (FedEx 27,054 / BlueDart 27,013 / Ekart 26,787 / DHL 26,715) and **Express** carriers (~22,200–22,530 each, 10 carriers) — together **~76%** of all shipments.
- **Premium** carriers (TCIExpress, Trackon, Borzo, Aramex) handle the smallest volume (8,383–8,599 each) but cost **₹41.0/kg on average — 5.8x Economy's ₹7.1/kg**.
- SLA breach rates are tightly clustered **regardless of tier**: Economy 6.99% avg, Standard 6.99% avg, Express 6.91% avg, Premium 7.22% avg. Aramex has the single highest breach rate (7.73%); Borzo the lowest (6.55%).
- Transit time scales almost perfectly with tier design: Premium ~1.60 days, Express ~3.00 days, Standard ~5.48 days, Economy ~8.48 days — carrier-side execution is highly predictable.

**Reading:** carriers are doing exactly what their tier design promises on *speed*. They are **not** differentiating on *reliability*. Premium pricing does not buy premium SLA performance.

### 5.2 Warehouse Performance

**Purpose:** Evaluate utilization, throughput, and reliability across 120 fulfillment centers.

- Network-wide average utilization: **1.87%** (min 0.40%, max 5.53%) against average facility capacity of **289,141 units**.
- Utilization by region: East India highest (4.18%), Central 2.79%, North 2.47%, South 1.17%, West lowest (0.90%).
- Warehouse rating shows **no measurable relationship** with SLA performance (correlation coefficient ≈ **-0.002**) — highly-rated Tier 1 facilities in Delhi, Chennai, and Mumbai are among the highest SLA-breach warehouses in the network.
- Utilization itself is also uncorrelated with SLA breach (correlation ≈ **0.017**) — the constraint is not simply "busier warehouses fail more."

**Reading:** this is not a capacity problem. Facility ratings and utilization levels do not predict delivery reliability — the driver is elsewhere (operational design within large facilities, or upstream seller dispatch — see Chapter 6).

### 5.3 Region Performance

**Purpose:** Macro-level view of demand, cost, and reliability across India's 5 operational regions.

- Demand is concentrated: South India (130,844 shipments) and North India (130,092) together represent **53.0%** of national shipment volume. Central India is the smallest market (50,174).
- Cost is almost perfectly uniform nationally: avg shipping cost ~₹197 in every region, cost/kg ~₹9.71–9.73, transit time ~4.91–4.93 days — a single national operating model, regardless of local density or demand.
- East India has the highest SLA breach rate (7.07%); Central India the lowest (6.80%) — a real but modest spread (0.27 points) given volume.

**Reading:** the network runs one operating model everywhere. That simplifies execution but forfeits the cost and service advantages a demand-weighted, regionally-tuned strategy could unlock.

### 5.4 Seller Performance

**Purpose:** Evaluate 2,000 marketplace sellers on commercial and operational performance.

- SLA breach rate spans **0% to 22.99%** across sellers (network average 6.91%, std. dev. 2.15 points) — a materially wider spread than anything observed at the carrier or warehouse level.
- Ten sellers post SLA breach rates above 15% (worst: `DigitalKart6843` at 22.99%; `DigitalEnterprise1385` at 22.62% while generating ₹8.9M in revenue — a high-revenue, high-risk seller).
- Tier does not fully predict reliability: Premium-tier sellers average 6.76% breach — the best of the three tiers — but individual Premium sellers still appear in the worst-10 list, showing tier alone is an incomplete risk signal.
- Revenue concentration is moderate, not extreme: the top 10 sellers (of 2,000) generate **5.4%** of total marketplace revenue (₹45.88B) — this is a long-tail marketplace, not a hits-driven one.

**Reading:** seller-side dispatch behavior is a genuine, measurable, and isolable source of delivery risk — and it is invisible if you only look at carrier or warehouse dashboards.

### 5.5 Financial Impact

**Purpose:** Translate operational performance into enterprise financial terms.

- Total logistics spend: **₹98.57M** across 499,500 shipments (avg ₹197.34/shipment, ₹9.72/kg).
- SLA-breached shipments (34,811 of 499,500 — 6.97%) account for **₹6.88M**, or **6.98% of total spend** — i.e., failed deliveries cost proportionally the same per shipment as successful ones (₹197.77 vs. ₹197.24 avg), meaning there is currently **no cost recovery mechanism** for failed service.

**Reading:** the organization pays full price for failed deliveries. This is a contractual/procurement gap, not a data or forecasting gap — and it's one of the more directly fixable findings in this report.

### 5.6 Logistics Overview (Time Series)

**Purpose:** Daily executive trend view, 2022–2025 (1,461 days, zero missing/duplicate).

- Average daily orders: 342; peak day: 786 orders.
- Average daily SLA breach: 6.95%; peak day: **13.08%** — nearly double the baseline.
- Order volume, revenue, and SLA performance are stable year-over-year (2022–2025 order counts range narrowly between 124,577 and 125,466) — this is a **mature, steady-state business**, not one experiencing structural growth or decline. The operational stress observed is therefore driven by **demand variability within the network's existing footprint**, not by unmanaged top-line growth.

---

## Chapter 6: Cross-Mart Synthesis (the part most projects skip)

Individually, each mart is well-formed and answers its own question competently. The real diagnostic value only appears when they're read **together** — this is the difference between a reporting project and a consulting engagement.

### Finding 1 — Idle Infrastructure, Active SLA Failures

- Warehouse mart: 1.87% average utilization, 5.53% peak.
- Overview mart: 6.95% average SLA breach, 13.08% peak.

If warehouses are almost empty, low warehouse capacity cannot be the reason deliveries are late. **The constraint is allocation, not capacity.**

### Finding 2 — Demand and Infrastructure Are Not on the Same Map

- Region mart: South (130,844) and North (130,092) are the two largest demand markets.
- Warehouse mart: South utilization is 1.17%; East India — a mid-sized demand market — runs at 4.18% utilization *and* the highest SLA breach rate (7.07%).

Inventory positioning does not track customer demand. East India shows early signs of localized fulfillment congestion (Kolkata and Patna are among the network's busiest facilities by shipment volume) while South India's much larger demand base sits on comparatively idle infrastructure.

### Finding 3 — Premium Price, Average Reliability

- Carrier mart: Premium tier costs 5.8x Economy per kg (₹41.0 vs ₹7.1) with an *average* SLA breach rate (7.22%) that is not meaningfully better than Economy (6.99%).

The organization is paying a substantial premium for speed, not for reliability — and currently allocates that premium tier without a hard rule limiting it to shipments where speed alone justifies the cost.

### Finding 4 — Seller Behavior Is a Distinct, Material Risk Factor

- Seller mart: SLA breach spread of 0%–22.99% across 2,000 sellers, well beyond the 6.55%–7.73% spread seen across all 25 carriers combined.
- Warehouses are idle; carriers perform consistently. By elimination, **seller-side dispatch timing is a leading, independently measurable driver of delivery risk** — and one that neither the warehouse nor carrier mart alone would surface.

### Finding 5 — Peak Demand Breaks the Network, Not Capacity

- Overview mart: SLA breach nearly doubles on peak-volume days (6.95% avg → 13.08% peak) while warehouse capacity is nowhere near saturated even on those days.

The network has enough physical capacity to absorb peak demand but not enough **process elasticity** (labor scheduling, pickup cadence, pre-positioning) to convert that capacity into throughput when it's needed most.

### Finding 6 — Procurement Has Not Captured Volume Economics

- Financial mart: shipping cost per shipment is nearly flat (₹197 average, tight range) regardless of volume, region, or time period.

At this shipment volume (499,500 annually), flat per-shipment pricing across a multi-year, multi-region contract set suggests carrier agreements are not structured around volume-tiered economics — a straightforward, low-execution-risk cost-recovery opportunity.

### Cross-Mart Conclusion

> **The network has sufficient infrastructure, operationally stable carriers, and predictable demand. The binding constraint is strategic allocation — of inventory, carrier tier, seller accountability, and procurement structure — not physical capacity.** This reframes the business conversation from *"where do we build next"* to *"how do we use what we already have."*

---

## Chapter 7: Executive Recommendations & Roadmap

Recommendations are prioritized using four criteria consistent with how a consulting engagement would triage a findings list: **financial impact, customer impact, implementation complexity, and time-to-value.**

### Immediate (0–3 Months) — high impact, low complexity

| Initiative | Business Problem | Expected Benefit |
|---|---|---|
| **Seller SLA scorecards** | Worst sellers breach 23% of deliveries vs. 6.9% network average | Targeted accountability without penalizing the 90%+ of sellers performing well |
| **Performance-linked carrier contracts** | Breached shipments cost the same as on-time ones (~₹197 each) | Path to recovering part of the ₹6.88M annual breach cost |
| **Restrict Premium carrier usage** | Premium costs 5.8x Economy for statistically similar SLA outcomes | Direct cost reduction with minimal service risk |
| **Weight-based routing rules** | Heavy shipments are not systematically routed to lower-cost tiers | Lower blended cost/kg without new infrastructure |

### Medium-Term (3–6 Months) — high impact, moderate-to-high complexity

| Initiative | Business Problem | Expected Benefit |
|---|---|---|
| **Warehouse network consolidation review** | 1.87% average utilization across 120 facilities | Lower fixed OPEX; higher inventory density |
| **Regional inventory rebalancing** | South/North demand vs. East/South utilization mismatch | Shorter transit distances, reduced regional congestion |
| **Peak-season load balancing** | SLA breach nearly doubles on peak days despite spare capacity | Smoother customer experience exactly when it matters most |
| **Managed fulfillment pathway for high-risk sellers** | 10 sellers breach >15% SLA, one at ₹8.9M revenue | Converts a volatile risk into a controlled, company-managed process |

### Long-Term (6–18 Months) — strategic, higher complexity

| Initiative | Business Problem | Expected Benefit |
|---|---|---|
| **Zone-based / volume-tiered pricing** | Flat ₹197 avg. cost regardless of region or volume | Captures negotiating leverage from scale |
| **Demand-driven capacity planning** | Infrastructure investment has outpaced realized demand | Future capital tied to evidence, not uniform geographic coverage |
| **Dynamic, rules-based carrier allocation** | Static tier-based routing today | Continuous cost/SLA optimization at scale |

### Target KPI Movement

| KPI | Current | Target |
|---|---|---|
| SLA breach rate | 6.97% | < 5% |
| Peak-day SLA breach | 13.08% | < 8% |
| Warehouse utilization | 1.87% | 10–15% |
| Avg. shipping cost/shipment | ₹197 | ₹185–190 |
| Breached-shipment cost share | 6.98% of spend | Reduced 25–40% |

**Bottom line for leadership:** the highest-return moves in this network are operational-discipline and allocation fixes, not capital expenditure. That combination — high impact, low capital risk — is precisely the profile that gets funded first in any real budget cycle.

---

## Chapter 8: Engineering Challenges & Decisions

Real projects break in ways portfolio write-ups often skip. This section documents one non-trivial issue actually hit during orchestration, because *how* a problem was diagnosed matters as much as the fix — for Data Engineering, DevOps, and Analyst/Consultant roles alike.

### Issue: Airflow DAG failing intermittently at the `dbt_build` task

**Symptom:** The first five DAG runs failed inconsistently at the `dbt build` task, with no obvious pattern — sometimes failing, sometimes succeeding on retry with no code changes in between. This is the worst kind of bug to debug because it looks like flakiness rather than a real defect.

**Root cause:** dbt resolves its connection configuration through `profiles.yml`, which in turn depends on environment variables for file paths (DuckDB file location, project directory). Locally on **Windows**, those paths resolved correctly using Windows-style paths and the local Python virtual environment. Inside **Docker/Linux** (where Airflow actually executes the DAG), the same environment variables were either unset or pointed to Windows-style paths that don't exist in the container filesystem — so `dbt debug` would sometimes pass (using a stale or partially-correct path) while `dbt build` failed downstream once it tried to actually read/write the DuckDB file at a path that didn't exist in that environment.

**Why it looked like "hidden dependency" failure at first:** the DAG's task-to-task dependency graph (`load_bronze → dbt_debug → dbt_build → export_gold`) was correct — tasks were genuinely waiting on each other. The actual defect was **environment parity**, not task sequencing: development (Windows, local venv) and orchestrated execution (Linux, Docker) were silently resolving different physical paths from the same logical configuration.

**Fix:**
1. Standardized all path references in `profiles.yml` and dbt project config to resolve exclusively through environment variables injected at container runtime (via `docker-compose.yml`), removing any hardcoded or OS-assumed paths.
2. Added a `dbt debug` task as an explicit, separate DAG step *before* `dbt build` — so a bad connection/profile config fails fast and visibly, instead of surfacing as a confusing downstream build failure.
3. Verified reproducibility by tearing down and rebuilding the full Docker environment from a clean state multiple times, rather than trusting a single successful run.

**Why this matters beyond this one bug:** it's a concrete example of a class of problem that shows up constantly in real data platforms — configuration that "works on my machine" because of implicit environment assumptions. The fix (explicit environment-variable-driven configuration + a fail-fast validation step in the pipeline) is a general pattern, not a one-off patch.

---

## Chapter 9: Limitations & Honest Caveats

A credible analytics case study states its limitations directly rather than implying false certainty.

- **Synthetic data:** all underlying datasets were generated via a Python synthetic data generator, not sourced from a live production system. Business logic, anomaly patterns, and KPI ranges were designed to be operationally realistic, but the specific figures in this report describe this dataset, not a real company's actual logistics network.
- **No live dashboard yet:** the Power BI / HTML dashboard layer referenced in the architecture is in progress — see [Roadmap](#roadmap--future-work). All findings in this README were validated directly against the exported Gold CSVs using independent recalculation, not against a pre-built dashboard.
- **Regional shipment totals** differ by <1% depending on aggregation path (warehouse-fulfillment region vs. customer-assigned region) — documented in [Chapter 4](#chapter-4-data-quality--governance) rather than silently reconciled.
- **Single point-in-time export:** the Gold marts analyzed here reflect one pipeline run. A production version of this platform would track KPI drift across runs, not just a single snapshot.

---

## Chapter 10: What This Project Demonstrates

This project was deliberately scoped to demonstrate judgment, not just tool proficiency.

| Capability | Where it shows up |
|---|---|
| Translating a vague business pain point into specific, testable questions | Chapter 1 |
| Designing a governed, scalable dimensional model (not just "a database") | Chapters 2–3 |
| Treating data quality as a philosophy, not a checklist | Chapter 4 |
| Reading data at the mart level *and* synthesizing across marts | Chapters 5–6 |
| Prioritizing recommendations by impact vs. effort, the way a real budget cycle would | Chapter 7 |
| Debugging environment-parity issues in a real orchestrated pipeline | Chapter 8 |
| Being honest about what the data can and can't support | Chapter 9 |

The tools (dbt, DuckDB, Airflow, Docker, Power BI) are listed once, in Chapter 2, and never again — because they are infrastructure in service of the argument, not the argument itself.

---

## Repository Structure

```
marketplace-logistics-intelligence-platform/
│
├── data/
│   ├── bronze/              # Raw synthetic Parquet datasets
│   └── gold/                # Exported Gold mart CSVs (analyzed in this README)
│
├── python/
│   ├── generators/          # Synthetic data generation
│   ├── exports/             # Gold mart CSV export logic
│   └── utilities/
│
├── warehouse/
│   └── logistics.duckdb     # Analytical warehouse (Bronze → Silver → Gold)
│
├── dbt/
│   └── logistics_project/
│       ├── models/
│       │   ├── bronze/      # Source definitions
│       │   ├── silver/
│       │   │   ├── staging/
│       │   │   ├── dimensions/
│       │   │   └── facts/
│       │   └── gold/        # 6 business marts + schema tests
│       └── ...
│
├── airflow/
│   ├── dags/                 # logistics_pipeline DAG
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── docs/                      # Architecture, data model, data quality reports
├── images/                    # Screenshots referenced in this README (see placeholders)
├── dashboards/                 # Power BI / HTML dashboard assets (in progress)
├── README.md                   # You are here
├── SETUP.md                    # Environment setup & reproduction steps
└── requirements.txt
```

---

## Roadmap / Future Work

- [ ] Build and publish the HTML executive dashboard (in progress) covering Overview, Carrier, Warehouse, Region, Seller, and Financial views
- [ ] Add a `SETUP.md` walkthrough for full local reproduction via Docker Compose
- [ ] Capture and embed real screenshots (dbt lineage, Airflow DAG runs, dashboard views) in place of the placeholders in this README
- [ ] Add KPI drift tracking across multiple pipeline runs rather than a single snapshot
- [ ] Extend seller risk scoring beyond SLA breach % into a composite operational-risk index

---

<p align="center"><i>This README is written as a business case study, not a feature list. If you have questions about any specific number, methodology, or design decision above, I'm happy to walk through it.</i></p>
