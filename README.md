<!-- ========================================================= -->

<!-- HERO BANNER -->

<!-- ========================================================= -->

<p align="center">

# Marketplace Logistics Intelligence Platform

### Root Cause Analysis of Delivery Delays, SLA Breaches & Logistics Cost Optimization

**Enterprise Analytics Engineering Project**

*Transforming fragmented logistics operations into executive decision intelligence through modern Analytics Engineering, governed data modeling, and business focused analytics.*

</p>

---

<!-- HERO IMAGE -->

<p align="center">

> **[ HERO BANNER PLACEHOLDER ]**

`images/banner/repository-hero-banner.png`

</p>

---

<!-- DASHBOARD PREVIEW -->

<p align="center">

> **Executive Operations Dashboard Preview**

`images/dashboard/dashboard-overview.png`

</p>

---

# Executive Summary

Modern marketplace platforms generate millions of operational events across customers, sellers, warehouses, carriers, and delivery networks every day. While each operational system captures valuable data, decision makers often struggle to identify where delivery performance begins to deteriorate, which operational bottlenecks drive logistics costs, and how service failures impact customer experience.

The **Marketplace Logistics Intelligence Platform** was designed as an end to end Analytics Engineering solution that transforms raw operational data into trusted business intelligence. Rather than focusing on dashboard development alone, the project demonstrates how modern analytics platforms integrate data engineering, business modeling, governance, and executive reporting into a unified decision support system.

The platform follows a layered Medallion Architecture built using Python, DuckDB, dbt, SQL, and Power BI. Approximately **7.9 million synthetic operational records** were generated to simulate a realistic large scale marketplace environment, including customers, sellers, products, orders, shipments, warehouses, logistics partners, tracking events, and delivery exceptions. Each transformation layer was intentionally designed to mirror enterprise Analytics Engineering practices while preserving realistic operational anomalies for downstream analysis and governance.

The resulting analytics platform enables leadership teams to move beyond descriptive reporting and understand the operational drivers behind delivery delays, SLA breaches, warehouse bottlenecks, carrier performance, regional logistics efficiency, seller impact, and financial exposure.

---

# Why This Project Matters

Marketplace logistics directly influences customer satisfaction, operational efficiency, and profitability. A single delayed shipment may trigger increased logistics costs, customer complaints, seller dissatisfaction, refund requests, and contractual penalties.

Although organizations collect large volumes of operational data, that information is frequently distributed across multiple business systems, making it difficult to identify the true causes of logistics failures.

This project demonstrates how Analytics Engineering can bridge that gap by transforming fragmented operational data into governed business models that support faster, more informed executive decision making.

---

# Business Challenges

The platform was designed to address five operational challenges commonly faced by large marketplace organizations.

| Business Challenge                              | Operational Impact                                         |
| ----------------------------------------------- | ---------------------------------------------------------- |
| Limited visibility into carrier performance     | Higher delivery delays and increasing SLA penalties        |
| Warehouse dispatch bottlenecks                  | Reduced operational efficiency and longer processing times |
| Regional logistics inconsistency                | Uneven customer experience across markets                  |
| Limited understanding of logistics cost drivers | Rising operational expenditure                             |
| Fragmented reporting across operational systems | Slower executive decision making                           |

---

# Business Questions

Instead of producing generic operational reports, every business mart within this platform was designed to answer a specific executive question.

| Business Question                                              | Business Value                       | Executive Decision                                    |
| -------------------------------------------------------------- | ------------------------------------ | ----------------------------------------------------- |
| Which carriers contribute most to SLA breaches?                | Improve delivery reliability         | Review carrier performance and contractual agreements |
| Which warehouses create dispatch bottlenecks?                  | Increase warehouse efficiency        | Optimize staffing and warehouse operations            |
| Which customer regions experience the highest delivery delays? | Improve customer experience          | Allocate logistics capacity strategically             |
| What financial impact do SLA breaches create?                  | Reduce operational costs             | Prioritize high impact operational improvements       |
| Which sellers are most affected by logistics performance?      | Strengthen marketplace relationships | Support sellers experiencing logistics constraints    |

---

# Project Highlights

| Metric                        |                      Value |
| ----------------------------- | -------------------------: |
| Synthetic Operational Records |           **~7.9 Million** |
| Customer Orders               |                **500,000** |
| Shipment Records              |                **500,000** |
| Tracking Events               |           **5.3+ Million** |
| Business Marts                | **6 Executive Gold Marts** |
| Analytics Architecture        | **Bronze → Silver → Gold** |

