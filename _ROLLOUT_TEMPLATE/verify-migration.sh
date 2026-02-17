#!/bin/bash
# Verification script for [Migration Name]
#
# This script verifies that the migration was applied correctly.
# Run from the project root directory.

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

echo "Verifying [Migration Name] migration..."
echo

# Verification checks
echo "Checking files..."

# Check that expected files exist
if [ -f "path/to/expected/file.ts" ]; then
    pass "Expected file exists"
else
    fail "Expected file missing: path/to/expected/file.ts"
fi

# Check file contents
if grep -q "expected pattern" "path/to/file.ts"; then
    pass "File contains expected pattern"
else
    fail "File missing expected pattern"
fi

# Check that old files were removed
if [ ! -f "path/to/old/file.ts" ]; then
    pass "Old file removed"
else
    warn "Old file still exists: path/to/old/file.ts"
fi

# Check package.json dependencies (if applicable)
if command -v jq >/dev/null 2>&1; then
    if jq -e '.dependencies["package-name"]' package.json >/dev/null 2>&1; then
        pass "Package dependency found"
    else
        fail "Package dependency missing"
    fi
fi

echo
echo "================================"
echo -e "${GREEN}✓ All checks passed${NC}"
echo "Migration verified successfully"
echo "================================"
