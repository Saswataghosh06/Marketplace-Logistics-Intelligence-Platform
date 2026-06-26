# Data Dictionary

## Project

Marketplace Logistics Intelligence Platform

---

# Overview

This document describes the business purpose and key fields for every table used in the Logistics Analytics Platform.

The project follows a Medallion Architecture consisting of Bronze, Silver, and Gold layers.

---

# Bronze Layer

The Bronze layer stores raw data generated during the synthetic data creation process.

No transformations are performed in this layer.

## Tables

| Table | Description |
|--------|-------------|
| orders | Raw customer orders |
| order_items | Raw order line items |
| shipments | Raw shipment records |
| tracking_events | Raw shipment tracking events |
| customers_scd | Customer SCD Type 2 history |
| carriers_scd | Carrier SCD Type 2 history |
| sellers | Seller master data |
| warehouses | Warehouse master data |
| products | Product catalog |
| date_dimension | Calendar dimension |

---

# Silver Layer

The Silver layer standardizes schemas, enforces datatypes, and performs business transformations while intentionally preserving known data quality issues.

## dim_customers

| Column | Description |
|----------|-------------|
| customer_sk | Surrogate key |
| customer_id | Business customer identifier |
| city | Customer city |
| state | Customer state |
| country | Customer country |
| customer_region | Customer region |
| customer_segment | Customer segment |
| effective_from | SCD effective start date |
| effective_to | SCD effective end date |
| is_current | Current record flag |

---

## dim_carriers

| Column | Description |
|----------|-------------|
| carrier_sk | Surrogate key |
| carrier_id | Business carrier identifier |
| carrier_name | Carrier name |
| carrier_tier | Service tier |
| service_type | Logistics service |
| sla_target_pct | SLA target percentage |
| effective_from | SCD effective start |
| effective_to | SCD effective end |
| is_current | Current carrier version |

---

## dim_sellers

| Column | Description |
|----------|-------------|
| seller_id | Seller identifier |
| seller_name | Seller name |
| seller_tier | Marketplace seller tier |
| seller_region | Seller region |
| seller_category | Primary business category |
| rating_score | Seller rating |
| is_active | Active seller flag |

---

## dim_warehouses

| Column | Description |
|----------|-------------|
| warehouse_id | Warehouse identifier |
| warehouse_name | Warehouse name |
| warehouse_type | Fulfillment center type |
| city | Warehouse city |
| state | Warehouse state |
| region | Geographic region |
| capacity_units | Storage capacity |
| warehouse_rating | Operational rating |

---

## fct_orders

| Column | Description |
|----------|-------------|
| order_id | Order identifier |
| customer_sk | Customer surrogate key |
| order_date | Order date |
| order_status | Current order status |
| order_amount | Gross order amount |
| shipping_fee | Shipping fee |
| discount_amount | Applied discount |
| net_amount | Final customer payment |

---

## fct_order_items

| Column | Description |
|----------|-------------|
| order_item_id | Order line identifier |
| order_id | Parent order |
| seller_id | Selling merchant |
| product_id | Product identifier |
| quantity | Units purchased |
| unit_price | Selling price |
| line_amount | Revenue for line item |

---

## fct_shipments

| Column | Description |
|----------|-------------|
| shipment_id | Shipment identifier |
| order_id | Parent order |
| warehouse_id | Shipping warehouse |
| carrier_id | Logistics carrier |
| shipment_weight_kg | Shipment weight |
| shipping_cost | Shipping cost |
| dispatch_date | Dispatch date |
| promised_delivery_date | SLA delivery date |
| actual_delivery_date | Actual delivery date |
| actual_transit_days | Transit duration |
| delay_days | Delivery delay |
| is_sla_breached | SLA breach indicator |
| shipment_status | Shipment status |

---

## fct_tracking_events

| Column | Description |
|----------|-------------|
| tracking_event_id | Tracking event identifier |
| shipment_id | Shipment reference |
| order_id | Order reference |
| event_type | Logistics event |
| event_timestamp | Event timestamp |
| event_location | Event location |

---

# Gold Layer

The Gold layer contains business-ready marts optimized for reporting and dashboarding.

## mart_logistics_overview

Executive logistics KPI summary.

---

## mart_carrier_performance

Carrier operational performance including:

* Shipment volume
* SLA breach rate
* Transit performance
* Shipping cost

---

## mart_warehouse_performance

Warehouse operational performance including:

* Shipment throughput
* SLA performance
* Warehouse cost metrics
* Transit metrics

---

## mart_region_performance

Regional logistics performance including:

* Regional shipment volume
* Regional SLA breaches
* Delivery performance
* Shipping costs

---

## mart_seller_performance

Seller logistics performance including:

* Revenue
* Quantity sold
* Shipment volume
* SLA performance
* Shipping costs

---

## mart_financial_impact

Executive financial summary including:

* Total shipping spend
* Breached shipment cost
* On-time shipment cost
* Cost impact of SLA breaches

---

# Data Governance

The Gold layer excludes invalid operational records from KPI calculations where appropriate while preserving traceability to the Silver layer.

This design reflects enterprise data warehouse practices where operational anomalies remain available for audit purposes without affecting executive reporting.