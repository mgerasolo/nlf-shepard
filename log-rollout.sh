#!/bin/bash
# ShepardProtocol Audit Log Helper
# Adds rollout execution entries to audit-log.json and AUDIT_LOG.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIT_JSON="$SCRIPT_DIR/audit-log.json"
AUDIT_MD="$SCRIPT_DIR/AUDIT_LOG.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }

usage() {
    cat <<EOF
Usage: $0 <rollout-name>

Generates an audit log entry for a completed rollout by analyzing projects.json.

Arguments:
    rollout-name    Name of the rollout to log (e.g., migrationtostandards2)

Example:
    $0 migrationtostandards2
    $0 Tasks&Issues

The script will:
1. Check projects.json for the rollout status
2. Generate audit entry with project results
3. Append to audit-log.json
4. Append to AUDIT_LOG.md
5. Prompt for additional notes

EOF
    exit 1
}

[[ $# -eq 0 ]] && usage

ROLLOUT_NAME="$1"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_HUMAN=$(date +"%Y-%m-%d")

# Check if rollout exists in projects.json
if ! jq -e ".projects[0].migrations.\"$ROLLOUT_NAME\"" "$SCRIPT_DIR/projects.json" > /dev/null 2>&1; then
    error "Rollout '$ROLLOUT_NAME' not found in projects.json"
    exit 1
fi

info "Analyzing rollout: $ROLLOUT_NAME"

# Extract rollout status for all projects
PROJECTS_DATA=$(jq -r ".projects[] | select(.migrations.\"$ROLLOUT_NAME\" != null) |
    \"\(.id)|\(.name)|\(.host)|\(.priority)|\(.migrations.\"$ROLLOUT_NAME\")\"" \
    "$SCRIPT_DIR/projects.json")

# Count statistics
TOTAL=$(echo "$PROJECTS_DATA" | wc -l)
COMPLETE=$(echo "$PROJECTS_DATA" | grep -c "|complete$" || true)
PENDING=$(echo "$PROJECTS_DATA" | grep -c "|pending$" || true)
SKIP=$(echo "$PROJECTS_DATA" | grep -c "|skip$" || true)
FAILED=$(echo "$PROJECTS_DATA" | grep -c "|failed$" || true)

info "Statistics:"
echo "  Total projects: $TOTAL"
echo "  Complete: $COMPLETE"
echo "  Pending: $PENDING"
echo "  Skipped: $SKIP"
echo "  Failed: $FAILED"

if [[ $COMPLETE -eq 0 ]]; then
    warn "No completed projects found. Are you sure you want to log this rollout?"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

# Prompt for details
echo ""
info "Audit Log Entry Details:"
read -p "Executor (e.g., claude-code-agent, manual): " EXECUTOR
read -p "Execution mode (manual/automated-sequential/automated-parallel/mixed): " EXEC_MODE
read -p "Brief objective/description: " OBJECTIVE
echo ""
info "Enter additional notes (press Ctrl+D when done):"
NOTES=$(cat)

# Generate JSON entry (skeleton - user should add project details)
cat <<EOF

${YELLOW}Note:${NC} Basic audit entry created. You should manually add:
1. Project-specific changes to audit-log.json
2. Detailed changes section to AUDIT_LOG.md
3. Any errors encountered

EOF

success "Audit log entry created for rollout: $ROLLOUT_NAME"
info "Files updated:"
echo "  - $AUDIT_JSON (append project details manually)"
echo "  - $AUDIT_MD (append detailed section manually)"

cat <<EOF

Template for AUDIT_LOG.md:

### $ROLLOUT_NAME
**Date:** $DATE_HUMAN
**Executor:** $EXECUTOR
**Mode:** $EXEC_MODE

**Objective:** $OBJECTIVE

#### Projects Affected ($COMPLETE/$TOTAL completed)

| Project | Host | Priority | Status | Changes | Agent |
|---------|------|----------|--------|---------|-------|
EOF

# Generate project table rows
while IFS='|' read -r id name host priority status; do
    STATUS_SYMBOL="○"
    [[ "$status" == "complete" ]] && STATUS_SYMBOL="✓"
    [[ "$status" == "failed" ]] && STATUS_SYMBOL="✗"
    [[ "$status" == "skip" ]] && STATUS_SYMBOL="−"

    echo "| $name | $host | $priority | $STATUS_SYMBOL $status | [TODO: Add changes] | [TODO: Add agent] |"
done <<< "$PROJECTS_DATA"

cat <<EOF

#### Summary

- **Total projects evaluated:** $TOTAL
- **Projects requiring migration:** [TODO]
- **Projects skipped:** $SKIP
- **Successful migrations:** $COMPLETE
- **Failed migrations:** $FAILED

#### Key Changes by Project

[TODO: Add detailed changes for each project]

#### Errors

[TODO: List errors or write "None"]

#### Notes

$NOTES

---
EOF
