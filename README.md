# Homelab Infrastructure Analytics

SQL-based analytics project built on real infrastructure data from a production-style homelab. Demonstrates database design, SQL querying, KPI tracking, trend analysis, and data-driven reporting — the same skills used in business intelligence roles.

## What This Project Demonstrates

- **Database Design:** Relational schema with normalized tables for services, metrics, incidents, and network traffic
- **SQL Fundamentals:** JOINs, aggregations, window functions, CTEs, subqueries, date-based filtering
- **KPI Definition:** Uptime percentage, mean time to resolution, resource utilization trends, traffic volume
- **Trend Analysis:** Time-series queries showing performance over days, weeks, and months
- **Data Quality:** Validation queries that cross-reference metrics against expected baselines
- **Reporting:** Summary queries designed to feed dashboards or stakeholder reports

## Schema

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│    services      │     │  service_metrics  │     │    incidents     │
├─────────────────┤     ├──────────────────┤     ├─────────────────┤
│ id              │◄────│ service_id       │     │ id              │
│ name            │     │ timestamp        │     │ service_id      │◄──┐
│ category        │     │ cpu_percent      │     │ started_at      │   │
│ port            │     │ memory_mb        │     │ resolved_at     │   │
│ vlan            │     │ status           │     │ severity        │   │
│ host            │     │ response_time_ms │     │ root_cause      │   │
│ created_at      │     └──────────────────┘     │ resolution      │   │
└─────────────────┘                              └─────────────────┘   │
                                                                       │
┌─────────────────┐     ┌──────────────────┐                          │
│     vlans        │     │ network_traffic  │                          │
├─────────────────┤     ├──────────────────┤                          │
│ id              │     │ id               │                          │
│ vlan_id         │     │ vlan_id          │                          │
│ name            │     │ timestamp        │                          │
│ subnet          │     │ bytes_in         │                          │
│ gateway         │     │ bytes_out        │                          │
│ purpose         │     │ packets_in       │                          │
│ firewall_policy │     │ packets_out      │                          │
└─────────────────┘     └──────────────────┘                          │
                                                                       │
┌─────────────────┐                                                    │
│  disk_metrics    │                                                   │
├─────────────────┤                                                   │
│ id              │                                                   │
│ mount_point     │                                                   │
│ total_gb        │                                                   │
│ used_gb         │                                                   │
│ timestamp       │                                                   │
└─────────────────┘
```

## Files

| File | Description |
|------|-------------|
| `schema.sql` | Database schema — all table definitions with constraints and indexes |
| `seed_data.sql` | Realistic sample data based on actual homelab infrastructure |
| `queries/kpi_dashboard.sql` | Core KPI queries — uptime, MTTR, resource utilization, traffic |
| `queries/trend_analysis.sql` | Time-series analysis — weekly trends, peak usage, growth patterns |
| `queries/incident_report.sql` | Incident management queries — severity breakdown, resolution times, root cause analysis |
| `queries/capacity_planning.sql` | Storage and resource forecasting queries |
| `queries/network_analysis.sql` | Per-VLAN traffic analysis, bandwidth utilization, anomaly detection |

## How to Run

Works with SQLite (no server needed), PostgreSQL, or MySQL.

```bash
# SQLite (simplest)
sqlite3 homelab.db < schema.sql
sqlite3 homelab.db < seed_data.sql
sqlite3 homelab.db < queries/kpi_dashboard.sql

# PostgreSQL
psql -d homelab -f schema.sql
psql -d homelab -f seed_data.sql
psql -d homelab -f queries/kpi_dashboard.sql
```

## Environment

Data modeled from a real homelab running:
- **Proxmox VE 9.1.7** with 2 VMs (Ubuntu Server + OPNsense)
- **15 Docker containers** across monitoring, services, and management
- **4 active VLANs** with per-VLAN firewall policies
- **Full observability stack** — Prometheus, Grafana, Loki, Uptime Kuma

## About

Built by [Gavin White](https://gavinwhite.dev) — CompTIA Security+ certified, studying for CCNA.
