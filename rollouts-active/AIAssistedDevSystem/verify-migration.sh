#!/bin/bash
#
# Verify AI-Assisted Development System Setup
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check() {
    local desc="$1"
    local result="$2"

    if [[ "$result" == "pass" ]]; then
        echo -e "${GREEN}✓${NC} $desc"
        ((PASS++))
    elif [[ "$result" == "warn" ]]; then
        echo -e "${YELLOW}!${NC} $desc"
        ((WARN++))
    else
        echo -e "${RED}✗${NC} $desc"
        ((FAIL++))
    fi
}

echo -e "${BLUE}=== AI-Assisted Development System Verification ===${NC}\n"

# Check baton structure
echo -e "${BLUE}Baton Context Management:${NC}"

[[ -d ".claude" ]] && check ".claude/ directory exists" "pass" || check ".claude/ directory exists" "fail"
[[ -d ".claude/conversations" ]] && check ".claude/conversations/ exists" "pass" || check ".claude/conversations/ exists" "fail"
[[ -d ".claude/templates" ]] && check ".claude/templates/ exists" "pass" || check ".claude/templates/ exists" "fail"
[[ -d ".claude/archive" ]] && check ".claude/archive/ exists" "pass" || check ".claude/archive/ exists" "fail"
[[ -f ".claude/settings.json" ]] && check ".claude/settings.json exists" "pass" || check ".claude/settings.json exists" "fail"
[[ -f ".claude/CONVERSATION_HISTORY.md" ]] && check "CONVERSATION_HISTORY.md exists" "pass" || check "CONVERSATION_HISTORY.md exists" "fail"
[[ -f ".claude/BUGS.md" ]] && check "BUGS.md exists" "pass" || check "BUGS.md exists" "fail"
[[ -f ".claude/DECISIONS.md" ]] && check "DECISIONS.md exists" "pass" || check "DECISIONS.md exists" "fail"
[[ -f ".claude/templates/standard.md" ]] && check "Standard template exists" "pass" || check "Standard template exists" "fail"

echo ""

# Check workflow commands
echo -e "${BLUE}Workflow Commands:${NC}"

[[ -d ".claude/commands/wf" ]] && check ".claude/commands/wf/ exists" "pass" || check ".claude/commands/wf/ exists" "fail"
[[ -f ".claude/commands/wf/help.md" ]] && check "help.md command exists" "pass" || check "help.md command exists" "warn"
[[ -f ".claude/commands/wf/status.md" ]] && check "status.md command exists" "pass" || check "status.md command exists" "warn"
[[ -f ".claude/commands/wf/approve.md" ]] && check "approve.md command exists" "pass" || check "approve.md command exists" "warn"

echo ""

# Check GitHub labels (if gh available)
echo -e "${BLUE}GitHub Labels:${NC}"

if command -v gh &> /dev/null; then
    # Check if in a git repo with GitHub remote
    if gh repo view &> /dev/null; then
        LABEL_COUNT=$(gh label list --json name -q 'length' 2>/dev/null || echo "0")

        if [[ "$LABEL_COUNT" -ge 40 ]]; then
            check "GitHub labels ($LABEL_COUNT found, 40+ expected)" "pass"
        elif [[ "$LABEL_COUNT" -ge 20 ]]; then
            check "GitHub labels ($LABEL_COUNT found, 40+ expected)" "warn"
        else
            check "GitHub labels ($LABEL_COUNT found, 40+ expected)" "fail"
        fi

        # Check for key labels
        gh label list --json name -q '.[].name' 2>/dev/null | grep -q "phase:0-backlog" && \
            check "Phase labels present" "pass" || check "Phase labels present" "fail"

        gh label list --json name -q '.[].name' 2>/dev/null | grep -q "next:ai-ready" && \
            check "Next action labels present" "pass" || check "Next action labels present" "fail"

        gh label list --json name -q '.[].name' 2>/dev/null | grep -q "workflow:full" && \
            check "Workflow type labels present" "pass" || check "Workflow type labels present" "fail"
    else
        check "GitHub repo not connected (skip label check)" "warn"
    fi
else
    check "gh CLI not installed (skip label check)" "warn"
fi

echo ""

# Check CLAUDE.md
echo -e "${BLUE}CLAUDE.md Integration:${NC}"

if [[ -f "CLAUDE.md" ]]; then
    check "CLAUDE.md exists" "pass"

    grep -q "AI-Assisted\|Workflow\|phase:" CLAUDE.md 2>/dev/null && \
        check "CLAUDE.md has workflow section" "pass" || check "CLAUDE.md has workflow section" "warn"

    grep -q "baton\|/baton" CLAUDE.md 2>/dev/null && \
        check "CLAUDE.md mentions baton" "pass" || check "CLAUDE.md mentions baton" "warn"
else
    check "CLAUDE.md exists" "fail"
fi

echo ""

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
echo -e "${GREEN}Passed:${NC} $PASS"
echo -e "${YELLOW}Warnings:${NC} $WARN"
echo -e "${RED}Failed:${NC} $FAIL"

echo ""

if [[ "$FAIL" -eq 0 ]]; then
    if [[ "$WARN" -eq 0 ]]; then
        echo -e "${GREEN}All checks passed! AI-Assisted Development System is fully configured.${NC}"
    else
        echo -e "${YELLOW}Setup mostly complete. Review warnings above.${NC}"
    fi
    exit 0
else
    echo -e "${RED}Setup incomplete. Address failed checks before using workflow.${NC}"
    exit 1
fi
