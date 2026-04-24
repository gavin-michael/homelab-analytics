-- =============================================================================
-- Homelab Infrastructure Analytics — Seed Data
-- Realistic data based on actual homelab infrastructure
-- =============================================================================

-- Services
INSERT INTO services (id, name, category, port, vlan, host, image) VALUES
(1,  'prometheus',          'monitoring',      9090,  20, '10.0.20.20', 'prom/prometheus'),
(2,  'grafana',             'monitoring',      3000,  20, '10.0.20.20', 'grafana/grafana'),
(3,  'loki',                'monitoring',      3100,  20, '10.0.20.20', 'grafana/loki'),
(4,  'alloy',               'monitoring',      12345, 20, '10.0.20.20', 'grafana/alloy'),
(5,  'node-exporter',       'monitoring',      9100,  20, '10.0.20.20', 'prom/node-exporter'),
(6,  'snmp-exporter',       'monitoring',      9116,  20, '10.0.20.20', 'prom/snmp-exporter'),
(7,  'uptime-kuma',         'monitoring',      3001,  20, '10.0.20.20', 'louislam/uptime-kuma'),
(8,  'pihole',              'services',        53,    20, '10.0.20.20', 'pihole/pihole'),
(9,  'nginx-proxy-manager', 'services',        81,    20, '10.0.20.20', 'jc21/nginx-proxy-manager'),
(10, 'cloudflared',         'services',        NULL,  20, '10.0.20.20', 'cloudflare/cloudflared'),
(11, 'portfolio',           'services',        8090,  20, '10.0.20.20', 'nginx:alpine'),
(12, 'homepage',            'services',        3002,  20, '10.0.20.20', 'ghcr.io/gethomepage'),
(13, 'minecraft',           'services',        25565, 20, '10.0.20.20', 'itzg/minecraft-server'),
(14, 'portainer',           'services',        9000,  20, '10.0.20.20', 'portainer/portainer-ce'),
(15, 'opnsense',            'infrastructure',  443,   10, '10.0.10.1',  NULL);

-- VLANs
INSERT INTO vlans (id, vlan_id, name, subnet, gateway, purpose, firewall_policy) VALUES
(1, 1,  'Switch Mgmt', '192.168.0.0/24', NULL,        'Switch management',    NULL),
(2, 10, 'Trusted',     '10.0.10.0/24',   '10.0.10.1', 'Personal devices',     'full_access'),
(3, 20, 'Lab',         '10.0.20.0/24',   '10.0.20.1', 'VMs and services',     'lab_access'),
(4, 30, 'IoT',         '10.0.30.0/24',   '10.0.30.1', 'Smart devices',        'internet_only'),
(5, 40, 'Guest',       '10.0.40.0/24',   '10.0.40.1', 'Visitors',             'internet_only');

-- Service Metrics — 7 days of hourly data for key services
-- Generating realistic patterns: lower usage at night, spikes during day

-- Helper: Generate 168 hours (7 days) of metrics for each service
-- Day 1-7, Hours 0-23

-- Prometheus metrics (steady, low resource usage)
INSERT INTO service_metrics (service_id, timestamp, cpu_percent, memory_mb, status, response_time_ms)
SELECT 1,
    datetime('2026-04-17', '+' || (d*24 + h) || ' hours'),
    ROUND(2.0 + ABS(RANDOM() % 30) / 10.0, 1),
    ROUND(280 + ABS(RANDOM() % 60), 0),
    'up',
    ROUND(5 + ABS(RANDOM() % 15), 0)
FROM (SELECT 0 AS d UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) days,
     (SELECT 0 AS h UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23) hours;

