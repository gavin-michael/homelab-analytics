-- =============================================================================
-- Network Analysis Queries
-- Per-VLAN traffic patterns, bandwidth utilization, anomaly detection
-- =============================================================================

-- 1. Traffic Distribution by VLAN (percentage of total)
WITH totals AS (
    SELECT
        vlan_id,
        SUM(bytes_in + bytes_out) AS vlan_total
    FROM network_traffic
    GROUP BY vlan_id
)
SELECT
    v.name AS vlan_name,
    v.subnet,
    v.firewall_policy,
    ROUND(t.vlan_total / 1073741824.0, 2) AS total_gb,
    ROUND(
        100.0 * t.vlan_total / SUM(t.vlan_total) OVER (),
        1
    ) AS pct_of_total_traffic
FROM totals t
JOIN vlans v ON t.vlan_id = v.vlan_id
ORDER BY total_gb DESC;


-- 2. Hourly Traffic Pattern by VLAN (average)
SELECT
    CAST(strftime('%H', nt.timestamp) AS INTEGER) AS hour_of_day,
    v.name AS vlan_name,
    ROUND(AVG(nt.bytes_in + nt.bytes_out) / 1048576.0, 1) AS avg_mb_per_hour,
    ROUND(MAX(nt.bytes_in + nt.bytes_out) / 1048576.0, 1) AS peak_mb_per_hour
FROM network_traffic nt
JOIN vlans v ON nt.vlan_id = v.vlan_id
WHERE v.name = 'Trusted'
GROUP BY hour_of_day, v.name
ORDER BY hour_of_day;


-- 3. Ingress vs Egress Ratio (identifies upload-heavy or download-heavy VLANs)
SELECT
    v.name AS vlan_name,
    ROUND(SUM(nt.bytes_in) / 1073741824.0, 2) AS ingress_gb,
    ROUND(SUM(nt.bytes_out) / 1073741824.0, 2) AS egress_gb,
    ROUND(1.0 * SUM(nt.bytes_in) / NULLIF(SUM(nt.bytes_out), 0), 2) AS ingress_egress_ratio,
    CASE
        WHEN SUM(nt.bytes_in) > SUM(nt.bytes_out) * 1.5 THEN 'Download Heavy'
        WHEN SUM(nt.bytes_out) > SUM(nt.bytes_in) * 1.5 THEN 'Upload Heavy'
        ELSE 'Balanced'
    END AS traffic_pattern
FROM network_traffic nt
JOIN vlans v ON nt.vlan_id = v.vlan_id
GROUP BY v.vlan_id, v.name
ORDER BY ingress_gb DESC;


-- 4. Anomaly Detection — Hours with traffic > 2x the daily average
WITH hourly_avg AS (
    SELECT
        vlan_id,
        AVG(bytes_in + bytes_out) AS avg_bytes
    FROM network_traffic
    GROUP BY vlan_id
)
SELECT
    v.name AS vlan_name,
    nt.timestamp,
    ROUND((nt.bytes_in + nt.bytes_out) / 1048576.0, 1) AS traffic_mb,
    ROUND(ha.avg_bytes / 1048576.0, 1) AS avg_mb,
    ROUND(1.0 * (nt.bytes_in + nt.bytes_out) / ha.avg_bytes, 1) AS times_above_avg
FROM network_traffic nt
JOIN hourly_avg ha ON nt.vlan_id = ha.vlan_id
JOIN vlans v ON nt.vlan_id = v.vlan_id
WHERE (nt.bytes_in + nt.bytes_out) > ha.avg_bytes * 2
ORDER BY times_above_avg DESC
LIMIT 20;


-- 5. Packets-per-Byte Ratio (identifies protocol anomalies)
-- High packets/byte = lots of small packets (DNS, scanning)
-- Low packets/byte = large transfers (streaming, backups)
SELECT
    v.name AS vlan_name,
    date(nt.timestamp) AS day,
    SUM(nt.packets_in + nt.packets_out) AS total_packets,
    ROUND(SUM(nt.bytes_in + nt.bytes_out) / 1048576.0, 1) AS total_mb,
    ROUND(
        1.0 * SUM(nt.packets_in + nt.packets_out) /
        NULLIF(SUM(nt.bytes_in + nt.bytes_out) / 1024.0, 0),
        2
    ) AS packets_per_kb
FROM network_traffic nt
JOIN vlans v ON nt.vlan_id = v.vlan_id
GROUP BY v.name, date(nt.timestamp)
ORDER BY v.name, day;
