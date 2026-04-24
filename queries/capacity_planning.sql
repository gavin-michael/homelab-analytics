-- =============================================================================
-- Capacity Planning Queries
-- Storage forecasting, resource growth, headroom analysis
-- =============================================================================

-- 1. Current Disk Usage with Headroom
SELECT
    mount_point,
    disk_type,
    total_gb,
    used_gb,
    ROUND(total_gb - used_gb, 1) AS free_gb,
    ROUND(100.0 * used_gb / total_gb, 1) AS used_pct,
    CASE
        WHEN (100.0 * used_gb / total_gb) > 90 THEN 'CRITICAL'
        WHEN (100.0 * used_gb / total_gb) > 75 THEN 'WARNING'
        ELSE 'HEALTHY'
    END AS health_status
FROM disk_metrics
WHERE timestamp = (SELECT MAX(timestamp) FROM disk_metrics)
ORDER BY used_pct DESC;


-- 2. Daily Storage Growth Rate
WITH daily AS (
    SELECT
        mount_point,
        timestamp,
        used_gb,
        LAG(used_gb) OVER (PARTITION BY mount_point ORDER BY timestamp) AS prev_used_gb
    FROM disk_metrics
)
SELECT
    mount_point,
    ROUND(AVG(used_gb - prev_used_gb), 3) AS avg_daily_growth_gb,
    ROUND(MAX(used_gb - prev_used_gb), 3) AS max_daily_growth_gb
FROM daily
WHERE prev_used_gb IS NOT NULL
GROUP BY mount_point;


-- 3. Days Until Full (at current growth rate)
WITH growth AS (
    SELECT
        mount_point,
        disk_type,
        MAX(total_gb) AS total_gb,
        MAX(used_gb) AS current_used_gb,
        AVG(used_gb - LAG(used_gb) OVER (PARTITION BY mount_point ORDER BY timestamp)) AS daily_growth
    FROM disk_metrics
    GROUP BY mount_point, disk_type
)
SELECT
    mount_point,
    disk_type,
    total_gb,
    ROUND(current_used_gb, 1) AS used_gb,
    ROUND(total_gb - current_used_gb, 1) AS free_gb,
    ROUND(daily_growth, 3) AS daily_growth_gb,
    CASE
        WHEN daily_growth > 0 THEN ROUND((total_gb - current_used_gb) / daily_growth, 0)
        ELSE NULL
    END AS days_until_full
FROM growth;


-- 4. Memory Headroom per Service
SELECT
    s.name AS service,
    ROUND(AVG(sm.memory_mb), 0) AS avg_memory_mb,
    ROUND(MAX(sm.memory_mb), 0) AS peak_memory_mb,
    CASE s.name
        WHEN 'minecraft' THEN 8192
        WHEN 'prometheus' THEN 512
        WHEN 'grafana' THEN 512
        WHEN 'loki' THEN 512
        ELSE 256
    END AS allocated_mb,
    ROUND(100.0 * MAX(sm.memory_mb) / CASE s.name
        WHEN 'minecraft' THEN 8192
        WHEN 'prometheus' THEN 512
        WHEN 'grafana' THEN 512
        WHEN 'loki' THEN 512
        ELSE 256
    END, 1) AS peak_utilization_pct
FROM services s
JOIN service_metrics sm ON s.id = sm.service_id
GROUP BY s.id, s.name
ORDER BY peak_utilization_pct DESC;
