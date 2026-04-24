-- =============================================================================
-- Homelab Infrastructure Analytics — Database Schema
-- Compatible with SQLite, PostgreSQL, and MySQL
-- =============================================================================

-- Services running in the homelab
CREATE TABLE services (
    id              INTEGER PRIMARY KEY,
    name            TEXT NOT NULL,
    category        TEXT NOT NULL,  -- 'monitoring', 'services', 'infrastructure'
    port            INTEGER,
    vlan            INTEGER NOT NULL,
    host            TEXT NOT NULL DEFAULT '10.0.20.20',
    image           TEXT,
    created_at      TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Time-series service health metrics (sampled hourly)
CREATE TABLE service_metrics (
    id              INTEGER PRIMARY KEY,
    service_id      INTEGER NOT NULL REFERENCES services(id),
    timestamp       TEXT NOT NULL,
    cpu_percent     REAL,
    memory_mb       REAL,
    status          TEXT NOT NULL DEFAULT 'up',  -- 'up', 'down', 'degraded'
    response_time_ms INTEGER
);

CREATE INDEX idx_svc_metrics_ts ON service_metrics(timestamp);
CREATE INDEX idx_svc_metrics_svc ON service_metrics(service_id);

-- VLAN configuration
CREATE TABLE vlans (
    id              INTEGER PRIMARY KEY,
    vlan_id         INTEGER NOT NULL UNIQUE,
    name            TEXT NOT NULL,
    subnet          TEXT NOT NULL,
    gateway         TEXT,
    purpose         TEXT,
    firewall_policy TEXT  -- 'full_access', 'lab_access', 'internet_only'
);

-- Network traffic per VLAN (sampled hourly)
CREATE TABLE network_traffic (
    id              INTEGER PRIMARY KEY,
    vlan_id         INTEGER NOT NULL,
    timestamp       TEXT NOT NULL,
    bytes_in        INTEGER NOT NULL DEFAULT 0,
    bytes_out       INTEGER NOT NULL DEFAULT 0,
    packets_in      INTEGER NOT NULL DEFAULT 0,
    packets_out     INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_traffic_ts ON network_traffic(timestamp);
CREATE INDEX idx_traffic_vlan ON network_traffic(vlan_id);

-- Incident log
CREATE TABLE incidents (
    id              INTEGER PRIMARY KEY,
    service_id      INTEGER REFERENCES services(id),
    started_at      TEXT NOT NULL,
    resolved_at     TEXT,
    severity        TEXT NOT NULL,  -- 'critical', 'major', 'minor'
    root_cause      TEXT,
    resolution      TEXT,
    impact          TEXT
);

CREATE INDEX idx_incidents_svc ON incidents(service_id);
CREATE INDEX idx_incidents_ts ON incidents(started_at);

-- Disk usage metrics (sampled daily)
CREATE TABLE disk_metrics (
    id              INTEGER PRIMARY KEY,
    mount_point     TEXT NOT NULL,
    disk_type       TEXT NOT NULL,  -- 'nvme', 'hdd'
    total_gb        REAL NOT NULL,
    used_gb         REAL NOT NULL,
    timestamp       TEXT NOT NULL
);

CREATE INDEX idx_disk_ts ON disk_metrics(timestamp);
