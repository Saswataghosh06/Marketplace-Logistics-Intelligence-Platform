<div align="center">
  <img width="140px" src="images/logo.jpg" alt="Logistics Group logo — placeholder, swap for your real logo file" />
</div>

<h1 align="center">Marketplace Logistics Intelligence Platform</h1>
<h3 align="center">Executive Diagnostic Report — Simulated National Logistics Network</h3>

<p align="center">
  <img alt="status" src="https://img.shields.io/badge/status-portfolio_case_study-1E56C7">
  <img alt="data" src="https://img.shields.io/badge/data-synthetic_%2F_self_generated-8B98AE">
  <img alt="stack" src="https://img.shields.io/badge/stack-dbt_%7C_DuckDB_%7C_Airflow_%7C_Docker-1E56C7">
  <img alt="quality" src="https://img.shields.io/badge/data_quality-0_nulls_%7C_0_duplicates-12A879">
</p>

<p align="center"><b>Saswata Ghosh</b> · Analytics Engineer / Data Analyst<br>
<a href="https://github.com/Saswataghosh06/Marketplace-Logistics-Intelligence-Platform">GitHub Repo</a> · <a href="#">LinkedIn</a> · <a href="#">Email</a> · <a href="./SETUP.md">Reproduce This Project →</a></p>

---

### Important Note

> **What this is:** a self-generated ~500K-shipment logistics dataset, built into a governed dbt/DuckDB warehouse, analyzed the way an operations consultant would — not "here's a dashboard" but "here's why the numbers look this way, and what I'd fix first."
>
> **What to do with this page:** skim the Executive Summary for the headline finding and the money number. If that lands, read the Insights section for the evidence. If you're evaluating engineering depth, jump to [Tech Stack, Architecture & Code](#7-tech-stack-architecture--code) — full technical documentation lives in `/docs`, linked at the bottom.
>
> **The one thing worth remembering:** premium carriers in this dataset cost **5.8× more per kg** than economy carriers for **statistically identical** on-time performance. That single number is the throughline for most of the recommendations below.

---

## 1. Background & Overview

I'm approaching this project the way an analytics engineer would approach a first-week engagement with a new logistics client: don't trust the dashboards that already exist, rebuild the data model from the ground up, validate it, and only then start forming opinions about what's actually happening operationally.

The "client" here is a simulated national e-commerce logistics network — 25 carriers, 120 warehouses, 5 regions, 2,000 marketplace sellers, ~500K shipments across four years (2022–2025). I designed and generated this dataset myself in Python specifically so it would behave like a real operational system: messy in the ways real systems are messy (missing references, late-arriving records, duplicate events), not the clean, pre-solved version you get from a Kaggle download.

On top of that data, I built a governed dimensional warehouse (Bronze → Silver → Gold), orchestrated it with Apache Airflow in Docker, and ran a cross-functional diagnostic across six business-domain marts — Overview, Carrier, Warehouse, Region, Seller, and Financial — to answer the kind of question a COO actually asks, not the kind a tutorial asks.

---

## 2. Objective

The logistics network in this dataset looks adequate on paper: reasonable infrastructure, stable carrier partners, predictable demand. It still misses roughly **7% of delivery commitments**, and no single team's dashboard explains why.

**The objective of this project is to answer one question with evidence, not assumption:**

> *If the infrastructure looks fine, why isn't performance matching it — and with a limited budget, what gets fixed first?*

That question sits at the intersection of five roles — data engineer, BI analyst, business analyst, operations consultant, and finance — so the project was built to hold up under any of those lenses, not just one.

**Business questions this project answers:**
- Which carriers are worth the money, and which aren't?
- Are warehouses actually the bottleneck — or is the constraint somewhere upstream?
- Does inventory sit where customer demand actually is?
- Which sellers create delivery risk that a carrier or warehouse report alone would never surface?
- What does a missed SLA cost in currency, not just in percentage points?

---

## 3. Data Structure & Initial Checks

The warehouse follows a **Medallion Architecture** (Bronze → Silver → Gold) with a **Star Schema** dimensional model: 7 conformed dimensions, 4 fact tables, 6 Gold marts.

<div align="center">
<table>
<tr>
<td width="50%" align="center"><b>dbt Lineage Graph</b><br><sub>Bronze sources → staging → dimensions/facts → 6 Gold marts</sub><br><br>
<img width="420" src="https://github.com/user-attachments/assets/bc154db8-5fd6-44cd-b52d-e27d0d837e75" alt="dbt lineage graph" />
</td>
<td width="50%" align="center"><b>Airflow Orchestration DAG</b><br><sub>4-task pipeline, all green</sub><br><br>
<img width="420" src="https://github.com/user-attachments/assets/463291d2-331b-4119-b0b2-4ed16cb155e2" alt="Airflow DAG success run" />
</td>
</tr>
</table>
</div>

