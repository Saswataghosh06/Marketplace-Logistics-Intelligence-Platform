# POWER_BI_DASHBOARD_GUIDE

# Marketplace Logistics Intelligence Platform

Power BI Dashboard Implementation Guide

---

# Objective

Build an executive analytics dashboard that answers the business questions defined in the project charter.

The dashboard is designed for Operations Managers, Supply Chain Managers, Logistics Heads, and Business Leadership.

Each page maps directly to one Gold mart.

---

# Dashboard Pages

| Page | Gold Mart | Status |
|---------|---------|---------|
| Executive Overview | mart_logistics_overview | Pending |
| Carrier Performance | mart_carrier_performance | Pending |
| Warehouse Performance | mart_warehouse_performance | Pending |
| Regional Performance | mart_region_performance | Pending |
| Seller Performance | mart_seller_performance | Pending |
| Financial Impact | mart_financial_impact | Pending |

---

# Global Filters

Available on every page

• Date
• Region
• Carrier Tier
• Warehouse
• Seller Tier

---

# Theme

Style

Clean Corporate Dashboard

Colors

Blue
Green
Orange
Red

Background

White

Font

Segoe UI

---

# Navigation

Every page contains

Home Button

Previous Page

Next Page

Dashboard Title

Last Refresh Date

---

# Executive Overview

Business Question

What is the overall health of logistics operations?

KPIs

Total Shipments

Delivered Shipments

On Time Shipments

SLA Breached Shipments

Overall SLA %

Average Transit Days

Average Delay

Total Shipping Cost

Charts

Shipment Status Distribution

SLA Trend

Delivery Trend

Shipping Cost Trend

Top KPI Cards

Filters

Date

Region

Carrier

---

# Carrier Performance

Business Questions

Which carrier contributes most to SLA breaches?

Which carrier has the worst delivery performance?

Which carrier costs the most?

KPIs

Total Shipments

Delivered

SLA %

Average Delay

Average Transit

Shipping Cost

Charts

Carrier Ranking

SLA %

Average Delay

Shipping Cost

Shipment Volume

Visuals

Bar Chart

Column Chart

Matrix

---

# Warehouse Performance

Business Questions

Which warehouses create operational bottlenecks?

Which warehouses dispatch efficiently?

KPIs

Total Shipments

SLA %

Average Transit

Average Delay

Shipping Cost

Charts

Warehouse Ranking

Top SLA Breaches

Shipping Cost

Warehouse Rating Comparison

Visuals

Bar Chart

Scatter Plot

Matrix

---

# Regional Performance

Business Questions

Which regions experience the highest delays?

Which regions contribute most to SLA breaches?

KPIs

Total Shipments

Average Delay

Average Transit

Shipping Cost

SLA %

Charts

Filled Map

Regional Ranking

Delay Comparison

Shipping Cost Comparison

Visuals

Map

Bar Chart

Column Chart

---

# Seller Performance

Business Questions

Which sellers generate the highest logistics workload?

Which sellers suffer the highest SLA breaches?

KPIs

Revenue

Order Items

Shipment Volume

Average Shipping Cost

SLA %

Charts

Revenue Ranking

Shipment Ranking

SLA Ranking

Seller Tier Comparison

Visuals

Bar Chart

Treemap

Matrix

---

# Financial Impact

Business Questions

What is the financial impact of logistics performance?

KPIs

Total Shipping Cost

Breached Shipping Cost

On Time Shipping Cost

Average Shipping Cost

Average Delay

Charts

Shipping Cost Breakdown

Breached vs On Time Cost

Cost Distribution

Visuals

Donut Chart

Stacked Column Chart

Cards

---

# Cross Filtering

Every visual should cross-filter other visuals on the page.

Example

Selecting Carrier X updates

SLA %

Average Delay

Shipping Cost

Shipment Volume

---

# Tooltips

Each chart should display

Value

Percentage

Rank

Average

Difference from overall average

---

# Drill Through

Carrier

View carrier details

Warehouse

View warehouse details

Seller

View seller details

Region

View regional details

---

# KPI Formatting

Percentages

Two decimal places

Currency

Indian Rupees

Thousands Separator

Enabled

Dates

dd-MMM-yyyy

---

# Performance Guidelines

Avoid unnecessary calculated columns.

Prefer measures.

Disable Auto Date Table.

Use Star Schema relationships only.

---

# Dashboard Goal

Enable leadership to quickly identify

• Poor performing carriers

• Warehouse bottlenecks

• Regional delivery issues

• Seller logistics performance

• Financial impact of delivery failures

through a clean, interactive executive dashboard.
