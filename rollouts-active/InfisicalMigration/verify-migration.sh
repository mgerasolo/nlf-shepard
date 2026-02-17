#!/bin/bash
# Verification script for Phase to Infisical migration
#
# Usage:
#   ./verify-migration.sh --check    # Check if migration needed
#   ./verify-migration.sh --verify   # Verify migration complete
#   ./verify-migration.sh --migrate  # Run automated migration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
WARNINGS=0
ERRORS=0
CHECKS=0

# Results storage
PHASE_FILES=()
PHASE_DOCS=()
INFISICAL_STATUS=""

echo "======================================"
echo "Phase to Infisical Migration Checker"
echo "======================================"
echo ""

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((CHECKS++))
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    ((ERRORS++))
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check 1: Infisical CLI availability
check_infisical_cli() {
    log_info "Checking Infisical CLI..."

    if command_exists infisical; then
        local version=$(infisical --version 2>/dev/null | head -n1)
        log_success "Infisical CLI installed: $version"
        return 0
    else
        log_error "Infisical CLI not installed"
        echo "  Install with: curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash && sudo apt-get install -y infisical"
        return 1
    fi
}

# Check 2: Infisical authentication
check_infisical_auth() {
    log_info "Checking Infisical authentication..."

    if ! command_exists infisical; then
        log_warning "Skipping auth check (CLI not installed)"
        return 1
    fi

    if infisical secrets list --env prod &>/dev/null; then
        log_success "Infisical authenticated and working"
        INFISICAL_STATUS="authenticated"
        return 0
    else
        log_warning "Infisical not authenticated (fallback .env will be used)"
        INFISICAL_STATUS="not_authenticated"
        return 1
    fi
}

# Check 3: Fallback .env files exist
check_env_fallback() {
    log_info "Checking fallback .env files..."

    local found=0

    if [[ -f ~/.secrets/nlf-infrastructure.env ]]; then
        log_success "Infrastructure .env exists: ~/.secrets/nlf-infrastructure.env"
        ((found++))
    else
        log_warning "Infrastructure .env not found: ~/.secrets/nlf-infrastructure.env"
    fi

    if [[ -f ~/.secrets/nlf-appservices.env ]]; then
        log_success "AppServices .env exists: ~/.secrets/nlf-appservices.env"
        ((found++))
    else
        log_warning "AppServices .env not found: ~/.secrets/nlf-appservices.env"
    fi

    if [[ $found -eq 0 ]]; then
        log_error "No fallback .env files found"
        return 1
    fi

    return 0
}

# Check 4: Search for Phase CLI usage in scripts
check_phase_in_scripts() {
    log_info "Searching for Phase CLI usage in scripts..."

    local phase_files=$(grep -r "phase secrets\|phase run\|phase export" \
        --include="*.sh" \
        --exclude-dir=".git" \
        --exclude-dir="#archived" \
        --exclude-dir="node_modules" \
        . 2>/dev/null | grep -v "DEPRECATED\|historical" || true)

    if [[ -z "$phase_files" ]]; then
        log_success "No active Phase CLI usage found in scripts"
        return 0
    else
        log_warning "Found Phase CLI usage in scripts:"
        echo "$phase_files" | while read -r line; do
            echo "    $line"
            PHASE_FILES+=("$line")
        done
        return 1
    fi
}

# Check 5: Search for Phase references in documentation
check_phase_in_docs() {
    log_info "Searching for Phase references in documentation..."

    local phase_docs=$(grep -r "Using Phase\|Phase CLI\|phase secrets" \
        --include="*.md" \
        --exclude-dir=".git" \
        --exclude-dir="#archived" \
        --exclude-dir="node_modules" \
        . 2>/dev/null | grep -v "Previously\|DEPRECATED\|historical\|migrated from Phase" || true)

    if [[ -z "$phase_docs" ]]; then
        log_success "No active Phase references in documentation"
        return 0
    else
        log_warning "Found Phase references in documentation:"
        echo "$phase_docs" | head -n 10 | while read -r line; do
            echo "    $line"
            PHASE_DOCS+=("$line")
        done
        if [[ $(echo "$phase_docs" | wc -l) -gt 10 ]]; then
            echo "    ... and $(($(echo "$phase_docs" | wc -l) - 10)) more"
        fi
        return 1
    fi
}

# Check 6: Search for Phase environment variables
check_phase_env_vars() {
    log_info "Searching for Phase environment variables..."

    local phase_vars=$(grep -r "PHASE_SERVICE_TOKEN\|PHASE_HOST" \
        --include="*.sh" --include="*.env*" \
        --exclude-dir=".git" \
        --exclude-dir="#archived" \
        . 2>/dev/null | grep -v ".backup" | grep -v "DEPRECATED" || true)

    if [[ -z "$phase_vars" ]]; then
        log_success "No Phase environment variables found"
        return 0
    else
        log_warning "Found Phase environment variables:"
        echo "$phase_vars" | while read -r line; do
            echo "    $line"
        done
        return 1
    fi
}