---

# Business Value Delivered

The Marketplace Logistics Intelligence Platform demonstrates how modern Analytics Engineering supports executive decision making by:

* Transforming fragmented logistics operations into governed business intelligence.
* Identifying the operational drivers behind delivery delays and SLA breaches.
* Measuring the financial impact of logistics performance.
* Providing standardized executive KPIs across multiple operational domains.
* Supporting evidence based operational improvements through interactive analytics.

Rather than focusing solely on reporting historical performance, the platform establishes a scalable analytical foundation that enables leadership teams to identify operational inefficiencies before they become larger business problems.

---

# Platform Architecture

> **[ MEDALLION ARCHITECTURE PLACEHOLDER ]**

`images/architecture/medallion-architecture.png`

---

## End to End Analytics Workflow

```text
Synthetic Data Generation
            │
            ▼
   Bronze Layer (Parquet Files)
            │
            ▼
      SnowFlake Data Warehouse
            │
            ▼
     dbt Transformation Layer
            │
            ▼
    Gold Business Data Marts
            │
            ▼
 Executive Power BI Dashboards
            │
            ▼
 Business Insights & Executive Decisions
```

---

## Why a Medallion Architecture?

Rather than transforming raw operational data directly into dashboards, the project adopts a Medallion Architecture that separates data ingestion, transformation, and business consumption into independent layers.

This approach improves maintainability, reproducibility, governance, and scalability while reducing downstream reporting complexity.

### Bronze Layer

Stores immutable raw operational datasets generated from the synthetic marketplace environment.

### Silver Layer

Applies schema standardization, business validation, data quality rules, and dimensional modeling while intentionally preserving operational anomalies for governance and downstream analysis.

### Gold Layer

Delivers business ready analytical marts optimized for executive reporting, KPI calculation, and decision support.

---

# Analytics Engineering Philosophy

Most business dashboards begin at the reporting layer. This project was intentionally designed from the opposite direction.

Instead of asking **"What charts should be built?"**, the project began with a more fundamental question:

> **"How should operational data be engineered so executives can trust every metric they see?"**

Every architectural decision was therefore made with scalability, governance, reproducibility, and business trust in mind.

The objective was not simply to build dashboards, but to design an analytical platform capable of transforming raw logistics operations into governed executive intelligence.

---

# Engineering Decisions

Every technology choice was driven by an operational requirement rather than personal preference.

---

## Why Synthetic Data?

Most publicly available ecommerce datasets stop at customer orders.

Very few include:

* Warehouse operations
* Carrier performance
* Shipment lifecycle
* Tracking events
* Delivery exceptions
* SLA breaches
* Reverse logistics
* Penalty costs

Without these operational datasets, answering logistics questions becomes impossible.

Instead of simplifying the business problem, the project generated an enterprise scale synthetic marketplace environment containing realistic business relationships across multiple operational domains.

---

## Why Python?

Python was selected because it provides complete control over realistic data generation.

Instead of randomly generating records, Python was used to simulate actual marketplace operations, including:

* Customer purchasing behaviour
* Seller inventory
* Warehouse allocation
* Carrier assignment
* Shipment movement
* Delivery outcomes
* Operational anomalies
* SLA failures

The generator intentionally produces business scenarios that resemble production logistics environments.

---

## Why Parquet?

The Bronze layer stores immutable datasets as Apache Parquet.

Advantages include:

* Columnar storage
* Better compression
* Faster analytical queries
* Native compatibility with DuckDB
* Warehouse portability

The Bronze layer therefore behaves similarly to a modern cloud data lake.

---

## Why DuckDB?

The architecture was originally designed around Snowflake.

For this portfolio implementation, DuckDB was selected because it provides:

* Embedded analytical database
* Native Parquet support
* High performance analytical queries
* Zero infrastructure setup
* Fully reproducible local development

Most importantly, the transformation layer remains warehouse agnostic, allowing future migration to Snowflake, BigQuery, or Databricks with minimal changes.

---

## Why dbt?

Traditional SQL scripts become difficult to maintain as projects grow.

dbt introduces software engineering practices into analytics development through:

* Modular SQL models
* Dependency management
* Documentation
* Testing
* Version control
* Reusable transformations

