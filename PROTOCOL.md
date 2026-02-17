# Shepherd - Protocol Lifecycle Management System

**Version:** 2.0.0
**Status:** Active

Shepherd manages the complete lifecycle of Claude Code protocols: inventory, distribution, version tracking, and feedback collection.

## Overview

The shepherd metaphor: know the flock, track each sheep, move them where needed, and manage the whole system.

### Lifecycle Phases

```
┌─────────────┐
│  INVENTORY  │  Know what protocols exist (catalog.json)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ DISTRIBUTE  │  Roll out to hosts/projects
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   TRACK     │  Record what version is where (shepherd.db)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   HERD      │  Collect feedback over time (herding/)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  ITERATE    │  Improve protocol, bump version
└──────┴──────┘
       │
       └──────► Back to DISTRIBUTE
```

## Directory Structure

```
ShepardProtocol/
├── PROTOCOL.md              # This file
├── QUICK_START.md           # Quick reference
├── shepard.sh               # CLI for all operations
│
├── catalog.json             # Protocol definitions (JSON, git-tracked)
│
├── db/
│   ├── schema.sql           # Database schema
│   └── shepherd.db          # Deployment state (SQLite)
│
├── projects.json            # Project registry (metadata only)
│
├── herding/
│   ├── README.md            # Herding documentation
│   ├── pending/             # Feedback awaiting review
│   └── processed/           # Feedback addressed
│
├── rollouts-active/         # Rollout definitions
└── schemas/                 # JSON schemas
```

## Quick Start

```bash
# List all protocols
./shepard.sh catalog

# Check what's deployed where
./shepard.sh hosts status

# Check for version drift
./shepard.sh drift

# Deploy a protocol to infrastructure hosts
./shepard.sh deploy-host work-tracking --infra

# Submit feedback on a protocol
./shepard.sh herd new baton
```

## Deployment Types

| Type | Target | Path | Hosts |
|------|--------|------|-------|
| **host** | Claude Code hosts | `~/.claude/` | friday, stark, helicarrier |
| **project** | Project repositories | `.claude/` | N/A (per-project) |

## Claude Code Hosts

| Host | Role | Auto-deploy |
|------|------|-------------|
| friday | Primary infrastructure | Yes |
| stark | Development workstation | Yes |
| helicarrier | Backup (break-glass) | Infra protocols only |

## CLI Reference

### Inventory

```bash
shepard.sh catalog              # List all protocols
shepard.sh catalog show <p>     # Show protocol details
shepard.sh hosts                # List Claude Code hosts
shepard.sh hosts status         # Show deployments per host
shepard.sh bundles              # List protocol bundles
```

### Deployment

```bash
shepard.sh deploy-host <p> <h>  # Deploy to specific host
shepard.sh deploy-host <p> --infra  # Deploy to friday + helicarrier
shepard.sh deploy-host <p> <h> --dry-run  # Preview
```

### Version Management

```bash
shepard.sh drift                # Check all for version drift
shepard.sh drift <protocol>     # Check specific protocol
shepard.sh upgrade <p>          # Upgrade all non-pinned
shepard.sh upgrade <p> --cascade  # Also upgrade dependents
```

### Pinning

```bash
shepard.sh pin <p> --host <h> --reason "..."
shepard.sh unpin <p> --host <h>
shepard.sh pins                 # List all pins
```

### Dependencies

```bash
shepard.sh deps <protocol>      # Show dependencies
shepard.sh deps <p> --reverse   # Show what depends on this
```

### Herding (Feedback)

```bash
shepard.sh herd list            # List pending feedback
shepard.sh herd new <p>         # Create feedback file
shepard.sh herd propose <name>  # Propose new protocol
shepard.sh herd process <file>  # Move to processed
```

## Version Pinning

When a target is pinned, upgrades explicitly skip it:

```
Upgrading work-tracking to 1.2.0...
  friday:      1.1.0 → 1.2.0 ✓ upgraded
  stark:       ⚠️ SKIPPED (pinned at 1.1.0)
               Reason: "Testing v1.1 stability"
               To upgrade anyway: shepard.sh upgrade work-tracking --host stark --force
               To unpin: shepard.sh unpin work-tracking --host stark
  helicarrier: 1.1.0 → 1.2.0 ✓ upgraded

Summary: 2 upgraded, 1 skipped (pinned)
```

## Data Storage

### catalog.json (Protocol Definitions)

JSON file, git-tracked. Contains:
- Protocol metadata (version, description, status)
- Deployment type (host or project)
- Dependencies
- Repository location

### shepherd.db (Deployment State)

SQLite database. Contains:
- `hosts` - Claude Code hosts
- `host_deployments` - What's deployed to each host
- `project_deployments` - What's deployed to each project
- `deployment_history` - Audit trail
- `bundles` - Protocol bundles

## Dependencies

Shepherd depends on the infrastructure graph for impact analysis:

```bash
shepard.sh impact work-tracking
```

This queries the graph to find what would be affected by changes.

## Related

- [protocols/INDEX.md](/mnt/foundry_resources/protocols/INDEX.md)
- [Issue #222](https://github.com/mgerasolo/nlf-infrastructure/issues/222)
- [herding/README.md](herding/README.md)
