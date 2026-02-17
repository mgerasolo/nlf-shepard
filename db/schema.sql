-- Shepherd Protocol Management System
-- Database Schema v1.0.0
-- Created: 2026-02-13

-- Hosts that run Claude Code
CREATE TABLE IF NOT EXISTS hosts (
    name TEXT PRIMARY KEY,
    role TEXT NOT NULL,  -- 'primary-infra', 'primary-dev', 'backup-infra'
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Host-level deployments (protocols deployed to ~/.claude/)
CREATE TABLE IF NOT EXISTS host_deployments (
    host TEXT NOT NULL REFERENCES hosts(name),
    protocol TEXT NOT NULL,
    version TEXT NOT NULL,
    path TEXT NOT NULL,
    deployed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pinned BOOLEAN DEFAULT FALSE,
    pin_reason TEXT,
    PRIMARY KEY (host, protocol)
);

-- Project-level deployments (protocols deployed to project .claude/)
CREATE TABLE IF NOT EXISTS project_deployments (
    project TEXT NOT NULL,
    host TEXT NOT NULL REFERENCES hosts(name),
    protocol TEXT NOT NULL,
    version TEXT NOT NULL,
    deployed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pinned BOOLEAN DEFAULT FALSE,
    pin_reason TEXT,
    PRIMARY KEY (project, protocol)
);

-- Deployment history (audit trail)
CREATE TABLE IF NOT EXISTS deployment_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    target_type TEXT NOT NULL,  -- 'host' or 'project'
    target TEXT NOT NULL,
    host TEXT,  -- for project deployments, which host
    protocol TEXT NOT NULL,
    from_version TEXT,
    to_version TEXT,
    action TEXT NOT NULL,  -- 'deploy', 'upgrade', 'rollback', 'pin', 'unpin'
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    performed_by TEXT DEFAULT 'claude'
);

-- Protocol bundles for batch deployment
CREATE TABLE IF NOT EXISTS bundles (
    name TEXT PRIMARY KEY,
    description TEXT,
    protocols TEXT NOT NULL,  -- JSON array of protocol names
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Views for common queries

-- What's deployed on a host (both host-level and project-level)
CREATE VIEW IF NOT EXISTS host_full_status AS
SELECT
    h.name as host,
    h.role,
    'host' as deployment_type,
    hd.protocol,
    hd.version,
    hd.pinned,
    hd.pin_reason,
    hd.deployed_at,
    NULL as project
FROM hosts h
LEFT JOIN host_deployments hd ON h.name = hd.host
UNION ALL
SELECT
    pd.host,
    h.role,
    'project' as deployment_type,
    pd.protocol,
    pd.version,
    pd.pinned,
    pd.pin_reason,
    pd.deployed_at,
    pd.project
FROM project_deployments pd
JOIN hosts h ON pd.host = h.name;

-- All pinned deployments
CREATE VIEW IF NOT EXISTS pinned_deployments AS
SELECT 'host' as type, host as target, protocol, version, pin_reason, deployed_at
FROM host_deployments WHERE pinned = 1
UNION ALL
SELECT 'project' as type, project as target, protocol, version, pin_reason, deployed_at
FROM project_deployments WHERE pinned = 1;

-- Recent deployment activity
CREATE VIEW IF NOT EXISTS recent_activity AS
SELECT * FROM deployment_history
ORDER BY performed_at DESC
LIMIT 50;
