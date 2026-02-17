# MCP Gateway Rollout

**Status:** Complete
**Date:** 2025-12-29
**Scope:** All VMs with Claude Code

## Purpose

Deploy centralized Docker MCP Gateway configuration to all VMs so Claude Code sessions automatically connect to the gateway on Helicarrier.

## What Was Deployed

User-level MCP configuration at `~/.claude/.mcp.json` on each host:

```json
{
  "mcpServers": {
    "docker-mcp-gateway": {
      "url": "http://10.0.0.27:2761/sse",
      "transport": "sse"
    }
  }
}
```

## Hosts Configured

| Host | IP | Status |
|------|-----|--------|
| friday | 10.0.0.35 | Complete |
| stark | 10.0.0.31 | Complete |
| parker | 10.0.0.34 | Complete |
| banner | 10.0.0.33 | Complete |
| hulk | 10.0.0.32 | Complete |
| helicarrier | 10.0.0.27 | Complete |
| coulson | 10.0.0.28 | Complete |

## MCP Gateway Details

- **Location:** Helicarrier (10.0.0.27:2761)
- **Stack:** `/home/mgerasolo/Infrastructure/stacks/mcp-gateway/`
- **23 MCPs configured** (see docker-compose.yml)

## Adding New MCPs

1. Edit `stacks/mcp-gateway/catalog.yaml` (for custom MCPs)
2. Add to `--servers=` list in `docker-compose.yml`
3. Add environment variables if needed
4. Redeploy stack on Helicarrier

All connected hosts automatically get access to new MCPs.

## New Host Setup

For any new VM, run:
```bash
ssh <hostname> 'mkdir -p ~/.claude && cat > ~/.claude/.mcp.json << EOF
{
  "mcpServers": {
    "docker-mcp-gateway": {
      "url": "http://10.0.0.27:2761/sse",
      "transport": "sse"
    }
  }
}
EOF'
```
