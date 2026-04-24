-- =============================================================================
-- KPI Dashboard Queries
-- Core metrics for infrastructure health reporting
-- =============================================================================

-- 1. Overall Service Uptime (last 7 days)
-- Calculates uptime percentage per service based on hourly health checks
SELECT
    s.name AS service,
    s.category,
    COUNT(*) AS total_checks,
    SUM(CASE WHEN sm.status = 'up' THEN 1 ELSE 0 END) AS checks_up,
    ROUND(
        100.0 * SUM(CASE WHEN sm.status = 'up' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS uptime_pct
FROM services s
JOIN service_metrics sm ON s.id = sm.service_id
WHERE sm.timestamp >= datetime('now', '-7 days')
GROUP BY s.id, s.name, s.category
ORDER BY uptime_pct ASC;


-- 2. Average Resource Usage by Service (last 24 hours)
SELECT
    s.name AS service,
    ROUND(AVG(sm.cpu_percent), 1) AS avg_cpu_pct,
    ROUND(MAX(sm.cpu_percent), 1) AS peak_cpu_pct,
    ROUND(AVG(sm.memory_mb), 0) AS avg_memory_mb,
    ROUND(MAX(sm.memory_mb), 0) AS peak_memory_mb,
    ROUND(AVG(sm.response_time_ms), 0) AS avg_response_ms
FROM services s
JOIN service_metrics sm ON s.id = sm.service_id
WHERE sm.timestamp >= datetime('now', '-24 hours')
GROUP BY s.id, s.name
ORDER BY avg_cpu_pct DESC;


-- 3. Total Memory Allocation Across All Services
SELECT
    s.category,
    COUNT(DISTINCT s.id) AS service_count,
    ROUND(SUM(sm.memory_mb) / COUNT(DISTINCT sm.timestamp), 0) AS avg_total_memory_mb,
    ROUND(SUM(sm.memory_mb) / COUNT(DISTINCT sm.timestamp) / 16384 * 100, 1) AS pct_of_16gb
FROM services s
JOIN service_metrics sm ON s.id = sm.service_id
WHERE sm.timestamp = (
    SELECT MAX(timestamp) FROM service_metrics
)
GROUP BY s.category
ORDER BY avg_total_memory_mb DESC;


-- 4. Mean Time to Resolution (MTTR) by Severity
SELECT
    severity,
    COUNT(*) AS incident_count,
    ROUND(AVG(
        (julianday(resolved_at) - julianday(started_at)) * 24 * 60
    ), 0) AS avg_mttr_minutes,
    ROUND(MIN(
        (julianday(resolved_at) - julianday(started_at)) * 24 * 60
    ), 0) AS fastest_resolution_min,
    ROUND(MAX(
        (julianday(resolved_at) - julianday(started_at)) * 24 * 60
    ), 0) AS slowest_resolution_min
FROM incidents
WHERE resolved_at IS NOT NULL
GROUP BY severity
ORDER BY
    CASE severity
        WHEN 'critical' THEN 1
        WHEN 'major' THEN 2
        WHEN 'minor' THEN 3
    END;


-- 5. Network Traffic Summary by VLAN (last 24 hours)
SELECT
    v.name AS vlan_name,
    v.subnet,
    ROUND(SUM(nt.bytes_in) / 1073741824.0, 2) AS total_ingress_gb,
    ROUND(SUM(nt.bytes_out) / 1073741824.0, 2) AS total_egress_gb,
    ROUND(SUM(nt.bytes_in + nt.bytes_out) / 1073741824.0, 2) AS total_traffic_gb,
    SUM(nt.packets_in + nt.packets_out) AS total_packets
FROM vlans v
JOIN network_traffic nt ON v.vlan_id = nt.vlan_id
WHERE nt.timestamp >= datetime('now', '-24 hours')
GROUP BY v.vlan_id, v.name, v.subnet
ORDER BY total_traffic_gb DESC;