# Check 7: Test secret retrieval
check_secret_retrieval() {
    log_info "Testing secret retrieval via helper script..."

    # Check if secrets.sh exists
    local secrets_script=""
    if [[ -f ~/Infrastructure/scripts/secrets.sh ]]; then
        secrets_script=~/Infrastructure/scripts/secrets.sh
    elif [[ -f scripts/secrets.sh ]]; then
        secrets_script=scripts/secrets.sh
    elif [[ -f ./secrets.sh ]]; then
        secrets_script=./secrets.sh
    fi

    if [[ -z "$secrets_script" ]]; then
        log_warning "secrets.sh not found (skipping retrieval test)"
        return 1
    fi

    # Try to source and test
    if source "$secrets_script" 2>/dev/null && secret_get PORTAINER_USERNAME &>/dev/null; then
        log_success "Secret retrieval working via secrets.sh"
        return 0
    else
        log_warning "Could not test secret retrieval (may be normal if not in infrastructure repo)"
        return 1
    fi
}

# Check 8: Look for phase-*.sh scripts
check_phase_scripts() {
    log_info "Checking for Phase-specific scripts..."

    local phase_scripts=$(find . -name "phase-*.sh" -type f ! -path "*/#archived/*" ! -path "*/.git/*" 2>/dev/null || true)

    if [[ -z "$phase_scripts" ]]; then
        log_success "No Phase-specific scripts found"
        return 0
    else
        log_warning "Found Phase-specific scripts:"
        echo "$phase_scripts" | while read -r script; do
            echo "    $script"
        done
        echo "  Consider archiving to #archived/ directory"
        return 1
    fi
}

# Summary
print_summary() {
    echo ""
    echo "======================================"
    echo "Migration Check Summary"
    echo "======================================"
    echo -e "${GREEN}Checks passed:${NC} $CHECKS"
    echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
    echo -e "${RED}Errors:${NC} $ERRORS"
    echo ""

    if [[ $ERRORS -gt 0 ]]; then
        echo -e "${RED}Migration BLOCKED${NC} - Fix errors before proceeding"
        echo ""
        echo "Common fixes:"
        echo "  - Install Infisical CLI: curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash && sudo apt-get install -y infisical"
        echo "  - Authenticate: infisical login"
        echo "  - Create .env fallback: cp .env.example ~/.secrets/nlf-infrastructure.env"
        return 1
    elif [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}Migration NEEDED${NC} - Phase references found"
        echo ""
        echo "Next steps:"
        echo "  1. Review warnings above"
        echo "  2. Read PROMPT_FOR_AI.md for migration steps"
        echo "  3. Run: ./verify-migration.sh --migrate (if available)"
        echo "  4. Or migrate manually using migration-guide.md"
        return 2
    else
        echo -e "${GREEN}Migration COMPLETE${NC} - No Phase references found"
        echo ""
        echo "System is using Infisical for secrets management."
        if [[ "$INFISICAL_STATUS" == "not_authenticated" ]]; then
            echo "Note: Infisical CLI not authenticated - using .env fallback (this is OK)"
        fi
        return 0
    fi
}

# Main execution
main() {
    local mode="${1:---check}"

    case "$mode" in
        --check)
            echo "Running migration checks..."
            echo ""

            check_infisical_cli
            check_infisical_auth
            check_env_fallback
            check_phase_in_scripts
            check_phase_in_docs
            check_phase_env_vars
            check_secret_retrieval
            check_phase_scripts

            print_summary
            exit $?
            ;;

        --verify)
            echo "Verifying migration completion..."
            echo ""

            check_infisical_cli || exit 1
            check_env_fallback || exit 1

            if check_phase_in_scripts && check_phase_in_docs && check_phase_env_vars && check_phase_scripts; then
                log_success "Migration verified - no Phase references found"
                exit 0
            else
                log_error "Migration incomplete - Phase references still exist"
                exit 1
            fi
            ;;

        --migrate)
            log_error "Automated migration not yet implemented"
            echo ""
            echo "For now, use manual migration:"
            echo "  1. Read migration-guide.md for step-by-step instructions"
            echo "  2. Or use PROMPT_FOR_AI.md with Claude Code"
            exit 1
            ;;

        *)
            echo "Usage: $0 [--check|--verify|--migrate]"
            echo ""
            echo "  --check   Check if migration is needed (default)"
            echo "  --verify  Verify migration is complete"
            echo "  --migrate Run automated migration (if available)"
            exit 1
            ;;
    esac
}

main "$@"
