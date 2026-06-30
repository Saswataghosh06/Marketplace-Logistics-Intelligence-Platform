# DATA_DICTIONARY.md

# Marketplace Logistics Intelligence Platform

## Enterprise Data Dictionary

---

# Purpose

This document defines the business meaning, ownership, and analytical purpose of every dataset in the Marketplace Logistics Intelligence Platform.

The data dictionary serves as the central metadata reference for analysts, analytics engineers, business stakeholders, and dashboard developers.

Rather than documenting every technical column, this document focuses on business critical attributes that drive reporting, KPI calculations, and operational decision making.

---

# Warehouse Overview

The warehouse follows a Medallion Architecture.

| Layer  | Purpose                                 |
| ------ | --------------------------------------- |
| Bronze | Raw operational source data             |
| Silver | Standardized dimensions and fact tables |
| Gold   | Business ready analytical marts         |

---

# Bronze Layer

The Bronze layer preserves raw operational data exactly as generated.

No business transformations are performed.

## Bronze Tables

| Table           | Business Description            |
| --------------- | ------------------------------- |
| orders          | Raw customer order transactions |
| order_items     | Raw purchased products          |
| shipments       | Raw shipment lifecycle          |
| tracking_events | Raw shipment tracking history   |
| customers_scd   | Customer master history         |
| carriers_scd    | Carrier master history          |
| sellers         | Seller master data              |
| warehouses      | Warehouse master data           |
| products        | Product catalog                 |
| date_dimension  | Calendar dimension              |

---

# Silver Layer

The Silver layer contains standardized business entities used throughout the warehouse.

---

# Dimension Tables

---

# dim_customers

## Business Purpose

Stores customer master information while preserving historical profile changes through Slowly Changing Dimension Type 2.

## Grain

One row per customer version.

## Primary Key

customer_sk

## Business Owner

Customer Operations

## Source

customers_scd

## Important Fields

| Column           | Business Meaning                            |
| ---------------- | ------------------------------------------- |
| customer_sk      | Surrogate key used for historical reporting |
| customer_id      | Stable business identifier                  |
| customer_name    | Customer full name                          |
| city             | Customer city                               |
| state            | Customer state                              |
| country          | Customer country                            |
| customer_region  | Geographic reporting region                 |
| customer_segment | Customer business segment                   |
| signup_date      | Original registration date                  |
| effective_from   | Record effective start                      |
| effective_to     | Record effective end                        |
| is_current       | Indicates latest customer version           |

---

# dim_carriers

## Business Purpose

Stores logistics carrier information and historical SLA configurations.

## Grain

One row per carrier version.

## Primary Key

carrier_sk

## Source

carriers_scd

## Important Fields

| Column         | Business Meaning             |
| -------------- | ---------------------------- |
| carrier_sk     | Historical surrogate key     |
| carrier_id     | Business carrier identifier  |
| carrier_name   | Logistics provider           |
| carrier_tier   | Service level classification |
| service_type   | Delivery service type        |
| sla_target_pct | Target SLA percentage        |
| effective_from | Version start                |
| effective_to   | Version end                  |
| is_current     | Current carrier record       |

---

# dim_products

## Business Purpose

Stores descriptive information about marketplace products.

## Grain

One row per product.

## Primary Key

product_id

## Important Fields

| Column       | Business Meaning      |
| ------------ | --------------------- |
| product_id   | Product identifier    |
| product_name | Product name          |
| category     | Product category      |
| brand        | Manufacturer or brand |
| unit_cost    | Procurement cost      |

---

# dim_sellers

## Business Purpose

Stores seller profile information for marketplace performance reporting.

## Grain

One row per seller.

## Primary Key

seller_id

## Important Fields

| Column          | Business Meaning          |
| --------------- | ------------------------- |
| seller_id       | Seller identifier         |
| seller_name     | Seller name               |
| seller_tier     | Marketplace tier          |
| seller_region   | Seller operating region   |
| seller_category | Primary business category |
| rating_score    | Marketplace rating        |

---

# dim_warehouses

## Business Purpose

Stores warehouse attributes used for logistics performance reporting.

## Grain

One row per warehouse.

## Primary Key

warehouse_id

## Important Fields

| Column           | Business Meaning                  |
| ---------------- | --------------------------------- |
| warehouse_id     | Warehouse identifier              |
| warehouse_name   | Warehouse name                    |
| warehouse_type   | Fulfillment center classification |
| city             | Warehouse city                    |
| state            | Warehouse state                   |
| region           | Geographic region                 |
| capacity_units   | Maximum storage capacity          |
| warehouse_rating | Operational rating                |

---

# dim_date

## Business Purpose

Provides a reusable calendar dimension for time based analysis.

## Grain

One row per calendar day.

## Primary Key

date_key

## Important Fields