Rather than writing isolated SQL queries, every transformation becomes part of a governed analytical pipeline.

---

## Why a Medallion Architecture?

Operational data changes throughout its lifecycle.

Separating ingestion, transformation, and reporting creates clear ownership at every stage.

| Layer  | Responsibility                                             |
| ------ | ---------------------------------------------------------- |
| Bronze | Immutable raw operational data                             |
| Silver | Business validation, standardization, dimensional modeling |
| Gold   | Executive KPIs and analytical business marts               |

This separation improves maintainability while preventing reporting logic from contaminating raw operational data.

---

## Why Business Marts?

Executives rarely analyse raw transactional tables.

Instead, they ask questions.

Examples include:

* Which carrier performs worst?
* Which warehouse causes dispatch delays?
* Which region experiences poor delivery performance?
* What financial impact do SLA breaches create?

Each Gold Mart was therefore designed around a business decision rather than a database entity.

---

# Data Quality Framework

> **[ DATA QUALITY FRAMEWORK PLACEHOLDER ]**

`images/diagrams/data-quality-framework.png`

Reliable analytics begins with reliable data.

Instead of assuming perfect operational data, the project intentionally introduces realistic inconsistencies that mirror production environments.

Examples include:

* Missing values
* Duplicate records
* Country inconsistencies
* Future dates
* Weight outliers
* Missing warehouse assignments
* Missing delivery dates
* Delivery exceptions

These anomalies allow the transformation layer to demonstrate realistic data governance rather than artificial data cleaning.

---

## Bronze Layer Philosophy

The Bronze layer intentionally preserves operational reality.

No business rules are applied.

Raw data remains immutable.

This allows complete traceability back to the original operational records.

---

## Silver Layer Philosophy

The Silver layer standardizes operational data while preserving meaningful business anomalies.

Typical transformations include:

* Data type standardization
* Schema normalization
* Fact and dimension modeling
* Surrogate keys
* Business validations
* Referential integrity
* Consistent naming conventions

Rather than hiding operational issues, the Silver layer exposes them for downstream governance.

---

## Gold Layer Philosophy

Only trusted business metrics reach the Gold layer.

Each business mart contains executive ready KPIs designed for reporting and strategic decision making.

This ensures every Power BI visualization consumes governed business data rather than raw operational transactions.

---

# Gold Business Marts

The analytical layer consists of six business marts.

Each mart answers a specific operational question.

---

## Executive Logistics Overview

> **[ PLACEHOLDER ]**

`images/gold-marts/mart-logistics-overview.png`

### Purpose

Provide leadership with a complete operational snapshot of marketplace logistics performance.

### Business Questions

* How many orders were fulfilled?
* How many shipments were completed?
* What percentage breached SLA?
* What are current logistics costs?
* How are operations trending over time?

### Primary KPIs

* Orders
* Shipments
* Revenue
* SLA Breach %
* Shipping Cost
* Transit Time

---

## Carrier Performance

> **[ PLACEHOLDER ]**

`images/gold-marts/mart-carrier-performance.png`

### Purpose

Evaluate logistics partner reliability.

### Business Questions

* Which carriers generate the highest delivery delays?
* Which carrier contributes most to SLA penalties?
* Which carrier demonstrates consistent performance?

### Primary KPIs

* On Time Delivery %
* SLA Breach %
* Delay Days
* Reliability Score
* Shipping Volume

---

## Warehouse Performance

> **[ PLACEHOLDER ]**

`images/gold-marts/mart-warehouse-performance.png`

### Purpose

Measure warehouse operational efficiency.

### Business Questions

* Which warehouses experience dispatch bottlenecks?
* Which facilities delay shipments?
* Which warehouses process orders most efficiently?

### Primary KPIs

* Dispatch Time
* Shipment Volume
* Delay Rate
* Processing Efficiency

---

## Regional Performance

> **[ PLACEHOLDER ]**

`images/gold-marts/mart-region-performance.png`

### Purpose

Understand geographical delivery performance.

### Business Questions

* Which regions experience higher delays?
* Which markets require operational investment?
* How does logistics performance vary geographically?

### Primary KPIs

* Regional SLA %
* Transit Time
* Delay Days
* Shipment Volume

---

## Seller Performance

> **[ PLACEHOLDER ]**

`images/gold-marts/mart-seller-performance.png`

### Purpose

