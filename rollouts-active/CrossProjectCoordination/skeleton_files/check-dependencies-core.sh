#!/bin/bash
# Cross-project dependency checker for CORE/FRAMEWORK projects
# Checks which downstream projects depend on this project

set -e

REPO_OWNER="mgerasolo"
PROJECT_ID="{PROJECT_ID}"  # Replace with actual project ID

# Replace with actual dependent projects (space-separated)
DEPENDENTS="{DEPENDENTS_ARRAY}"  # e.g., "plugin-a plugin-b plugin-c"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Cross-Project Dependency Check: ${PROJECT_ID}"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check downstream projects that depend on this core
if [[ -n "$DEPENDENTS" ]]; then
    echo "=== Projects Depending on ${PROJECT_ID} ==="
    for dep in $DEPENDENTS; do
        echo ""
        echo "--- $dep ---"
        RESULTS=$(gh issue list --repo "${REPO_OWNER}/${dep}" \
            --search "depends-on:${PROJECT_ID}" \
            --json number,title \
            --template '{{range .}}#{{.number}}: {{.title}}{{"\n"}}{{end}}' 2>/dev/null || echo "  (no issues found)")

        if [[ -z "$RESULTS" ]]; then
            echo "  ✓ No blocking dependencies"
        else
            echo "$RESULTS"
        fi
    done
else
    echo "⚠️  No dependent projects configured"
    echo "   Update DEPENDENTS variable in this script"
fi

echo ""
echo "=== Breaking Changes in This Repository ==="
BREAKING=$(gh issue list --repo "${REPO_OWNER}/${PROJECT_ID}" \
    --label "breaking:next-release" \
    --json number,title,createdAt \
    --template '{{range .}}#{{.number}}: {{.title}} ({{timeago .createdAt}}){{"\n"}}{{end}}' 2>/dev/null || echo "")

if [[ -z "$BREAKING" ]]; then
    echo "  ✓ No breaking changes scheduled"
else
    echo "$BREAKING"
fi

echo ""
echo "=== Recently Provided Features ==="
gh issue list --repo "${REPO_OWNER}/${PROJECT_ID}" \
    --label "provides" \
    --state closed \
    --limit 5 \
    --json number,title,closedAt \
    --template '{{range .}}#{{.number}}: {{.title}} ({{timeago .closedAt}}){{"\n"}}{{end}}' 2>/dev/null || echo "  (none)"

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Tip: Run with 'watch -n 60' to monitor continuously"