-- Grafana metrics (moderate, spikes during dashboard viewing)
INSERT INTO service_metrics (service_id, timestamp, cpu_percent, memory_mb, status, response_time_ms)
SELECT 2,
    datetime('2026-04-17', '+' || (d*24 + h) || ' hours'),
    CASE WHEN h BETWEEN 9 AND 22 THEN ROUND(5.0 + ABS(RANDOM() % 80) / 10.0, 1)
         ELSE ROUND(1.0 + ABS(RANDOM() % 20) / 10.0, 1) END,
    ROUND(180 + ABS(RANDOM() % 80), 0),
    'up',
    CASE WHEN h BETWEEN 9 AND 22 THEN ROUND(20 + ABS(RANDOM() % 60), 0)
         ELSE ROUND(8 + ABS(RANDOM() % 15), 0) END
FROM (SELECT 0 AS d UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) days,
     (SELECT 0 AS h UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23) hours;

-- Minecraft metrics (high memory, variable CPU)
INSERT INTO service_metrics (service_id, timestamp, cpu_percent, memory_mb, status, response_time_ms)
SELECT 13,
    datetime('2026-04-17', '+' || (d*24 + h) || ' hours'),
    CASE WHEN h BETWEEN 18 AND 23 THEN ROUND(15.0 + ABS(RANDOM() % 200) / 10.0, 1)
         ELSE ROUND(3.0 + ABS(RANDOM() % 40) / 10.0, 1) END,
    ROUND(6800 + ABS(RANDOM() % 1200), 0),
    'up',
    ROUND(1 + ABS(RANDOM() % 5), 0)
FROM (SELECT 0 AS d UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) days,
     (SELECT 0 AS h UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23) hours;

-- Pi-hole metrics (consistent, low resources)
INSERT INTO service_metrics (service_id, timestamp, cpu_percent, memory_mb, status, response_time_ms)
SELECT 8,
    datetime('2026-04-17', '+' || (d*24 + h) || ' hours'),
    ROUND(0.5 + ABS(RANDOM() % 20) / 10.0, 1),
    ROUND(85 + ABS(RANDOM() % 30), 0),
    'up',
    ROUND(1 + ABS(RANDOM() % 3), 0)
FROM (SELECT 0 AS d UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) days,
     (SELECT 0 AS h UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23) hours;

-- Network Traffic — hourly per VLAN
-- Trusted (VLAN 10) — highest traffic, personal devices
INSERT INTO network_traffic (vlan_id, timestamp, bytes_in, bytes_out, packets_in, packets_out)
SELECT 10,
    datetime('2026-04-17', '+' || (d*24 + h) || ' hours'),
    CASE WHEN h BETWEEN 9 AND 23 THEN 50000000 + ABS(RANDOM() % 150000000)
         ELSE 5000000 + ABS(RANDOM() % 20000000) END,
    CASE WHEN h BETWEEN 9 AND 23 THEN 30000000 + ABS(RANDOM() % 80000000)
         ELSE 2000000 + ABS(RANDOM() % 10000000) END,
    CASE WHEN h BETWEEN 9 AND 23 THEN 40000 + ABS(RANDOM() % 100000)
         ELSE 5000 + ABS(RANDOM() % 15000) END,
    CASE WHEN h BETWEEN 9 AND 23 THEN 25000 + ABS(RANDOM() % 60000)
         ELSE 3000 + ABS(RANDOM() % 8000) END
FROM (SELECT 0 AS d UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) days,
     (SELECT 0 AS h UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23) hours;

-- Lab (VLAN 20) — moderate, Docker + monitoring traffic
INSERT INTO network_traffic (vlan_id, timestamp, bytes_in, bytes_out, packets_in, packets_out)
SELECT 20,
    datetime('2026-04-17', '+' || (d*24 + h) || ' hours'),
    20000000 + ABS(RANDOM() % 60000000),
    15000000 + ABS(RANDOM() % 40000000),
    15000 + ABS(RANDOM() % 40000),
    10000 + ABS(RANDOM() % 25000)
FROM (SELECT 0 AS d UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) days,
     (SELECT 0 AS h UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23) hours;