Measure how logistics operations impact marketplace sellers.

### Business Questions

* Which sellers experience the highest logistics disruption?
* Which sellers require operational support?
* How does logistics affect seller performance?

### Primary KPIs

* Orders
* Shipments
* Delay Rate
* Revenue
* Seller Ranking

---

## Financial Impact

> **[ PLACEHOLDER ]**

`images/gold-marts/mart-financial-impact.png`

### Purpose

Quantify the business cost of operational inefficiencies.

### Business Questions

* What is the financial impact of SLA breaches?
* Which operational issues increase logistics costs?
* Where should investment generate the highest return?

### Primary KPIs

* Shipping Cost
* Estimated Penalty Cost
* Revenue
* Cost Per Shipment
* Financial Exposure

---

# Why These Marts Matter

Instead of organizing analytics around database tables, each mart was designed around an executive decision.

This shifts the analytical model from **data storage** toward **business outcomes**, ensuring every dashboard directly supports operational planning, performance monitoring, and strategic decision making.

---

# Executive Dashboard Experience

The Power BI solution was designed using an executive first approach.

Rather than maximizing the number of visualizations, every dashboard answers a focused operational question that supports business decision making.

The dashboard follows a consistent design language across all report pages, emphasizing readability, KPI visibility, business storytelling, and executive usability.

---

# Executive Overview Dashboard

> **[ DASHBOARD PLACEHOLDER ]**

`images/dashboard/executive-overview.png`

## Business Headline

### Logistics Performance Remains Stable, but Delivery Delays Continue to Increase Operating Costs

### Purpose

Provide executives with a single operational view of marketplace logistics performance.

### Questions Answered

* How many orders are being processed?
* How many shipments have been completed?
* Are deliveries meeting SLA commitments?
* How are logistics costs changing?
* Which operational metrics require immediate attention?

### Executive Decisions Supported

* Monitor overall operational health.
* Identify deteriorating logistics performance.
* Prioritize operational improvement initiatives.
* Track organization wide KPIs.

---

# Carrier Performance Dashboard

> **[ DASHBOARD PLACEHOLDER ]**

`images/dashboard/carrier-performance.png`

## Business Headline

### Carrier Performance Varies Significantly Across Logistics Partners

### Purpose

Measure logistics partner reliability and identify carriers responsible for operational delays.

### Questions Answered

* Which carriers generate the highest SLA breaches?
* Which carrier delivers most consistently?
* How do shipping volumes affect carrier performance?
* Which carriers require operational review?

### Executive Decisions Supported

* Renegotiate carrier contracts.
* Reallocate shipment volume.
* Improve delivery reliability.
* Reduce SLA penalties.

---

# Warehouse Performance Dashboard

> **[ DASHBOARD PLACEHOLDER ]**

`images/dashboard/warehouse-performance.png`

## Business Headline

### Dispatch Bottlenecks Continue to Reduce Warehouse Throughput

### Purpose

Evaluate warehouse operational efficiency.

### Questions Answered

* Which warehouses process shipments most efficiently?
* Which facilities experience dispatch delays?
* Which warehouses require operational improvement?

### Executive Decisions Supported

* Optimize staffing.
* Balance warehouse capacity.
* Reduce dispatch delays.
* Improve warehouse utilization.

---

# Regional Performance Dashboard

> **[ DASHBOARD PLACEHOLDER ]**

`images/dashboard/regional-performance.png`

## Business Headline

### Delivery Performance Differs Across Regional Logistics Networks

### Purpose

Compare logistics performance across geographical regions.

### Questions Answered

* Which regions experience higher delivery delays?
* Where are SLA breaches concentrated?
* Which markets require operational investment?

### Executive Decisions Supported

* Improve regional distribution.
* Optimize logistics routes.
* Allocate transportation resources.
* Improve customer experience.

---

# Seller Performance Dashboard

> **[ DASHBOARD PLACEHOLDER ]**

`images/dashboard/seller-performance.png`

## Business Headline

### Logistics Performance Directly Influences Seller Experience

### Purpose

Measure how operational performance affects marketplace sellers.

### Questions Answered

* Which sellers experience higher shipment delays?
* Which sellers generate greater shipment volumes?
* Which sellers require operational support?

### Executive Decisions Supported

* Improve seller satisfaction.
* Prioritize strategic sellers.
* Reduce seller complaints.
* Strengthen marketplace relationships.

