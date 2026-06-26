# GOLD_LAYER_BUSINESS_MARTS

## Project

Marketplace Logistics Intelligence Platform

---

# Purpose

The Gold layer contains business-ready marts designed for reporting, KPI monitoring, and root cause analysis.

Unlike the Silver layer, Gold models represent trusted business metrics that can be consumed directly by BI tools such as Power BI.

Each mart answers a specific business problem identified by logistics leadership.

---

# Gold Mart Overview

| Gold Mart | Business Objective |
|------------|--------------------|
| mart_logistics_overview | Executive logistics KPI dashboard |
| mart_carrier_performance | Evaluate carrier SLA performance |
| mart_warehouse_performance | Identify warehouse bottlenecks |
| mart_region_performance | Analyze regional delivery performance |
| mart_seller_performance | Measure seller logistics performance |
| mart_financial_impact | Quantify financial impact of logistics operations |

---

# 1. mart_logistics_overview

## Business Question

How is the logistics network performing overall?

## Primary Users

• Operations Leadership

• Supply Chain Managers

• Executive Dashboard

## Key KPIs

• Total Orders

• Total Shipments

• Delivered Shipments

• SLA Breach %

• Average Transit Days

• Shipping Cost

• Delivery Trend

---

# 2. mart_carrier_performance

## Business Question

Which carriers contribute most to SLA breaches?

## Primary Users

• Logistics Operations

• Carrier Management Team

## Key KPIs

• Total Shipments

• Delivered Shipments

• SLA Breach %

• Average Transit Days

• Average Delay

• Shipping Cost

• Cost per Kilogram

---

# 3. mart_warehouse_performance

## Business Question

Which warehouses are creating dispatch bottlenecks?

## Primary Users

• Warehouse Operations

• Supply Chain Managers

## Key KPIs

• Total Shipments

• Delivered Shipments

• SLA Breach %

• Average Transit Days

• Average Delay

• Shipping Cost

• Shipping Cost per Kilogram

Warehouse descriptive attributes are included to support operational reporting:

• Warehouse Name

• Warehouse Type

• City

• State

• Region

• Capacity

• Warehouse Rating

---

# 4. mart_region_performance

## Business Question

Which customer regions experience the highest delivery delays?

## Primary Users

• Regional Operations

• Logistics Planning

## Key KPIs

• Total Shipments

• Delivered Shipments

• SLA Breach %

• Average Transit Days

• Average Delay

• Shipping Cost

• Shipping Cost per Kilogram

---

# 5. mart_seller_performance

## Business Question

Which sellers are most impacted by logistics performance?

## Primary Users

• Marketplace Operations

• Seller Success Team

## Key KPIs

Business

• Total Revenue

• Total Quantity Sold

• Average Order Item Value

Logistics

• Total Shipments

• Delivered Shipments

• SLA Breach %

• Average Transit Days

• Average Delay

• Shipping Cost

Seller profile attributes are included for business segmentation:

• Seller Tier

• Seller Region

• Seller Category

• Rating Score

---

# 6. mart_financial_impact

## Business Question

What is the financial impact of logistics performance?

## Primary Users

• Finance

• Operations Leadership

## Key KPIs

• Total Shipping Cost

• Breached Shipping Cost

• On Time Shipping Cost

• Breached Cost %

• Average Shipping Cost

• Average Breached Shipping Cost

• Average Transit Days

• Average Delay

---

# Gold Layer Design Principles

Every Gold mart follows the same design philosophy:

• Business oriented

• One business problem per mart

• Aggregated metrics

• Trusted KPI definitions

• Optimized for reporting

• Consistent naming conventions

• Documented business logic

• Directly consumable by Power BI

---

# Relationship to Silver Layer

Silver models retain operational detail and known data quality anomalies.

Gold marts aggregate validated business metrics while excluding records that would distort executive reporting when appropriate.

This separation preserves data lineage while ensuring reliable analytics.