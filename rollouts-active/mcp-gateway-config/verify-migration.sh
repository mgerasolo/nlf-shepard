#!/bin/bash
# Verify MCP Gateway Configuration Rollout

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ERRORS=0

log_pass() { echo -e "${GREEN}✓${NC} $*"; }
log_fail() { echo -e "${RED}✗${NC} $*"; ERRORS=$((ERRORS + 1)); }

echo "Verifying MCP Gateway Configuration..."
echo

# Check .mcp.json exists
if [ -f ".mcp.json" ]; then
    log_pass ".mcp.json exists"
else
    log_fail ".mcp.json not found"
    exit 1
fi

# Check .mcp.json is valid JSON
if jq empty .mcp.json 2>/dev/null; then
    log_pass ".mcp.json is valid JSON"
else
    log_fail ".mcp.json is not valid JSON"
fi

# Check required MCPs are configured
check_mcp() {
    local name="$1"
    if jq -e ".mcpServers[\"$name\"]" .mcp.json >/dev/null 2>&1; then
        log_pass "$name MCP configured"
    else
        log_fail "$name MCP missing"
    fi
}

check_mcp "docker-mcp-gateway"
check_mcp "infisical"
check_mcp "adguard-home"
check_mcp "portainer"

# Check gateway URL is correct
GATEWAY_URL=$(jq -r '.mcpServers["docker-mcp-gateway"].url // ""' .mcp.json)
if [ "$GATEWAY_URL" = "http://10.0.0.27:2780/sse" ]; then
    log_pass "Gateway URL is correct"
else
    log_fail "Gateway URL incorrect: $GATEWAY_URL"
fi

# Check portainer binary exists
if [ -f "$HOME/.local/bin/portainer-mcp" ]; then
    log_pass "Portainer MCP binary installed"
else
    log_fail "Portainer MCP binary not found at ~/.local/bin/portainer-mcp"
fi

# Check .gitignore includes .mcp.json
if [ -f ".gitignore" ]; then
    if grep -q "\.mcp\.json" .gitignore; then
        log_pass ".mcp.json in .gitignore"
    else
        log_fail ".mcp.json not in .gitignore"
    fi
else
    log_fail ".gitignore not found"
fi

echo
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}$ERRORS check(s) failed${NC}"
    exit 1
fi
