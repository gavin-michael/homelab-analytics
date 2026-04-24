-- =============================================================================
-- Trend Analysis Queries
-- Time-series patterns, weekly comparisons, peak usage identification
-- =============================================================================

-- 1. Hourly CPU Trend — Minecraft Server (peak gaming hours analysis)
SELECT
    CAST(strftime('%H', sm.timestamp) AS INTEGER) AS hour_of_day,
    ROUND(AVG(sm.cpu_percent), 1) AS avg_cpu,
    ROUND(MAX(sm.cpu_percent), 1) AS peak_cpu,
    ROUND(AVG(sm.memory_mb), 0) AS avg_memory_mb,
    COUNT(*) AS sample_count
FROM service_metrics sm
JOIN services s ON sm.service_id = s.id
WHERE s.name = 'minecraft'
GROUP BY hour_of_day
ORDER BY hour_of_day;


-- 2. Daily Traffic Volume by VLAN (7-day trend)
SELECT
    date(nt.timestamp) AS day,
    v.name AS vlan_name,
    ROUND(SUM(nt.bytes_in + nt.bytes_out) / 1073741824.0, 2) AS total_gb
FROM network_traffic nt
JOIN vlans v ON nt.vlan_id = v.vlan_id
GROUP BY date(nt.timestamp), v.name
ORDER BY day, total_gb DESC;


-- 3. Service Response Time Trend (daily average over 7 days)
SELECT
    date(sm.timestamp) AS day,
    s.name AS service,
    ROUND(AVG(sm.response_time_ms), 1) AS avg_response_ms,
    ROUND(MAX(sm.response_time_ms), 0) AS max_response_ms
FROM service_metrics sm
JOIN services s ON sm.service_id = s.id
WHERE s.name IN ('grafana', 'prometheus', 'pihole')
GROUP BY date(sm.timestamp), s.name
ORDER BY day, service;


-- 4. Peak Usage Hours — When is the infrastructure busiest?
SELECT
    CAST(strftime('%H', sm.timestamp) AS INTEGER) AS hour_of_day,
    ROUND(AVG(sm.cpu_percent), 1) AS avg_cpu_all_services,
    ROUND(SUM(sm.memory_mb) / COUNT(DISTINCT sm.timestamp), 0) AS avg_total_memory_mb,
    CASE
        WHEN CAST(strftime('%H', sm.timestamp) AS INTEGER) BETWEEN 9 AND 17 THEN 'Business Hours'
        WHEN CAST(strftime('%H', sm.timestamp) AS INTEGER) BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Off Hours'
    END AS time_period
FROM service_metrics sm
GROUP BY hour_of_day
ORDER BY avg_cpu_all_services DESC
LIMIT 10;


-- 5. Week-over-Week Comparison — Is traffic growing?
WITH weekly AS (
    SELECT
        CAST(strftime('%W', timestamp) AS INTEGER) AS week_num,
        vlan_id,
        SUM(bytes_in + bytes_out) AS total_bytes
    FROM network_traffic
    GROUP BY week_num, vlan_id
)
SELECT
    w1.week_num AS current_week,
    v.name AS vlan_name,
    ROUND(w1.total_bytes / 1073741824.0, 2) AS current_gb,
    ROUND(w2.total_bytes / 1073741824.0, 2) AS previous_gb,
    ROUND(
        100.0 * (w1.total_bytes - w2.total_bytes) / NULLIF(w2.total_bytes, 0),
        1
    ) AS growth_pct
FROM weekly w1
JOIN weekly w2 ON w1.vlan_id = w2.vlan_id AND w1.week_num = w2.week_num + 1
JOIN vlans v ON w1.vlan_id = v.vlan_id
ORDER BY w1.week_num, vlan_name;
