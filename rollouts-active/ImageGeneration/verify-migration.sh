#!/bin/bash
set -euo pipefail

# Verify Image Generation Integration
# Run from project directory

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_error() { echo -e "${RED}✗${NC} $*"; }

errors=0

# Check CLAUDE.md has image generation section
if [ -f "CLAUDE.md" ]; then
    if grep -q "Image Generation" CLAUDE.md && grep -q "10.0.0.27:2725/webhook/generate-image" CLAUDE.md; then
        log_success "CLAUDE.md has Image Generation section"
    else
        log_error "CLAUDE.md missing Image Generation section"
        errors=$((errors + 1))
    fi
else
    log_error "CLAUDE.md not found"
    errors=$((errors + 1))
fi

# Check n8n webhook is accessible
if curl -s --connect-timeout 5 "http://10.0.0.27:2725" > /dev/null 2>&1; then
    log_success "n8n webhook endpoint accessible"
else
    log_error "Cannot reach n8n at 10.0.0.27:2725"
    errors=$((errors + 1))
fi

# Summary
echo
if [ $errors -eq 0 ]; then
    log_success "All checks passed"
    exit 0
else
    log_error "$errors check(s) failed"
    exit 1
fi
