# Marketplace Logistics Intelligence Platform

**A simulated logistics network, analyzed like a real consulting engagement.**

I generated a synthetic dataset for a national e-commerce logistics operation (~500K shipments, 25 carriers, 120 warehouses, 2,000 sellers), built a governed dbt/DuckDB warehouse on top of it, orchestrated the pipeline with Airflow in Docker, and then ran the kind of diagnostic a logistics ops consultant would run: not "here's a dashboard," but "here's why the numbers look the way they do, and here's what I'd fix first." Headline finding: premium carriers cost 5.8x more per kg than economy carriers in this dataset, for statistically identical SLA performance. Setup and reproduction steps live in [`SETUP.md`](./SETUP.md).

<p>
  <img alt="status" src="https://img.shields.io/badge/status-portfolio_case_study-blue">
  <img alt="data" src="https://img.shields.io/badge/data-synthetic_%2F_self_generated-lightgrey">
  <img alt="stack" src="https://img.shields.io/badge/stack-dbt_%7C_DuckDB_%7C_Airflow_%7C_Docker-orange">
  <img alt="quality" src="https://img.shields.io/badge/data_quality-0_nulls_%7C_0_duplicates-brightgreen">
</p>

**Author:** Saswata Ghosh · [GitHub](https://github.com/Saswataghosh06/Marketplace-Logistics-Intelligence-Platform) · [LinkedIn](#) · [Email](#)

---

## A note on the data, up front

Every number below — the ₹98.57M in logistics spend, the 6.97% SLA breach rate, the seller with a 22.99% failure rate — comes from a dataset I designed and generated myself in Python. It's not a real company's financials. I'm stating this here instead of burying it in a caveats section at the bottom, because pretending otherwise would be the fastest way to lose credibility with anyone who asks a follow-up question.

What *is* real: the architecture decisions, the data quality problems I deliberately built in (and how I chose to handle them), the pipeline bug I actually hit and fixed, and the analytical method — reading six business-domain marts together to find a story none of them tell alone. That's the part meant to transfer to an actual job.

Read the findings below as "what this simulated network shows," not "market research." I've tried to write it that way consistently rather than just saying it once and forgetting.

---

## Table of Contents

1. [Why I Built This](#why-i-built-this)
2. [Architecture](#architecture)
3. [Data Model](#data-model)
4. [Data Quality & Governance](#data-quality--governance)
5. [Findings, Mart by Mart](#findings-mart-by-mart)
6. [Cross-Mart Synthesis](#cross-mart-synthesis)
7. [Recommendations, If This Were Real](#recommendations-if-this-were-real)
8. [A Real Bug I Hit](#a-real-bug-i-hit)
9. [Limitations](#limitations)
10. [Repository Structure](#repository-structure)
11. [What's Next](#whats-next)

---

## Why I Built This

Most portfolio data projects grab a clean Kaggle CSV and make a chart. I wanted to practice the harder and more realistic version of the job: design a business scenario, generate data messy enough to be believable, build the pipeline that turns that mess into something trustworthy, and then actually reason about what the numbers mean for a business.

The scenario I picked: a logistics network that looks fine on paper — decent infrastructure, stable carriers, steady demand — but keeps missing delivery promises. The question I set out to answer:

> "If the infrastructure looks adequate, why isn't performance matching it, and what would I fix first with a limited budget?"

That's a question five different roles get asked in real life: a data engineer building the pipeline that surfaces it, a BI analyst building the dashboard, a business analyst writing the memo, or a consultant standing in front of the exec team. I wanted this repo to hold up under any of those lenses.

### Business questions the marts were built to answer

- Which carriers are worth the money, and which aren't?
- Are warehouses actually the bottleneck, or is it something upstream?
- Does demand match where the infrastructure is?
- Which sellers create risk that a dashboard by carrier or warehouse alone would never surface?
- What does a missed SLA actually cost, in currency, not just a percentage?

---

## Architecture

Medallion architecture (Bronze → Silver → Gold), star schema warehouse, orchestrated locally with Apache Airflow running in Docker — not a cloud-scale deployment, just a correctly-structured one.

```
Python data generator (11 entities)
        │
        ▼
Bronze — raw Parquet, immutable, untouched
        │
        ▼
load_bronze.py  →  DuckDB
        │
        ▼
dbt debug  →  dbt build
        │
        ▼
Silver — staging → dimensions → facts (DuckDB + dbt)
        │
        ▼
Gold — 6 business marts, dbt schema tests
        │
        ▼
export_gold_marts.py  →  CSV
        │
        ▼
Dashboard (HTML, in progress)
```

The whole thing runs as one Airflow DAG (`logistics_pipeline`), four tasks in sequence: `load_bronze → dbt_debug → dbt_build → export_gold`, each gated on the last one succeeding. It's containerized with Docker so dev and "production" don't silently disagree with each other — mostly.

> 📸 `images/airflow_dag_success.png` — placeholder, DAG graph view, all four tasks green
> 📸 `images/dbt_lineage_graph.png` — placeholder, full dbt lineage from source to marts

### Stack, and why each piece

| Layer | Tool | Notes |
|---|---|---|
| Data generation | Python | Builds the operational entities and injects the anomalies described below |
| Raw storage | Parquet | Immutable Bronze source |
| Warehouse | DuckDB | Embedded OLAP — see note below |
| Transformation | dbt Core | Tests, docs, and lineage that a raw SQL script doesn't give you |
| Orchestration | Apache Airflow (in Docker) | Local orchestration, not a managed cloud instance |
| Governance | dbt schema tests (YAML) | Enforced contracts between layers |
| Reporting | HTML dashboard (Power BI planned) | See [What's Next](#whats-next) |

**On DuckDB vs. a cloud warehouse:** I originally built this against Snowflake, and moved to DuckDB when my trial access ran out. It turned out to be a reasonable trade for a local portfolio project — same SQL dialect ergonomics, zero infrastructure to manage, fast enough for this data volume — but it's an embedded engine, not a distributed cloud warehouse, and I'm not pretending otherwise. The dbt models don't reference anything DuckDB-specific, so pointing this project at Snowflake or BigQuery is a config change, not a rewrite.

---

## Data Model

7 dimensions, 4 facts, 6 Gold marts. Standard star schema.

```
dim_customers (SCD2)   ┐
dim_products           ├──► fct_orders ──┐
dim_sellers            │    fct_order_items
dim_carriers (SCD2)    │    fct_shipments ──┐
dim_warehouses         │    fct_tracking_events
dim_regions            │                     │
dim_date               ┘                     ▼
                                    6 Gold marts
```

`dim_customers` and `dim_carriers` use SCD Type 2 — meaning a change to a customer's segment or a carrier's tier is preserved as history rather than overwritten. In a real business this matters for reconstructing "what did we know at the time." In this simulated dataset it's genuinely simpler than that: the generator writes synthetic change events into these two dimensions specifically so the SCD2 logic has something real to track. I'll say that plainly if asked in an interview — the pattern is implemented correctly, the trigger for it is manufactured, and I know the difference.

### Gold marts, verified against the actual exported files

| Mart | Grain | Records | Columns |
|---|---|---|---|
| `mart_logistics_overview` | Daily | 1,461 | 21 |
| `mart_carrier_performance` | Carrier | 25 | 13 |
| `mart_warehouse_performance` | Warehouse | 120 | 19 |
| `mart_region_performance` | Region | 5 | 11 |
| `mart_seller_performance` | Seller | 2,000 | 19 |
| `mart_financial_impact` | Enterprise summary | 1 | 15 |

Every row/column count above is a direct recount from the CSVs in this repo, not something carried over from an earlier draft.

---

## Data Quality & Governance

I built anomalies into the data on purpose — missing references, duplicate events, future-dated records, negative quantities — because a warehouse that only ever sees clean data doesn't prove you can handle governance. The rule I followed: preserve everything in Bronze, keep anomalies visible in Silver for investigation, and only let clean, business-valid rows reach Gold.

| Anomaly | What it simulates | Silver | Gold |
|---|---|---|---|
| Missing customer reference | Delayed CRM sync | Kept | Excluded from customer KPIs |
| Missing warehouse assignment | Unallocated shipment | Kept | Excluded from warehouse mart |
| Future-dated orders | Timezone/clock sync issues | Kept | Excluded from trend KPIs |
| Duplicate tracking events | Event-stream replay | Kept | Aggregated |
| Missing product references | Catalog sync failure | Kept | Excluded where required |
| Negative quantities | Transaction correction | Kept | Excluded from revenue |

I re-ran the null and duplicate checks myself rather than trusting the old docs:

| Mart | Nulls | Duplicates | Grain confirmed |
|---|---|---|---|
| Overview | 0 | 0 | 1,461 unique dates, 2022–2025, no gaps |
| Carrier | 0 | 0 | 25 unique carriers |
| Warehouse | 0 | 0 | 120 unique warehouses |
| Region | 0 | 0 | 5 unique regions |
| Seller | 0 | 0 | 2,000 unique seller IDs |
| Financial | 0 | 0 | 1 enterprise row |

Business rules — shipment volume ≥ 0, revenue ≥ 0, utilization and SLA breach between 0–100%, transit days > 0, seller ratings 1–5 — all passed dbt's generic and custom tests.

> 📸 `images/vscode_project_structure.png` — placeholder, project structure + dbt schema tests

**One thing I noticed and didn't smooth over:** regional shipment totals differ by under 1% depending on whether you roll them up from the warehouse's region or the customer's region on the order — those aren't always the same, and I left both readings visible rather than forcing them to agree.

---

## Findings, Mart by Mart

Same caveat as above applies to everything in this section: these are patterns in the simulated dataset, described the way I'd describe real ones.

### Carriers

25 carriers, 4 tiers. Standard and Express carriers carry roughly three-quarters of all volume — FedEx and BlueDart alone move about 27,000 shipments each. Premium carriers (TCIExpress, Trackon, Borzo, Aramex) handle the least volume but charge ₹41/kg on average against Economy's ₹7.1/kg — 5.8x the cost.

SLA breach rates, though, barely move by tier: Economy averages 6.99%, Express 6.91%, Premium 7.22%. Aramex is the single worst performer at 7.73%; Borzo the best at 6.55%. Transit time scales exactly the way you'd expect by tier (Premium ~1.6 days up to Economy ~8.5 days) — carriers deliver on speed, not on reliability, and the tiers don't actually separate on the metric that matters most.

### Warehouses

120 facilities, average utilization 1.87%, peak 5.53%. Not a typo — the network is running at a fraction of its built capacity. East India runs the hottest (4.18% utilization); West the coolest (0.90%). Warehouse rating has essentially zero correlation with SLA breach (-0.002), and utilization itself barely correlates with it either (0.017). Some of the highest-rated Tier 1 facilities — Delhi, Chennai, Mumbai — post some of the worst SLA numbers in the network.

So it's not a capacity story. Whatever's driving delivery failures, it isn't "warehouses are too full" or "the low-rated ones are dragging things down."

### Regions

South (130,844 shipments) and North (130,092) together make up 53% of national volume; Central is the smallest market at 50,174. Yet shipping cost, cost/kg, and transit time barely move across regions — everything sits within a tight band regardless of local demand density. SLA breach ranges from 6.80% (Central, best) to 7.07% (East, worst) — a real but modest spread.

Translation: this is one national operating model applied everywhere, whether or not the local market actually looks the same.

### Sellers

2,000 sellers. SLA breach ranges from 0% to 22.99% — by far the widest spread of any mart in this project, well beyond what carriers or warehouses show. Ten sellers sit above 15% breach; the worst, at 22.99%, and another at 22.62% while still pulling in ₹8.9M in revenue — high value, high risk, at the same time. Tier helps a little (Premium sellers average 6.76% breach, best of the three) but doesn't fully explain the spread; bad-performing sellers show up inside every tier.

### Financial impact

Total spend: ₹98.57M across 499,500 shipments, ~₹197 per shipment. The 34,811 shipments that missed SLA cost ₹6.88M — 6.98% of total spend — and cost, on average, almost exactly the same per shipment as the ones that didn't breach (₹197.77 vs. ₹197.24). There's no financial penalty built in anywhere for a failed delivery.

### Overview (daily trend, 2022–2025)

Average 342 orders/day, peak 786. Average SLA breach 6.95%, peak day 13.08% — nearly double. Order volume is flat year over year (each year lands between 124,577 and 125,466 orders), so this isn't a growth story — the network's own baseline demand is enough to stress it on its worst days.

---

## Cross-Mart Synthesis

Each mart above holds up fine on its own. Read together, they tell a different story than any one of them tells alone — this is the part of the exercise I found most useful to actually do, not just claim I did.

**Idle infrastructure, active failures.** Warehouses sit at 1.87% average utilization. SLA breach still averages 6.95% and spikes to 13.08%. If capacity were the constraint, it wouldn't look like this. Something else is driving the failures.

**Demand and infrastructure aren't looking at the same map.** South and North are the two biggest markets, and South runs at 1.17% utilization. East India, a mid-sized market by comparison, runs hot at 4.18% utilization *and* posts the network's worst SLA number. Kolkata and Patna — both East India — are among the busiest facilities in the whole network. Inventory isn't sitting where the demand is.

**Premium price, average reliability.** Already covered above, but it's worth repeating in context: 5.8x the cost for a tier of service that doesn't clear a statistically meaningful reliability bar over Economy.

**Seller behavior is a separate risk axis.** Warehouses are idle, carriers are consistent — by elimination, the 0–22.99% spread on the seller side is doing a lot of the work here, and it's invisible if you're only looking at carrier or warehouse dashboards.

**Peak days break the network without breaking capacity.** SLA breach nearly doubles on the busiest days while warehouse capacity is nowhere close to maxed out even then. The bottleneck on those days is process — labor, pickup cadence, how fast things move — not physical space.

**Flat pricing at real volume.** ₹197/shipment barely moves across 499,500 annual shipments, four years, five regions. At that scale, flat per-shipment pricing suggests the carrier contracts aren't structured around volume at all.

If I had to compress this into one sentence for an interview: *the network has enough infrastructure, stable carriers, and predictable demand — the problem is where things are allocated, not how much of them exist.*

---

## Recommendations, If This Were Real

Prioritized the way I'd actually triage a findings list — impact against effort — not because a template told me to, but because that's the question an exec actually asks.

**Do first (low effort, real impact):**
- Score sellers on SLA performance and hold the worst 10 accountable specifically, rather than applying blanket policy across all 2,000
- Tie carrier payment to performance — right now a breached shipment costs the same as a successful one
- Cap Premium carrier usage to shipments where speed genuinely matters, given the cost gap isn't buying reliability
- Route by weight, not just tier, so heavy shipments default to the cheaper cost-per-kg carriers

**Worth doing next (bigger lift, still high value):**
- Actually look at consolidating warehouse footprint given 1.87% average utilization
- Rebalance inventory toward where demand actually is (South/North) instead of where it currently sits (East)
- Build a peak-day operating mode — more labor, faster pickup cadence — instead of assuming idle capacity will absorb the spike on its own
- Move high-risk sellers toward managed fulfillment rather than leaving dispatch timing entirely up to them

**Longer horizon:**
- Move toward volume- or zone-based carrier pricing instead of a flat national rate
- Let future warehouse investment follow actual demand data instead of uniform geographic coverage
- Build toward dynamic, rules-based carrier allocation instead of static tier routing

The through-line: almost none of this needs new capital. It needs the existing infrastructure used differently. That's usually the recommendation that actually gets funded, because it doesn't ask for a bigger budget — it asks for better discipline.

---

## A Real Bug I Hit

This part isn't simulated. Early on, the Airflow DAG failed at the `dbt_build` step on five separate runs, inconsistently — no code changes between the failing and succeeding runs, which is the most annoying kind of bug to chase because it looks like flakiness instead of an actual defect.

The cause: dbt resolves its DuckDB path and project directory through `profiles.yml`, which pulls from environment variables. On my Windows machine, those variables resolved to Windows-style paths that worked fine locally. Inside the Docker container running on Linux — which is where Airflow actually executes the DAG — those same variables either weren't set or pointed at paths that don't exist on a Linux filesystem. `dbt debug` would sometimes pass anyway (using a stale or partially-correct path), and then `dbt build` would fail once it actually tried to read or write the DuckDB file.

It wasn't a task-ordering problem — `load_bronze → dbt_debug → dbt_build → export_gold` was dependency-correct the whole time. It was an environment-parity problem: dev and orchestrated execution were quietly resolving different physical paths from the same config.

Fix: pulled every path reference out of hardcoded values and into environment variables injected at container runtime via `docker-compose.yml`, and kept `dbt debug` as its own explicit DAG step ahead of `dbt build` so a bad connection fails immediately and visibly instead of surfacing three steps later as a confusing build error. Then I tore the whole Docker environment down and rebuilt it from scratch a few times to confirm it wasn't a fluke.

The general lesson, beyond this one bug: "works on my machine" is usually an environment-variable problem wearing a disguise.

---

## Limitations

- Every dataset here is synthetic, generated by a Python script I wrote — restated one more time because it matters and because I'd rather over-disclose than have someone find out mid-interview.
- The dashboard layer (HTML now, Power BI planned) isn't built yet — everything in this README was checked against the raw Gold CSVs directly, not a dashboard.
- Regional shipment totals differ by under 1% depending on aggregation path — noted above, not hidden.
- This reflects one pipeline run, one point in time. A production version would track KPI drift across runs, not just a single snapshot.
- Airflow here runs locally in Docker. It proves I can build and debug a real DAG; it doesn't claim experience running orchestration at cloud/production scale.

---

## Repository Structure

```
marketplace-logistics-intelligence-platform/
│
├── data/
│   ├── bronze/              # raw synthetic Parquet
│   └── gold/                # exported Gold mart CSVs
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
│       └── models/
│           ├── bronze/
│           ├── silver/{staging,dimensions,facts}
│           └── gold/
│
├── airflow/
│   ├── dags/
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── docs/
├── images/
├── dashboards/
├── README.md
├── SETUP.md
└── requirements.txt
```

---

## What's Next

- Build the HTML dashboard (in progress) covering all six marts
- Swap in real screenshots for the placeholders in this README
- Track KPIs across multiple pipeline runs instead of one snapshot
- Point the dbt project at Snowflake instead of DuckDB, since the models were written to not depend on anything DuckDB-specific
- Extend seller risk beyond SLA breach % into something closer to a composite risk score

---

If you want to walk through any specific number, decision, or the bug above in more depth, I'm glad to.