| Column       | Business Meaning       |
| ------------ | ---------------------- |
| date_key     | Surrogate calendar key |
| full_date    | Calendar date          |
| year         | Reporting year         |
| quarter      | Calendar quarter       |
| month        | Calendar month         |
| month_name   | Month description      |
| week_of_year | ISO reporting week     |

---

# Fact Tables

---

# fct_orders

## Business Purpose

Captures every customer order placed on the marketplace.

## Grain

One row per order.

## Primary Key

order_id

## Measures

* Order Amount
* Shipping Fee
* Discount Amount
* Net Amount

## Dimensions

* Customer
* Date

## Important Fields

| Column          | Business Meaning             |
| --------------- | ---------------------------- |
| order_id        | Order identifier             |
| customer_sk     | Customer surrogate key       |
| customer_id     | Business customer identifier |
| order_date      | Order creation date          |
| order_status    | Current order status         |
| payment_method  | Customer payment method      |
| currency_code   | Transaction currency         |
| order_amount    | Gross order value            |
| shipping_fee    | Shipping charge              |
| discount_amount | Promotional discount         |
| net_amount      | Final amount paid            |

---

# fct_order_items

## Business Purpose

Captures each individual product purchased within an order.

## Grain

One row per purchased product.

## Primary Key

order_item_id

## Measures

* Quantity
* Unit Price
* Revenue

## Dimensions

* Product
* Seller
* Order

## Important Fields

| Column        | Business Meaning      |
| ------------- | --------------------- |
| order_item_id | Order line identifier |
| order_id      | Parent order          |
| seller_id     | Selling merchant      |
| product_id    | Purchased product     |
| quantity      | Units sold            |
| unit_cost     | Procurement cost      |
| unit_price    | Selling price         |
| line_amount   | Revenue generated     |

---

# fct_shipments

## Business Purpose

Captures the complete shipment lifecycle from dispatch through delivery.

## Grain

One row per shipment.

## Primary Key

shipment_id

## Measures

* Shipping Cost
* Shipment Weight
* Transit Days
* Delay Days
* SLA Breach

## Dimensions

* Carrier
* Warehouse
* Customer Region
* Order

## Important Fields

| Column                 | Business Meaning          |
| ---------------------- | ------------------------- |
| shipment_id            | Shipment identifier       |
| order_id               | Parent order              |
| warehouse_id           | Dispatch warehouse        |
| carrier_id             | Logistics carrier         |
| customer_region        | Delivery region           |
| dispatch_date          | Shipment dispatch date    |
| promised_delivery_date | SLA commitment date       |
| actual_delivery_date   | Actual delivery date      |
| shipment_status        | Shipment lifecycle status |
| shipment_weight_kg     | Shipment weight           |
| shipping_cost          | Shipment cost             |
| actual_transit_days    | Actual transit duration   |
| delay_days             | Delivery delay            |
| is_sla_breached        | SLA breach indicator      |

---

# fct_tracking_events

## Business Purpose

Stores operational shipment tracking events throughout the delivery lifecycle.

## Grain

One row per shipment tracking event.

## Primary Key

tracking_event_id

## Business Event

Shipment status update.

## Important Fields

| Column            | Business Meaning              |
| ----------------- | ----------------------------- |
| tracking_event_id | Tracking event identifier     |
| shipment_id       | Shipment reference            |
| order_id          | Related order                 |
| carrier_id        | Logistics carrier             |
| event_timestamp   | Event occurrence time         |
| event_date        | Event calendar date           |
| event_hour        | Event hour                    |
| event_name        | Tracking event description    |
| event_status      | Event execution status        |
| event_location    | Tracking location             |
| is_exception      | Exception indicator           |
| is_delivery_event | Delivery completion indicator |

---

# Gold Layer

The Gold layer contains curated business marts designed for reporting and executive dashboards.

| Mart                       | Business Purpose                   |
| -------------------------- | ---------------------------------- |
| mart_logistics_overview    | Enterprise logistics KPI reporting |
| mart_carrier_performance   | Carrier performance benchmarking   |
| mart_warehouse_performance | Warehouse operational analysis     |
| mart_region_performance    | Regional delivery analysis         |
| mart_seller_performance    | Seller logistics performance       |
| mart_financial_impact      | Executive logistics cost analysis  |

---

# Data Governance

The data dictionary supports consistent business definitions across the warehouse.

Key governance principles include:

* Single source of truth for business entities
* Historical accuracy through Slowly Changing Dimensions
* Consistent KPI definitions
* Business friendly naming conventions
* Traceability from Gold marts back to operational events

---

# Summary

The Marketplace Logistics Intelligence Platform organizes operational logistics data into well defined business entities and measurable events.

This data dictionary provides a shared business vocabulary that ensures analysts, engineers, and business stakeholders interpret the warehouse consistently while supporting reliable reporting and decision making.
