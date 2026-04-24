-- =============================================================================
-- Incident Report Queries
-- Severity analysis, MTTR tracking, root cause patterns
-- =============================================================================

-- 1. Full Incident Timeline
SELECT
    i.id,
    COALESCE(s.name, 'Infrastructure') AS affected_service,
    i.severity,
    i.started_at,
    i.resolved_at,
    ROUND(
        (julianday(i.resolved_at) - julianday(i.started_at)) * 24 * 60,
        0
    ) AS resolution_minutes,
    i.root_cause,
    i.resolution
FROM incidents i
LEFT JOIN services s ON i.service_id = s.id
ORDER BY i.started_at DESC;


-- 2. Incident Severity Distribution
SELECT
    severity,
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM incidents), 1) AS pct_of_total,
    ROUND(AVG(
        (julianday(resolved_at) - julianday(started_at)) * 24 * 60
    ), 0) AS avg_resolution_min
FROM incidents
GROUP BY severity
ORDER BY
    CASE severity
        WHEN 'critical' THEN 1
        WHEN 'major' THEN 2
        WHEN 'minor' THEN 3
    END;


-- 3. Services with Most Incidents
SELECT
    COALESCE(s.name, 'Infrastructure') AS service,
    COUNT(*) AS incident_count,
    SUM(CASE WHEN i.severity = 'critical' THEN 1 ELSE 0 END) AS critical,
    SUM(CASE WHEN i.severity = 'major' THEN 1 ELSE 0 END) AS major,
    SUM(CASE WHEN i.severity = 'minor' THEN 1 ELSE 0 END) AS minor
FROM incidents i
LEFT JOIN services s ON i.service_id = s.id
GROUP BY COALESCE(s.name, 'Infrastructure')
ORDER BY incident_count DESC;


-- 4. Longest Outages
SELECT
    COALESCE(s.name, 'Infrastructure') AS service,
    i.severity,
    i.started_at,
    ROUND(
        (julianday(i.resolved_at) - julianday(i.started_at)) * 24 * 60,
        0
    ) AS duration_minutes,
    i.root_cause,
    i.impact
FROM incidents i
LEFT JOIN services s ON i.service_id = s.id
WHERE i.resolved_at IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 5;


-- 5. Incidents per Week (trend)
SELECT
    date(started_at, 'weekday 0', '-6 days') AS week_starting,
    COUNT(*) AS incidents,
    SUM(CASE WHEN severity = 'critical' THEN 1 ELSE 0 END) AS critical,
    SUM(CASE WHEN severity = 'major' THEN 1 ELSE 0 END) AS major,
    SUM(CASE WHEN severity = 'minor' THEN 1 ELSE 0 END) AS minor
FROM incidents
GROUP BY week_starting
ORDER BY week_starting;
