# DATA_MODEL.md

# Marketplace Logistics Intelligence Platform

## Dimensional Data Model

---

# Purpose

This document describes the logical and physical data model used in the Marketplace Logistics Intelligence Platform.

The warehouse follows a Star Schema designed using modern dimensional modeling principles. The model organizes operational logistics data into reusable dimensions and business event driven fact tables that support analytical workloads, KPI reporting, and executive dashboards.

The design prioritizes:

* Query performance
* Simplicity
* Reusability
* Business readability
* Historical accuracy
* Scalable analytics engineering

---

# Modeling Approach

The warehouse follows a dimensional modeling approach consisting of:

* Dimension tables describing business entities
* Fact tables capturing measurable business events
* Gold marts aggregating business KPIs

```
                    Dimension Tables

Customers
Products
Sellers
Carriers
Warehouses
Date

          │

          ▼

        Fact Tables

Orders
Order Items
Shipments
Tracking Events

          │

          ▼

     Gold Business Marts

Carrier Performance

Warehouse Performance

Seller Performance

Region Performance

Financial Impact

Executive Overview
```

---

# Why Star Schema?

A Star Schema was selected because it provides:

* Fast analytical queries
* Simplified joins
* Consistent business metrics
* Easy dashboard development
* Reusable dimensions
* Excellent compatibility with Power BI

Unlike normalized transactional databases, the Star Schema is optimized for reporting and business intelligence.

---

# Warehouse Layers

```
Python Generator

        │

        ▼

Bronze

Raw Operational Data

        │

        ▼

Silver

Dimensions

Facts

        │

        ▼

Gold

Business Marts
```

---

# Silver Layer Data Model

The Silver layer represents the enterprise analytical warehouse.

It contains reusable dimensions and fact tables that become the foundation for all downstream reporting.

---

# Dimension Tables

Dimension tables describe business entities and provide descriptive attributes for analytical filtering and grouping.

## dim_customers

### Grain

One row per customer version.

### Key

customer_sk

### Business Purpose

Stores customer master data while preserving historical changes using Slowly Changing Dimension Type 2.

### Used By

* fct_orders

---

## dim_carriers

### Grain

One row per carrier version.

### Key

carrier_sk

### Business Purpose

Stores carrier attributes and historical SLA configurations.

### Used By

* fct_shipments

---

## dim_products

### Grain

One row per product.

### Key

product_id

### Business Purpose

Provides product attributes for revenue and seller analysis.

### Used By

* fct_order_items

---

## dim_sellers

### Grain

One row per seller.

### Key

seller_id

### Business Purpose

Stores seller profile information used for operational and revenue reporting.

### Used By

* fct_order_items

---

## dim_warehouses

### Grain

One row per warehouse.

### Key

warehouse_id

### Business Purpose

Provides warehouse descriptive information for logistics reporting.

### Used By

* fct_shipments

---

## dim_date

### Grain

One row per calendar date.

### Key

date_key

### Business Purpose

Supports time based reporting across all business processes.

### Used By

* mart_logistics_overview

---

# Fact Tables

Fact tables capture measurable business events.

---

## fct_orders

### Grain

One row per customer order.

### Business Event

Customer places an order.

### Measures

* Order Amount
* Shipping Fee
* Discount
* Net Amount

### Dimensions

* Customer
* Date

---

## fct_order_items

### Grain

One row per product purchased within an order.

### Business Event

Customer purchases an individual product.

### Measures

* Quantity
* Unit Price
* Revenue

### Dimensions

* Product
* Seller
* Order

---

## fct_shipments

### Grain

One row per shipment.

### Business Event

Shipment moves through the logistics network.

### Measures

* Shipping Cost
* Transit Days
* Delay Days
* Shipment Weight
* SLA Breach

### Dimensions

* Carrier
* Warehouse
* Customer Region
* Order

---

## fct_tracking_events

### Grain

One row per shipment tracking event.

### Business Event

Operational shipment status update.

### Measures

No additive business measures.

This table captures operational events used for shipment traceability and future event level analytics.

---

# Entity Relationships

```
dim_customers

        │

        ▼

fct_orders

        │

        ▼

fct_order_items

        │

 ┌──────┴─────────┐

 ▼                ▼

dim_products   dim_sellers

        │

        ▼

fct_shipments

 ┌──────┬─────────┐

 ▼      ▼         ▼

Carriers Warehouses Regions

        │

        ▼

fct_tracking_events
```

---

# Slowly Changing Dimensions

Historical tracking is implemented where business attributes change over time.

| Dimension | Type       |
| --------- | ---------- |
| Customers | SCD Type 2 |
| Carriers  | SCD Type 2 |

This ensures historical reports remain accurate even after customer or carrier attributes change.

---

# Business Event Flow

The warehouse models the complete logistics lifecycle.

```
Customer

      │

      ▼

Order Created

      │

      ▼

Order Items Generated

      │

      ▼

Shipment Created

      │

      ▼

Tracking Events Recorded

      │

      ▼

Shipment Delivered

      │

      ▼

Business KPIs Calculated
```

---

# Gold Layer Data Model

Gold marts aggregate Silver facts into business ready datasets.

| Gold Mart                  | Grain                        |
| -------------------------- | ---------------------------- |
| mart_logistics_overview    | One row per calendar date    |
| mart_carrier_performance   | One row per carrier          |
| mart_warehouse_performance | One row per warehouse        |
| mart_region_performance    | One row per customer region  |
| mart_seller_performance    | One row per seller           |
| mart_financial_impact      | Single executive summary row |

Each mart is designed around a single business problem and contains governed KPI definitions.

---

# Design Decisions

Several design decisions were made to improve analytical usability.

## Surrogate Keys

Customer and carrier dimensions use surrogate keys to support SCD Type 2 history.

## Natural Keys

Products, sellers, and warehouses retain stable business identifiers.

## Fact Separation

Orders, shipments, and tracking events are stored independently because they represent different business processes.

## Business Marts

Gold marts aggregate data by business subject rather than exposing transactional detail.

---

# Benefits

The final data model provides:

* Clear separation between descriptive data and measurable events
* High performance analytical queries
* Reusable dimensions
* Historical reporting accuracy
* Simplified Power BI modeling
* Consistent KPI calculations
* Enterprise style dimensional warehouse design

---

# Summary

The Marketplace Logistics Intelligence Platform uses a Star Schema to transform raw logistics operations into a scalable analytical warehouse.

Dimension tables describe business entities, fact tables capture operational events, and Gold marts deliver trusted KPIs for executive reporting and operational decision making.

The model balances analytical performance, historical accuracy, and business usability while following modern Analytics Engineering best practices.
