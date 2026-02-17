# MCP Gateway Configuration Rollout

Standardize MCP configuration across all NLF projects to use the centralized Docker MCP Gateway.

## What This Rollout Does

1. Creates/updates `.mcp.json` in project root with:
   - Docker MCP Gateway (198 tools via SSE)
   - Infisical (secrets management)
   - AdGuard Home (DNS management)
   - Portainer (container management)

2. Infrastructure-only MCPs (not included in standard rollout):
   - hass-mcp (Home Assistant)
   - ollama-mcp (Jarvis local LLM)
   - authentik (identity management)

## MCP Gateway Details

- **URL**: `http://10.0.0.27:2780/sse`
- **Tools**: 198 from Docker catalog
- **Servers**: context7, dockerhub, markitdown, playwright, youtube_transcript, fetch, memory, time, git, docker, sequentialthinking, duckduckgo, wikipedia-mcp, exa, brave, github, grafana, cloudflare-docs, n8n, prometheus, metabase

## Standard .mcp.json Template

```json
{
  "mcpServers": {
    "docker-mcp-gateway": {
      "url": "http://10.0.0.27:2780/sse",
      "transport": "sse"
    },
    "infisical": {
      "command": "npx",
      "args": ["-y", "@infisical/mcp"],
      "env": {
        "INFISICAL_SITE_URL": "https://infisical.lab.nextlevelfoundry.com",
        "INFISICAL_UNIVERSAL_AUTH_CLIENT_ID": "cbf2d7de-80fd-401b-b62f-0a3814fe351f",
        "INFISICAL_UNIVERSAL_AUTH_CLIENT_SECRET": "7dfde8b8376148a6d9e0be30d7481299329f200b4a2bd61c65b25cc6e07bcf1b"
      }
    },
    "adguard-home": {
      "command": "npx",
      "args": ["-y", "@fcannizzaro/mcp-adguard-home"],
      "env": {
        "ADGUARD_URL": "http://10.0.0.27:2720",
        "ADGUARD_USERNAME": "mgerasolo",
        "ADGUARD_PASSWORD": "I@mIronMan"
      }
    },
    "portainer": {
      "command": "/home/mgerasolo/.local/bin/portainer-mcp",
      "args": ["-server", "https://10.0.0.27:2701", "-token", "ptr_xycBHw9cchEXvrWpvrMYd3qzzyhBLuyYoXdLB77t/Uk="]
    }
  }
}
```

## Prerequisites

1. Portainer MCP binary installed at `~/.local/bin/portainer-mcp`
   ```bash
   mkdir -p ~/.local/bin
   curl -sL https://github.com/portainer/portainer-mcp/releases/download/v0.6.0/portainer-mcp-v0.6.0-linux-amd64.tar.gz | tar -xzf - -C ~/.local/bin/
   chmod +x ~/.local/bin/portainer-mcp
   ```

2. Network access to:
   - 10.0.0.27:2780 (MCP Gateway)
   - 10.0.0.27:2720 (AdGuard)
   - 10.0.0.27:2701 (Portainer)

## Verification

After rollout, restart Claude Code session and verify:
- MCP tools are available (198+ from gateway)
- Can query AdGuard, Portainer
