#!/bin/bash
# Cross-project dependency checker for PLUGIN/CONSUMER projects
# Checks upstream dependencies for breaking changes and blockers

set -e

REPO_OWNER="mgerasolo"
PROJECT_ID="{PROJECT_ID}"  # Replace with actual project ID

# Replace with actual upstream dependencies (space-separated)
DEPENDENCIES="{DEPENDENCIES_ARRAY}"  # e.g., "core-api shared-lib"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Cross-Project Dependency Check: ${PROJECT_ID}"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check upstream dependencies for breaking changes
if [[ -n "$DEPENDENCIES" ]]; then
    echo "=== Upstream Breaking Changes ==="

    HAS_BREAKING=false
    for dep in $DEPENDENCIES; do
        echo ""
        echo "--- $dep ---"
        BREAKING=$(gh issue list --repo "${REPO_OWNER}/${dep}" \
            --label "breaking:next-release" \
            --json number,title,body \
            --template '{{range .}}⚠️  #{{.number}}: {{.title}}{{"\n"}}{{end}}' 2>/dev/null || echo "")

        if [[ -z "$BREAKING" ]]; then
            echo "  ✓ No breaking changes scheduled"
        else
            echo "$BREAKING"
            HAS_BREAKING=true
        fi

        # Check for new features
        FEATURES=$(gh issue list --repo "${REPO_OWNER}/${dep}" \
            --label "provides" \
            --state closed \
            --limit 3 \
            --json number,title \
            --template '{{range .}}  💡 #{{.number}}: {{.title}}{{"\n"}}{{end}}' 2>/dev/null || echo "")

        if [[ -n "$FEATURES" ]]; then
            echo "  Recent features:"
            echo "$FEATURES"
        fi
    done

    if [[ "$HAS_BREAKING" == "true" ]]; then
        echo ""
        echo "⚠️  ACTION REQUIRED: Review breaking changes above before proceeding"
    fi
else
    echo "⚠️  No dependencies configured"
    echo "   Update DEPENDENCIES variable in this script"
fi

echo ""
echo "=== Blocking Issues in This Project ==="
BLOCKED=$(gh issue list --repo "${REPO_OWNER}/${PROJECT_ID}" \
    --label "blocked" \
    --json number,title,labels \
    --jq '.[] | "🔒 #\(.number): \(.title) - Labels: \([.labels[].name] | join(", "))"' 2>/dev/null || echo "")

if [[ -z "$BLOCKED" ]]; then
    echo "  ✓ No blocked issues"
else
    echo "$BLOCKED"
fi

echo ""
echo "=== Infisical State Check ==="
if command -v infisical &> /dev/null || [[ -f ~/Infrastructure/scripts/secrets.sh ]]; then
    source ~/Infrastructure/scripts/secrets.sh 2>/dev/null || true

    for dep in $DEPENDENCIES; do
        DEP_UPPER=$(echo "$dep" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
        BREAKING_STATE=$(secret_get "${DEP_UPPER}_BREAKING_CHANGES" 2>/dev/null || echo "")
        VERSION_STATE=$(secret_get "${DEP_UPPER}_VERSION" 2>/dev/null || echo "")

        if [[ -n "$BREAKING_STATE" ]] || [[ -n "$VERSION_STATE" ]]; then
            echo "$dep:"
            [[ -n "$VERSION_STATE" ]] && echo "  Version: $VERSION_STATE"
            [[ -n "$BREAKING_STATE" ]] && echo "  ⚠️  Breaking: $BREAKING_STATE"
        fi
    done
else
    echo "  ⚠️  Infisical not configured (install or run secrets-setup.sh)"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "Tip: Run with 'watch -n 60' to monitor continuously"