---

# Financial Impact Dashboard

> **[ DASHBOARD PLACEHOLDER ]**

`images/dashboard/financial-impact.png`

## Business Headline

### Operational Inefficiencies Continue to Increase Logistics Costs

### Purpose

Measure the financial consequences of delivery performance.

### Questions Answered

* What is the cost of SLA breaches?
* Which operational failures generate the greatest financial impact?
* Which improvements produce the highest return?

### Executive Decisions Supported

* Reduce logistics expenditure.
* Prioritize operational investments.
* Improve profitability.
* Support budget planning.

---

# Business Recommendations

The analytical platform identifies several opportunities to improve marketplace logistics performance.

## Carrier Optimization

Monitor carrier reliability continuously and rebalance shipment allocation toward higher performing logistics partners.

**Expected Business Impact**

* Reduced SLA breaches
* Lower penalty costs
* Improved customer satisfaction

---

## Warehouse Optimization

Increase visibility into warehouse dispatch bottlenecks and redistribute operational capacity before congestion affects downstream deliveries.

**Expected Business Impact**

* Faster shipment processing
* Improved warehouse efficiency
* Lower delivery delays

---

## Regional Logistics Planning

Use regional performance analytics to identify underserved markets and optimize transportation networks.

**Expected Business Impact**

* Better delivery consistency
* Improved customer experience
* Higher operational efficiency

---

## Executive KPI Governance

Establish standardized KPI definitions across departments to ensure consistent reporting and trusted executive decision making.

**Expected Business Impact**

* Greater reporting consistency
* Faster executive decision making
* Improved cross functional collaboration

---

# Project Challenges

Although the final platform appears straightforward, developing a reliable analytical solution required significant engineering effort.

## Learning dbt While Building a Production Style Project

Rather than completing tutorials independently, dbt was learned by implementing it directly within a complete Analytics Engineering workflow.

This required understanding:

* Model dependencies
* Materializations
* Refactoring SQL into modular transformations
* Testing
* Documentation
* Data lineage

The learning process became part of the engineering experience itself.

---

## Generating Realistic Operational Data

Synthetic data generation proved to be the most technically demanding component of the project.

Instead of randomly generating records, the objective was to preserve realistic relationships across millions of operational events while ensuring downstream KPIs remained logically consistent.

This included maintaining relationships between:

* Orders
* Shipments
* Warehouses
* Carriers
* Sellers
* Tracking Events
* Delivery Outcomes

A single inconsistency introduced during generation could propagate across multiple Gold marts and dashboards.

---

## Business Validation Beyond SQL

One of the most valuable lessons came after the dbt models successfully executed.

Although transformation tests passed, several Power BI metrics produced unexpected business results.

This required tracing KPIs backward through:

Power BI

↓

Gold Marts

↓

Silver Models

↓

Fact Tables

↓

Synthetic Data Generation

Rather than assuming the dashboard was correct because the SQL executed successfully, every metric was manually validated against business expectations.

This iterative debugging process significantly strengthened the overall analytical quality of the platform.

---

# Lessons Learned

Building this platform reinforced several important principles of modern Analytics Engineering.

* Technical correctness does not automatically produce trustworthy business metrics.
* Data validation is equally as important as data transformation.
* Executive dashboards should answer business questions rather than display isolated KPIs.
* Documentation, governance, and communication are critical components of enterprise analytics.
* Modern Analytics Engineers require business understanding in addition to technical expertise.

---

# Future Roadmap

The current implementation establishes the analytical foundation.

Future enhancements include:

* Apache Airflow workflow orchestration
* Snowflake cloud warehouse migration
* Incremental dbt models
* Docker based deployment
* CI/CD pipelines
* Automated data quality monitoring
* Real time streaming pipelines
* Predictive delivery time estimation
* Machine learning based anomaly detection
* Semantic Layer implementation

These enhancements will extend the project from a portfolio demonstration into a production ready enterprise analytics platform.

---

# Closing Statement

The Marketplace Logistics Intelligence Platform demonstrates how Analytics Engineering extends beyond writing SQL or building dashboards.

It represents the complete lifecycle of modern analytics, from synthetic operational data generation and governed transformations to executive reporting, business storytelling, and strategic decision support.

The project reflects an engineering mindset focused on designing analytical systems that are scalable, maintainable, transparent, and aligned with real business objectives rather than simply producing visualizations.
