# DATA MODEL

## Project

Marketplace Logistics Intelligence Platform

---

# Modeling Approach

This project follows a dimensional modeling approach using a Star Schema.

The warehouse is organized into:

- Fact tables containing business events
- Dimension tables containing descriptive attributes
- Gold marts containing business-ready KPIs

The design supports analytical workloads, dashboard reporting, and root cause analysis for ecommerce logistics operations.

---

# Data Warehouse Layers

```
Python Generated Data
        │
        ▼
Bronze Layer
(Raw Parquet Files)
        │
        ▼
Silver Layer
(Standardized Business Tables)
        │
        ▼
Gold Layer
(Business KPI Marts)
```

---

# Silver Layer

## Dimension Tables

| Table | Description |
|----------|-------------|
| dim_date | Calendar dimension |
| dim_products | Product attributes |
| dim_customers | Customer master data |
| dim_sellers | Seller master data |
| dim_carriers | Carrier master data |
| dim_warehouses | Warehouse master data |

---

## Fact Tables

| Table | Business Event |
|----------|----------------|
| fct_orders | Customer orders |
| fct_order_items | Individual purchased items |
| fct_shipments | Shipment lifecycle |
| fct_tracking_events | Shipment tracking history |

---

# Star Schema

```
                 dim_date
                     │
                     │
                     ▼

dim_customers     fct_orders
                     │
                     │
                     ▼
              fct_order_items
              │             │
              │             │
              ▼             ▼
       dim_products     dim_sellers

                     │
                     ▼

                fct_shipments
          │          │          │
          ▼          ▼          ▼
   dim_carriers  dim_warehouses dim_date

                     │
                     ▼

          fct_tracking_events
```

---

# Gold Layer

Business-ready marts built from the Silver layer.

| Mart | Business Purpose |
|----------|----------------|
| mart_logistics_overview | Executive logistics KPIs |
| mart_carrier_performance | Carrier SLA analysis |
| mart_warehouse_performance | Warehouse bottleneck analysis |
| mart_region_performance | Regional logistics performance |
| mart_seller_performance | Seller logistics performance |
| mart_financial_impact | Cost impact of logistics operations |

---

# Modeling Principles

The warehouse follows these principles:

- Star schema design
- Single source of truth
- Reusable dimensions
- Business-oriented facts
- Modular dbt transformations
- Layered Medallion architecture

---

# Grain

## fct_orders

One row per order.

---

## fct_order_items

One row per purchased product within an order.

---

## fct_shipments

One row per shipment.

---

## fct_tracking_events

One row per shipment tracking event.

---

# Slowly Changing Dimensions

The project implements Slowly Changing Dimension Type 2 where historical business changes are important.

Implemented for:

- Customers
- Carriers

This preserves historical accuracy for reporting.

---

# Gold Layer Philosophy

Gold marts are purpose-built analytical datasets.

Each mart answers a specific business problem rather than serving as a generic reporting table.

Business logic is centralized in Gold to ensure:

- Consistent KPI definitions
- Governed metrics
- Reliable dashboard reporting

---

# Business Problems Addressed

The data model supports analysis of:

- Carrier SLA performance
- Warehouse bottlenecks
- Regional delivery performance
- Seller logistics performance
- Shipping cost analysis
- Financial impact of delivery failures
- Reverse logistics (future extension)

---

# Design Benefits

The final warehouse design provides:

- High query performance
- Clear separation of concerns
- Reusable business dimensions
- Scalable analytical architecture
- Easy Power BI integration
- Enterprise-style analytics engineering workflow