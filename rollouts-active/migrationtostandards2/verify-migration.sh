#!/bin/bash
# verify-migration.sh
# Automated verification script for Standards-v2 migration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0
PASSED=0

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}Standards-v2 Migration Verification${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo ""

# Check 1: Old Standards/ references (should be none)
echo -e "${BLUE}[1/6] Checking for old Standards/ references...${NC}"
OLD_REFS=$(grep -r "Standards/" . \
  --include="*.md" \
  --include="*.json" \
  --include="*.yml" \
  --include="*.yaml" \
  --include="*.sh" \
  --include=".env*" \
  --include="CLAUDE.md" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git" \
  --exclude-dir="UpdateAllDevProjects" \
  2>/dev/null | grep -v "Standards-v2" || true)

if [ -z "$OLD_REFS" ]; then
  echo -e "${GREEN}✓ PASS${NC} - No old Standards/ references found"
  ((PASSED++))
else
  echo -e "${RED}✗ FAIL${NC} - Found old Standards/ references:"
  echo "$OLD_REFS" | head -10
  if [ $(echo "$OLD_REFS" | wc -l) -gt 10 ]; then
    echo "... and $(( $(echo "$OLD_REFS" | wc -l) - 10 )) more"
  fi
  ((ERRORS++))
fi
echo ""

# Check 2: Infrastructure references (app projects should have none)
echo -e "${BLUE}[2/6] Checking for infrastructure standards references...${NC}"
INFRA_REFS=$(grep -r "Standards-v2/infrastructure" . \
  --include="*.md" \
  --include="*.json" \
  --include="*.yml" \
  --include="*.yaml" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git" \
  --exclude-dir="UpdateAllDevProjects" \
  2>/dev/null || true)

if [ -z "$INFRA_REFS" ]; then
  echo -e "${GREEN}✓ PASS${NC} - No infrastructure references (correct for app projects)"
  ((PASSED++))
else
  echo -e "${YELLOW}⚠ WARNING${NC} - Found infrastructure references (app projects should only use shared/ and apps/):"
  echo "$INFRA_REFS" | head -5
  if [ $(echo "$INFRA_REFS" | wc -l) -gt 5 ]; then
    echo "... and $(( $(echo "$INFRA_REFS" | wc -l) - 5 )) more"
  fi
  ((WARNINGS++))
fi
echo ""

# Check 3: Verify Standards-v2 usage
echo -e "${BLUE}[3/6] Checking for Standards-v2 references...${NC}"
V2_REFS=$(grep -r "Standards-v2" . \
  --include="*.md" \
  --include="*.json" \
  --include="*.yml" \
  --include="*.yaml" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git" \
  --exclude-dir="UpdateAllDevProjects" \
  2>/dev/null || true)

if [ -n "$V2_REFS" ]; then
  V2_COUNT=$(echo "$V2_REFS" | wc -l)
  echo -e "${GREEN}✓ PASS${NC} - Found $V2_COUNT Standards-v2 references"
  ((PASSED++))
else
  echo -e "${YELLOW}⚠ WARNING${NC} - No Standards-v2 references found (project may not use standards)"
  ((WARNINGS++))
fi
echo ""

# Check 4: Verify paths exist
echo -e "${BLUE}[4/6] Verifying referenced paths exist...${NC}"
MISSING_PATHS=0

# Extract unique paths from references
PATHS=$(grep -r "Standards-v2" . \
  --include="*.md" \
  --include="*.json" \
  --include="*.yml" \
  --include="*.yaml" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git" \
  --exclude-dir="UpdateAllDevProjects" \
  2>/dev/null | \
  grep -o "Standards-v2/[^[:space:])\"\'\]]*" | \
  sort -u || true)

if [ -n "$PATHS" ]; then
  while IFS= read -r path; do
    # Convert relative path to absolute
    FULL_PATH="/mnt/foundry_project/Forge/$path"
    # Remove any trailing punctuation or markdown
    FULL_PATH=$(echo "$FULL_PATH" | sed 's/[,.:;)]$//')

    if [ ! -e "$FULL_PATH" ]; then
      if [ $MISSING_PATHS -eq 0 ]; then
        echo -e "${RED}✗ FAIL${NC} - Missing paths:"
      fi
      echo "  - $FULL_PATH"
      ((MISSING_PATHS++))
    fi
  done <<< "$PATHS"

  if [ $MISSING_PATHS -eq 0 ]; then
    echo -e "${GREEN}✓ PASS${NC} - All referenced paths exist"
    ((PASSED++))
  else
    ((ERRORS++))
  fi
else
  echo -e "${YELLOW}⚠ WARNING${NC} - No paths to verify"
  ((WARNINGS++))
fi
echo ""

# Check 5: CLAUDE.md compliance
echo -e "${BLUE}[5/6] Checking CLAUDE.md for standards references...${NC}"
if [ -f "CLAUDE.md" ]; then
  CLAUDE_OLD=$(grep "Standards/" CLAUDE.md 2>/dev/null | grep -v "Standards-v2" || true)

  if [ -z "$CLAUDE_OLD" ]; then
    echo -e "${GREEN}✓ PASS${NC} - CLAUDE.md has no old Standards/ references"
    ((PASSED++))
  else
    echo -e "${RED}✗ FAIL${NC} - CLAUDE.md still has old Standards/ references:"
    echo "$CLAUDE_OLD"
    ((ERRORS++))
  fi
else
  echo -e "${YELLOW}⚠ WARNING${NC} - No CLAUDE.md file found"
  ((WARNINGS++))
fi
echo ""

# Check 6: Appropriate standards for app projects
echo -e "${BLUE}[6/6] Checking for appropriate standards usage...${NC}"
APPROPRIATE=true

# Count references to each category
SHARED_REFS=$(grep -r "Standards-v2/shared" . \
  --include="*.md" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git" \
  --exclude-dir="UpdateAllDevProjects" \
  2>/dev/null | wc -l || echo "0")

APPS_REFS=$(grep -r "Standards-v2/apps" . \
  --include="*.md" \
  --exclude-dir="node_modules" \
  --exclude-dir=".git" \
  --exclude-dir="UpdateAllDevProjects" \
  2>/dev/null | wc -l || echo "0")

INFRA_REFS_COUNT=$(echo "$INFRA_REFS" | grep -v "^$" | wc -l || echo "0")

echo "  Shared standards:        $SHARED_REFS references"
echo "  App standards:           $APPS_REFS references"
echo "  Infrastructure standards: $INFRA_REFS_COUNT references"

if [ "$INFRA_REFS_COUNT" -gt 0 ]; then
  echo -e "${YELLOW}⚠ WARNING${NC} - App projects should primarily use shared/ and apps/ standards"
  ((WARNINGS++))
else
  echo -e "${GREEN}✓ PASS${NC} - Using appropriate standards for app project"
  ((PASSED++))
fi
echo ""

# Summary
echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}Verification Summary${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo ""
echo -e "${GREEN}Passed:   $PASSED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Errors:   $ERRORS${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✓ MIGRATION COMPLETE${NC} - All checks passed!"
  echo ""
  echo "Next steps:"
  echo "1. Run build/test commands to verify nothing broke"
  echo "2. Commit changes: git add . && git commit -m 'chore: migrate to Standards-v2'"
  echo "3. Clean up: rm -rf UpdateAllDevProjects/migrationtostandards2"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠ MIGRATION COMPLETE WITH WARNINGS${NC}"
  echo ""
  echo "Review warnings above. If acceptable:"
  echo "1. Run build/test commands to verify nothing broke"
  echo "2. Commit changes: git add . && git commit -m 'chore: migrate to Standards-v2'"
  echo "3. Clean up: rm -rf UpdateAllDevProjects/migrationtostandards2"
  exit 0
else
  echo -e "${RED}✗ MIGRATION INCOMPLETE${NC} - Fix errors above before proceeding"
  echo ""
  echo "Common fixes:"
  echo "- Update remaining old Standards/ references to Standards-v2/"
  echo "- Remove infrastructure references (app projects should use shared/ and apps/)"
  echo "- Check that file paths are correct"
  exit 1
fi
