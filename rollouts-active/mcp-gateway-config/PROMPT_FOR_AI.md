# MCP Gateway Configuration Rollout

## Task

Configure this project to use the centralized NLF MCP Gateway and standard MCPs.

## Steps

1. **Install Portainer MCP binary** (if not already installed):
   ```bash
   mkdir -p ~/.local/bin
   curl -sL https://github.com/portainer/portainer-mcp/releases/download/v0.6.0/portainer-mcp-v0.6.0-linux-amd64.tar.gz -o /tmp/portainer-mcp.tar.gz
   tar -xzf /tmp/portainer-mcp.tar.gz -C ~/.local/bin/
   chmod +x ~/.local/bin/portainer-mcp
   ```

2. **Create or update `.mcp.json`** in the project root with this exact content:

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

3. **Add `.mcp.json` to `.gitignore`** (if not already present) - contains credentials:
   - Check if `.gitignore` exists
   - Add `.mcp.json` to it if not already listed

4. **Verify the configuration**:
   - Confirm `.mcp.json` exists with correct content
   - Confirm `.gitignore` includes `.mcp.json`

## What You Get

- **Docker MCP Gateway**: 198 tools including context7, exa, brave, github, grafana, n8n, prometheus, metabase, and more
- **Infisical**: Secrets management
- **AdGuard Home**: DNS ad-blocking management
- **Portainer**: Container management

## Completion Criteria

- [ ] Portainer MCP binary installed at `~/.local/bin/portainer-mcp`
- [ ] `.mcp.json` created with all 4 MCPs configured
- [ ] `.mcp.json` added to `.gitignore`
- [ ] No syntax errors in `.mcp.json`

Report completion status when done.