**Initial checks performed before any analysis began** (full methodology in `docs/data_quality_audit.md`):

| Check | Result |
|---|---|
| Missing values across all 6 Gold marts | **0** |
| Duplicate records across all 6 Gold marts | **0** |
| Grain validated per mart (1 row per entity) | **Confirmed** — daily, carrier, warehouse, region, seller, enterprise |
| Referential integrity (Orders↔Customers, Shipments↔Carriers/Warehouses, etc.) | **Passed** via dbt tests |
| Business-rule bounds (utilization 0–100%, ratings 1–5, costs ≥ 0, etc.) | **Passed** via dbt tests |

I re-ran the null, duplicate, and grain checks myself directly against the exported CSVs before writing a single insight below — see [Section 8](#8-caveats--assumptions) for the discrepancies I found and chose to disclose rather than quietly fix.

Full ERD, table-level grain, and SCD2 design notes: **`docs/data_model.md`**

---

## 4. Executive Summary

<div align="center">
<img width="1317" height="644" alt="Image" src="https://github.com/user-attachments/assets/2169567a-83d8-4901-b5d4-7bb4a137f7b7" />
</div>

<br>

<table align="center">
<tr>
<td align="center" width="20%"><h2>1.87%</h2><sub>Avg. warehouse utilization<br>across 120 facilities</sub></td>
<td align="center" width="20%"><h2>6.97%</h2><sub>Network-wide SLA<br>breach rate</sub></td>
<td align="center" width="20%"><h2>5.8×</h2><sub>Premium vs. Economy<br>carrier cost per kg</sub></td>
<td align="center" width="20%"><h2>₹6.88M</h2><sub>Cost of SLA-breached<br>shipments (of ₹98.6M spend)</sub></td>
<td align="center" width="20%"><h2>0–23%</h2><sub>Seller SLA breach<br>spread (2,000 sellers)</sub></td>
</tr>
</table>

**Headline finding:** the network is not capacity-constrained. It's allocation-constrained. Warehouses run at under 2% of built capacity while SLA breaches still spike to 13% on peak days; premium carriers cost 5.8× more without delivering measurably better reliability; and a 23-point SLA spread across sellers is invisible to anyone only looking at carrier or warehouse reports.

**Bottom line:** almost every recommendation in this report is an allocation and accountability fix, not a capital request — which is usually the recommendation that gets funded fastest.

Full findings, by mart, with the evidence behind each number, are in Section 5.

---

## 5. Insights Deep Dive

*(Every number below is a pattern in the simulated dataset, stated the way I'd state a real one — see [Caveats](#8-caveats--assumptions).)*

### 5.1 Carrier Performance

<div align="center">
<img width="1314" height="647" alt="Image" src="https://github.com/user-attachments/assets/104f2089-4d9b-4e07-829f-e03f575a0bd9" />


</div>

| Business Metric | Value | Historical / Comparative Trend |
|---|---|---|
| Avg. cost per kg — Premium tier | **₹41.00** | 5.8× Economy tier (₹7.12) |
| Avg. SLA breach — Premium tier | **7.22%** | Not meaningfully better than Economy (6.99%) or Express (6.91%) |
| Best / worst carrier by SLA | Borzo 6.55% / Aramex 7.73% | Range across all 25 carriers is under 1.2 points — tight and systemic |
| Transit time by tier | 1.6 days (Premium) → 8.5 days (Economy) | Scales exactly as designed — carriers execute on speed reliably |

**So what:** carriers differentiate cleanly on speed and not at all on reliability. Paying for Premium buys a faster average, not a safer one.

---

### 5.2 Warehouse Performance

<div align="center">
<img width="1317" height="647" alt="Image" src="https://github.com/user-attachments/assets/f24ed7d2-e775-430b-8c40-40700f97f836" />

</div>

| Business Metric | Value | Historical / Comparative Trend |
|---|---|---|
| Network-wide avg. utilization | **1.87%** | Peak facility utilization is only 5.53% — no facility is close to saturated |
| Utilization by region | East 4.18% (highest) / West 0.90% (lowest) | 4.6× spread between busiest and quietest region |
| Correlation: warehouse rating ↔ SLA breach | **-0.002** | Effectively zero — top-rated Tier 1 facilities (Delhi, Chennai, Mumbai) post some of the worst SLA numbers |
| Correlation: utilization ↔ SLA breach | **0.017** | Also effectively zero — busier facilities aren't the ones failing |

**So what:** this rules out the two easiest explanations (facility quality, facility busyness). Whatever's driving delivery failures is happening upstream of the warehouse floor.

---

### 5.3 Region Performance

<div align="center">
<img width="1320" height="647" alt="Image" src="https://github.com/user-attachments/assets/dea6b0b3-b1cd-471a-a502-580b9193dfa0" />

</div>

| Business Metric | Value | Historical / Comparative Trend |
|---|---|---|
| South + North share of regional volume¹ | **53%** (130,844 + 130,092 shipments) | Central is the smallest market at 50,174 |
| Cost per kg, transit time, avg. cost | Nearly flat nationwide (~₹9.72/kg, ~4.92 days, ~₹197) | Same operating model regardless of local demand density |
| SLA breach range | 6.80% (Central, best) → 7.07% (East, worst) | Modest spread, but meaningful at this shipment volume |

**So what:** one national playbook is being run everywhere, whether or not the local market looks the same — which forfeits any regional cost or service advantage.

¹ *Computed against the Region mart's own total (492,002 shipments), which differs slightly from the 499,500-shipment total used elsewhere — see [Caveats & Assumptions](#8-caveats--assumptions).*

---

### 5.4 Seller Performance

<div align="center">
<img width="1317" height="647" alt="Image" src="https://github.com/user-attachments/assets/07fa2ee7-6911-4d08-b108-bf59af33fb4f" />
</div>

| Business Metric | Value | Historical / Comparative Trend |
|---|---|---|
| SLA breach spread across 2,000 sellers | **0% – 22.99%** | Widest spread of any mart in this project — far beyond carrier (1.2 pt) or region (0.3 pt) spreads |
| Sellers above 15% breach | **10 sellers** | Worst offender pulls ₹8.9M in revenue while breaching 22.62% of shipments — high value, high risk, simultaneously |
| Avg. breach by tier | Premium 6.76% (best) | Still doesn't fully explain the spread — poor performers appear inside every tier |

**So what:** seller dispatch behavior is a real, isolable risk factor that no carrier or warehouse dashboard would ever surface on its own.

---

### 5.5 Financial Impact

<div align="center">
<img width="1320" height="649" alt="Image" src="https://github.com/user-attachments/assets/7c71338f-e0c1-45d5-911e-84fb825f7145" />
</div>

| Business Metric | Value | Historical / Comparative Trend |
|---|---|---|
| Total logistics spend | **₹98.57M** | Across 499,500 shipments, ~₹197/shipment average |
| Cost of SLA-breached shipments | **₹6.88M (6.98% of spend)** | 34,811 shipments missed SLA |
| Avg. cost — breached vs. on-time shipment | ₹197.77 vs. ₹197.24 | **Virtually identical** — no financial penalty exists anywhere for a failed delivery |

**So what:** this is the single most directly fixable finding in the dataset — a performance-linked carrier contract targets exactly this gap.

---

### 5.6 Enterprise Overview (Daily Trend, 2022–2025)

<div align="center">
</div>

| Business Metric | Value | Historical / Comparative Trend |
|---|---|---|
| Avg. daily orders | 342 | Peak day: 786 orders |
| Avg. SLA breach | 6.97% | Peak day: **13.08%** — nearly double baseline |
| Year-over-year order volume | Flat (124,577–125,466 orders/year) | Not a growth story — the network's own baseline demand is enough to stress it |

**So what:** peak-day failures happen without a growth trend to explain them, which points to a process-elasticity problem (labor, pickup cadence) rather than a scale problem.

---

## 6. Recommendations

Prioritized by impact vs. effort — the same triage a real budget cycle applies.

**Do first — low effort, real impact**
- Score sellers on SLA performance and act on the worst 10 specifically, rather than a blanket policy across all 2,000
- Move to performance-linked carrier contracts — a breached shipment currently costs the same as a successful one
- Cap Premium carrier usage to shipments where speed genuinely matters, given the 5.8× cost gap isn't buying reliability
- Route by shipment weight, not tier alone, so heavy shipments default to cheaper cost-per-kg carriers

**Next — bigger lift, still high value**
- Evaluate warehouse network consolidation given 1.87% average utilization
- Rebalance inventory toward where demand actually concentrates (South/North) instead of where it currently sits (East)
- Build a peak-day operating mode (added labor, faster pickup cadence) instead of assuming idle capacity absorbs demand spikes on its own
- Move the highest-risk sellers toward managed/company-controlled fulfillment

**Longer horizon**
- Move to volume- or zone-based carrier pricing instead of a flat national rate
- Let future warehouse investment follow demand data instead of uniform geographic coverage
- Build toward dynamic, rules-based carrier allocation instead of static tier routing

**The through-line:** almost none of this requires new capital. It requires using the infrastructure that already exists differently — which is usually the recommendation that gets funded first, because it doesn't ask for a bigger budget, it asks for better discipline.

---

## 7. Tech Stack, Architecture & Code

| Layer | Tool | Notes |
|---|---|---|
| Data generation | Python | Builds operational entities and injects realistic anomalies |
| Raw storage | Parquet | Immutable Bronze source |
| Warehouse | DuckDB | Embedded OLAP — see note below |
| Transformation | dbt Core | Tests, docs, and lineage a raw SQL script doesn't give you |
| Orchestration | Apache Airflow (in Docker) | Local orchestration, not a managed cloud instance |
| Governance | dbt schema tests (YAML) | Enforced contracts between Bronze/Silver/Gold |
| Reporting | Interactive HTML dashboard | See `/dashboards` |

**On DuckDB vs. a cloud warehouse:** this project was originally built against Snowflake and moved to DuckDB once trial access ran out. For a local portfolio build it's a reasonable trade — same SQL ergonomics, zero infrastructure to manage — but it's an embedded engine, not a distributed cloud warehouse, and the dbt models don't reference anything DuckDB-specific. Pointing this project at Snowflake or BigQuery is a config change, not a rewrite.

**Repository structure:**
```
marketplace-logistics-intelligence-platform/
├── data/{bronze, gold}
├── python/{generators, exports, utilities}
├── warehouse/logistics.duckdb
├── dbt/logistics_project/models/{bronze, silver, gold}
├── airflow/{dags, Dockerfile, docker-compose.yml}
├── dashboards/            # interactive HTML BI console
├── docs/                  # full technical documentation (see below)
├── images/
├── README.md
└── SETUP.md
```

**Full technical documentation** (kept out of this README so it stays scannable):

| Document | What's in it |
|---|---|
| [`docs/project_architecture.md`](./docs/project_architecture.md) | Full pipeline architecture, Airflow DAG design, and the dbt/`profiles.yml` environment-parity bug I hit and fixed during orchestration |
| [`docs/data_model.md`](./docs/data_model.md) | ERD, star schema, SCD Type 2 design and rationale |
| [`docs/data_quality_audit.md`](./docs/data_quality_audit.md) | Full data quality framework, anomaly injection and handling rules |
| [`docs/data_dictionary.md`](./docs/data_dictionary.md) | Column-level definitions for every Gold mart |
| [`docs/project_structure.md`](./docs/project_structure.md) | Repository layout and folder responsibilities |
| [`SETUP.md`](./SETUP.md) | How to reproduce the full pipeline locally |

---

## 8. Caveats & Assumptions

- **All data is synthetic.** Every figure above — the ₹98.57M spend, the 6.97% breach rate, the 22.99% seller outlier — comes from a dataset I designed and generated myself in Python. It is not a real company's financials, and I'm stating that plainly here rather than letting the findings read as market research.
- **What is real:** the architecture decisions, the data quality problems built in on purpose (and how they're handled), the orchestration bug actually hit and fixed (`docs/project_architecture.md`), and the cross-mart analytical method — that part is meant to transfer directly to a real job.
- **Shipment totals don't fully agree across marts, and that's disclosed, not hidden.** Carrier and Financial marts total 499,500 shipments; Warehouse totals 494,505 (−1.0%); Overview totals 493,940 (−1.1%); Region totals 492,002 (−1.5%). This follows each mart's own governance rules (a shipment with no assigned warehouse is excluded from the Warehouse mart, no assigned region excluded from the Region mart, etc. — see `docs/data_quality_audit.md`) rather than being an error. Practically: any "% of volume" figure in the Region section (5.3) is computed against that mart's own 492,002 total, not the 499,500 figure used in the Executive Summary — both are correct for what they're measuring, they're just not the same denominator.
- **This reflects one pipeline run, one point in time.** A production version would track KPI drift across runs, not a single snapshot.
- **Airflow runs locally in Docker**, not on managed cloud infrastructure. It demonstrates the ability to build and debug a real DAG; it does not claim production-scale orchestration experience.
- **SCD Type 2** is implemented correctly on `dim_customers` and `dim_carriers`, but the underlying change events are synthetically generated so the logic has something to track — happy to walk through that distinction directly.

---

<p align="center"><sub>Questions about any specific number, design decision, or the engineering bug above — happy to walk through it.</sub></p>