-- IoT (VLAN 30) — low, isolated traffic
INSERT INTO network_traffic (vlan_id, timestamp, bytes_in, bytes_out, packets_in, packets_out)
SELECT 30,
    datetime('2026-04-17', '+' || (d*24 + h) || ' hours'),
    1000000 + ABS(RANDOM() % 5000000),
    500000 + ABS(RANDOM() % 2000000),
    1000 + ABS(RANDOM() % 4000),
    500 + ABS(RANDOM() % 2000)
FROM (SELECT 0 AS d UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) days,
     (SELECT 0 AS h UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23) hours;

-- Incidents — realistic incidents from actual homelab experience
INSERT INTO incidents (id, service_id, started_at, resolved_at, severity, root_cause, resolution, impact) VALUES
(1, NULL, '2026-04-01 14:30:00', '2026-04-01 15:45:00', 'critical',
    'Root filesystem hit 100% — Ubuntu installer only allocated 15GB of 32GB disk',
    'Freed space with docker system prune, expanded LV with lvextend + resize2fs to 30GB',
    'All Docker containers unable to write logs or data'),
(2, 6, '2026-04-05 09:15:00', '2026-04-05 10:30:00', 'major',
    'SNMP Exporter returning only scrape-health metrics, no interface data',
    'Replaced hand-written 14-line config with full 61K-line official default config from container image',
    'No OPNsense network interface metrics in Grafana'),
(3, 4, '2026-04-08 16:00:00', '2026-04-08 16:45:00', 'major',
    'Alloy receiving OPNsense syslog but discarding all entries — RFC5424 vs RFC3164 format mismatch',
    'Added syslog_format = rfc3164 to Alloy config',
    'No firewall logs visible in Loki/Grafana'),
(4, NULL, '2026-04-10 11:00:00', '2026-04-10 12:00:00', 'critical',
    'Subnet conflict — vmbr0 and vmbr1 both on 192.168.0.0/24 causing routing failures',
    'Redesigned network into two subnets: WAN on 192.168.0.0/24, LAN on 10.0.x.0/24',
    'All inter-VLAN routing broken, VMs unreachable'),
(5, 8, '2026-04-12 08:30:00', '2026-04-12 09:00:00', 'minor',
    'Pi-hole failed to build gravity database — Docker DNS couldnt reach internet during startup',
    'Added explicit bootstrap DNS servers (1.1.1.1, 8.8.8.8) via dns: directive in compose',
    'Ad blocking not functional until gravity database built'),
(6, 10, '2026-04-15 20:00:00', '2026-04-15 20:30:00', 'critical',
    'Running docker compose down on services stack killed cloudflared, breaking Cloudflare Tunnel',
    'Accessed server via Proxmox console, ran docker compose up -d to restore all services',
    'Public website and remote access down for 30 minutes'),
(7, 13, '2026-04-23 12:10:00', '2026-04-23 12:16:00', 'minor',
    'Minecraft server showed Can\'t keep up warning after startup — post-spawn-generation catch-up',
    'No action needed — normal behavior for modded servers after initial chunk generation',
    'No player impact — warning is cosmetic');

-- Disk Metrics — daily snapshots for 7 days
INSERT INTO disk_metrics (mount_point, disk_type, total_gb, used_gb, timestamp)
SELECT '/', 'nvme', 30.0,
    ROUND(14.5 + d * 0.1 + ABS(RANDOM() % 5) / 10.0, 1),
    date('2026-04-17', '+' || d || ' days')
FROM (SELECT 0 AS d UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) days;

INSERT INTO disk_metrics (mount_point, disk_type, total_gb, used_gb, timestamp)
SELECT '/mnt/gamedata', 'hdd', 196.0,
    ROUND(0.5 + d * 0.8 + ABS(RANDOM() % 10) / 10.0, 1),
    date('2026-04-17', '+' || d || ' days')
FROM (SELECT 0 AS d UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) days;
