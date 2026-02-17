# NLF Service Integration

## Available Services

Check `/mnt/foundry_resources/` for shared resources available to all dev projects.

## MCP Gateway

For AI-powered features, use the MCP Gateway:

```
URL: http://10.0.0.27:2780/sse
```

Copy `.mcp.json` from Infrastructure project for configuration.

## Domains

| Domain | Purpose |
|--------|---------|
| `*.nextlevelfoundry.com` | Production apps |
| `*.nextlevelguild.com` | Community features |
| `dev.*.nextlevelfoundry.com` | Development |

**Rule:** No 4th-level subdomains (SSL doesn't work).

## Deployment

All apps deploy to Banner (dev) or Hulk (prod):
- **Banner** (10.0.0.33): Development/testing
- **Hulk** (10.0.0.32): Production

Never deploy to Stark (workstation only).

## Cross-Project Communication

Before making breaking changes:
1. Check if other projects depend on your APIs
2. Use `breaking:next-release` label
3. Notify dependent projects via GitHub issues

## Shared Resources

| Resource | Path |
|----------|------|
| Protocols | `/mnt/foundry_resources/protocols/` |
| Research | `/mnt/foundry_resources/research/` |
| AI Handoffs | `/mnt/foundry_resources/ai-handoffs/` |
| Dev Standards | `/mnt/foundry_devlab/standards-dev/` |

## Getting Help

- Infrastructure issues → [nlf-infrastructure](https://github.com/mgerasolo/nlf-infrastructure/issues)
- Cross-project coordination → Use `blocks:{project}` labels
