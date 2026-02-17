#!/bin/bash
set -euo pipefail

# ============================================================================
# Shepherd - Protocol Lifecycle Management System
# Version 2.0.0
#
# Commands:
#   catalog     - Protocol inventory
#   hosts       - Claude Code hosts and deployments
#   deploy-host - Deploy host-level protocol
#   drift       - Version drift detection
#   deps        - Protocol dependencies
#   pin/unpin   - Version pinning
#   herd        - Feedback collection
#   upgrade     - Upgrade protocols
#   rollouts    - Legacy rollout orchestration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATALOG_FILE="$SCRIPT_DIR/catalog.json"
PROJECTS_FILE="$SCRIPT_DIR/projects.json"
DB_FILE="$SCRIPT_DIR/db/shepherd.db"
HERDING_DIR="$SCRIPT_DIR/herding"
ROLLOUTS_DIR="$SCRIPT_DIR/rollouts-active"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Logging
log_info() { echo -e "${BLUE}ℹ ${NC}$*"; }
log_success() { echo -e "${GREEN}✓ ${NC}$*"; }
log_warning() { echo -e "${YELLOW}⚠ ${NC}$*"; }
log_error() { echo -e "${RED}✗ ${NC}$*"; }
log_header() { echo -e "\n${BOLD}${CYAN}$*${NC}\n"; }

# ============================================================================
# REQUIREMENTS CHECK
# ============================================================================

check_requirements() {
    local missing=()
    command -v jq >/dev/null 2>&1 || missing+=("jq")
    command -v sqlite3 >/dev/null 2>&1 || missing+=("sqlite3")

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing[*]}"
        exit 1
    fi

    if [ ! -f "$DB_FILE" ]; then
        log_error "Database not found: $DB_FILE"
        log_info "Run: sqlite3 $DB_FILE < $SCRIPT_DIR/db/schema.sql"
        exit 1
    fi
}

# ============================================================================
# DATABASE HELPERS
# ============================================================================

db_query() {
    sqlite3 -separator '|' "$DB_FILE" "$1"
}

db_exec() {
    sqlite3 "$DB_FILE" "$1"
}

# ============================================================================
# CATALOG COMMANDS
# ============================================================================

cmd_catalog() {
    local subcmd="${1:-list}"
    shift || true

    case "$subcmd" in
        list|"")
            catalog_list
            ;;
        show)
            catalog_show "$@"
            ;;
        *)
            log_error "Unknown catalog command: $subcmd"
            echo "Usage: shepard.sh catalog [list|show <protocol>]"
            exit 1
            ;;
    esac
}

catalog_list() {
    log_header "Protocol Catalog"

    jq -r '
        .protocols | to_entries[] |
        "\(.key)|\(.value.version)|\(.value.status)|\(.value.deploymentType)|\(.value.description)"
    ' "$CATALOG_FILE" | while IFS='|' read -r name version status type desc; do
        local type_icon="📁"
        [ "$type" = "host" ] && type_icon="🖥️"

        local status_color="$GREEN"
        [ "$status" = "planned" ] && status_color="$YELLOW"
        [ "$status" = "deprecated" ] && status_color="$RED"

        echo -e "${BOLD}$name${NC} v$version ${status_color}[$status]${NC} $type_icon"
        echo -e "  $desc"
        echo
    done
}

catalog_show() {
    local protocol="${1:-}"

    if [ -z "$protocol" ]; then
        log_error "Protocol name required"
        echo "Usage: shepard.sh catalog show <protocol>"
        exit 1
    fi

    local exists=$(jq -r --arg p "$protocol" '.protocols[$p] // empty' "$CATALOG_FILE")
    if [ -z "$exists" ]; then
        log_error "Protocol not found: $protocol"
        exit 1
    fi

    log_header "Protocol: $protocol"
    jq -r --arg p "$protocol" '
        .protocols[$p] |
        "Version:        \(.version)",
        "Status:         \(.status)",
        "Type:           \(.deploymentType)",
        "Description:    \(.description)",
        "Repository:     \(.repo)",
        "Entry:          \(.entry)",
        "Hooks:          \(.hooks | join(", ") // "none")",
        "Commands:       \(.commands | join(", ") // "none")",
        "Dependencies:   \(.dependencies | join(", ") // "none")"
    ' "$CATALOG_FILE"
}

# ============================================================================
# HOSTS COMMANDS
# ============================================================================

cmd_hosts() {
    local subcmd="${1:-list}"
    shift || true

    case "$subcmd" in
        list|"")
            hosts_list
            ;;
        status)
            hosts_status "$@"
            ;;
        *)
            log_error "Unknown hosts command: $subcmd"
            echo "Usage: shepard.sh hosts [list|status]"
            exit 1
            ;;
    esac
}

hosts_list() {
    log_header "Claude Code Hosts"

    db_query "SELECT name, role, note FROM hosts" | while IFS='|' read -r name role note; do
        echo -e "${BOLD}$name${NC} [$role]"
        [ -n "$note" ] && echo -e "  ${YELLOW}$note${NC}"
    done
}

hosts_status() {
    local host="${1:-}"

    log_header "Host Deployment Status"

    if [ -n "$host" ]; then
        # Show specific host
        echo -e "${BOLD}$host${NC}"
        echo

        db_query "SELECT protocol, version, pinned, pin_reason, deployed_at
                  FROM host_deployments WHERE host = '$host'" | \
        while IFS='|' read -r protocol version pinned reason deployed; do
            local pin_icon=""
            [ "$pinned" = "1" ] && pin_icon=" 📌"
            echo -e "  $protocol: ${GREEN}$version${NC}$pin_icon"
            [ "$pinned" = "1" ] && [ -n "$reason" ] && echo -e "    ${YELLOW}Pinned: $reason${NC}"
        done
    else
        # Show all hosts
        db_query "SELECT name FROM hosts" | while read -r h; do
            echo -e "${BOLD}$h${NC}"

            local deployments=$(db_query "SELECT protocol, version, pinned FROM host_deployments WHERE host = '$h'")
            if [ -z "$deployments" ]; then
                echo -e "  ${YELLOW}(no protocols deployed)${NC}"
            else
                echo "$deployments" | while IFS='|' read -r protocol version pinned; do
                    local pin_icon=""
                    [ "$pinned" = "1" ] && pin_icon=" 📌"
                    echo -e "  $protocol: ${GREEN}$version${NC}$pin_icon"
                done
            fi
            echo
        done
    fi
}

# ============================================================================
# DEPLOY COMMANDS
# ============================================================================

cmd_deploy_host() {
    local protocol="${1:-}"
    local target="${2:-}"
    local dry_run=false

    shift 2 || true

    while [ $# -gt 0 ]; do
        case "$1" in
            --dry-run) dry_run=true; shift ;;
            --infra) target="infra"; shift ;;
            *) log_error "Unknown option: $1"; exit 1 ;;
        esac
    done

    if [ -z "$protocol" ]; then
        log_error "Protocol required"
        echo "Usage: shepard.sh deploy-host <protocol> <host|--infra> [--dry-run]"
        exit 1
    fi

    # Get protocol info
    local proto_info=$(jq -r --arg p "$protocol" '.protocols[$p] // empty' "$CATALOG_FILE")
    if [ -z "$proto_info" ]; then
        log_error "Protocol not found: $protocol"
        exit 1
    fi

    local deploy_type=$(echo "$proto_info" | jq -r '.deploymentType')
    if [ "$deploy_type" != "host" ]; then
        log_error "$protocol is a project-level protocol, not host-level"
        exit 1
    fi

    local version=$(echo "$proto_info" | jq -r '.version')
    local repo=$(echo "$proto_info" | jq -r '.repo')

    # Determine target hosts
    local hosts=()
    if [ "$target" = "infra" ]; then
        hosts=("friday" "helicarrier")
    elif [ -n "$target" ]; then
        hosts=("$target")
    else
        log_error "Target host required"
        exit 1
    fi

    log_header "Deploying $protocol v$version"

    for host in "${hosts[@]}"; do
        echo -e "${BOLD}$host${NC}"

        # Check if pinned
        local pinned=$(db_query "SELECT pinned, pin_reason FROM host_deployments
                                 WHERE host = '$host' AND protocol = '$protocol'")
        if [ -n "$pinned" ]; then
            local is_pinned=$(echo "$pinned" | cut -d'|' -f1)
            local reason=$(echo "$pinned" | cut -d'|' -f2)
            if [ "$is_pinned" = "1" ]; then
                echo -e "  ${YELLOW}⚠️ SKIPPED (pinned at current version)${NC}"
                echo -e "  Reason: $reason"
                echo -e "  To upgrade anyway: shepard.sh deploy-host $protocol $host --force"
                echo -e "  To unpin: shepard.sh unpin $protocol --host $host"
                continue
            fi
        fi

        if [ "$dry_run" = true ]; then
            echo -e "  ${CYAN}[DRY RUN]${NC} Would deploy $protocol v$version"
            echo -e "  Source: $repo"
        else
            # Record deployment
            db_exec "INSERT OR REPLACE INTO host_deployments (host, protocol, version, path, deployed_at)
                     VALUES ('$host', '$protocol', '$version', '~/.claude/', datetime('now'))"

            # Record in history
            db_exec "INSERT INTO deployment_history (target_type, target, protocol, to_version, action)
                     VALUES ('host', '$host', '$protocol', '$version', 'deploy')"

            echo -e "  ${GREEN}✓${NC} Recorded deployment of $protocol v$version"
            echo -e "  ${YELLOW}Note: Actual file deployment should be done manually or via rollout${NC}"
        fi
        echo
    done
}

# ============================================================================
# DRIFT COMMANDS
# ============================================================================

cmd_drift() {
    local protocol="${1:-}"
    local host_filter=""
    local project_filter=""

    shift || true
    while [ $# -gt 0 ]; do
        case "$1" in
            --host) host_filter="$2"; shift 2 ;;
            --project) project_filter="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    log_header "Version Drift Report"

    # Get all host-level protocols
    jq -r '.protocols | to_entries[] | select(.value.deploymentType == "host") |
           "\(.key)|\(.value.version)"' "$CATALOG_FILE" | \
    while IFS='|' read -r proto source_version; do
        [ -n "$protocol" ] && [ "$proto" != "$protocol" ] && continue

        echo -e "${BOLD}$proto${NC} (source: $source_version)"

        local query="SELECT host, version, pinned, pin_reason FROM host_deployments WHERE protocol = '$proto'"
        [ -n "$host_filter" ] && query="$query AND host = '$host_filter'"

        db_query "$query" | while IFS='|' read -r host version pinned reason; do
            local status_icon="✓"
            local status_color="$GREEN"
            local extra=""

            if [ "$pinned" = "1" ]; then
                status_icon="📌"
                status_color="$YELLOW"
                extra=" pinned"
                [ -n "$reason" ] && extra="$extra ($reason)"
            elif [ "$version" != "$source_version" ]; then
                status_icon="⚠"
                status_color="$YELLOW"
                extra=" outdated"
            fi

            printf "  %-15s %s${status_color}%s${NC}%s\n" "$host:" "$version" " $status_icon" "$extra"
        done
        echo
    done
}

# ============================================================================
# DEPENDENCY COMMANDS
# ============================================================================

cmd_deps() {
    local protocol="${1:-}"
    local reverse=false

    shift || true
    [ "$1" = "--reverse" ] && reverse=true

    if [ -z "$protocol" ]; then
        log_error "Protocol required"
        echo "Usage: shepard.sh deps <protocol> [--reverse]"
        exit 1
    fi

    if [ "$reverse" = true ]; then
        log_header "What depends on $protocol"

        jq -r --arg p "$protocol" '
            .protocols | to_entries[] |
            select(.value.dependencies | index($p)) |
            "  \(.key) depends on this"
        ' "$CATALOG_FILE"
    else
        log_header "Dependencies of $protocol"

        local deps=$(jq -r --arg p "$protocol" '.protocols[$p].dependencies // [] | .[]' "$CATALOG_FILE")
        if [ -z "$deps" ]; then
            echo "  (no dependencies)"
        else
            echo "$deps" | while read -r dep; do
                local ver=$(jq -r --arg d "$dep" '.protocols[$d].version // "unknown"' "$CATALOG_FILE")
                echo "  └── $dep (v$ver)"
            done
        fi
    fi
}

# ============================================================================
# PINNING COMMANDS
# ============================================================================

cmd_pin() {
    local protocol="${1:-}"
    local host=""
    local reason=""

    shift || true
    while [ $# -gt 0 ]; do
        case "$1" in
            --host) host="$2"; shift 2 ;;
            --reason) reason="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [ -z "$protocol" ] || [ -z "$host" ]; then
        log_error "Protocol and host required"
        echo "Usage: shepard.sh pin <protocol> --host <host> --reason \"...\""
        exit 1
    fi

    db_exec "UPDATE host_deployments SET pinned = 1, pin_reason = '$reason'
             WHERE host = '$host' AND protocol = '$protocol'"

    db_exec "INSERT INTO deployment_history (target_type, target, protocol, action, performed_by)
             VALUES ('host', '$host', '$protocol', 'pin', 'user')"

    log_success "Pinned $protocol on $host"
    [ -n "$reason" ] && log_info "Reason: $reason"
}

cmd_unpin() {
    local protocol="${1:-}"
    local host=""

    shift || true
    while [ $# -gt 0 ]; do
        case "$1" in
            --host) host="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [ -z "$protocol" ] || [ -z "$host" ]; then
        log_error "Protocol and host required"
        echo "Usage: shepard.sh unpin <protocol> --host <host>"
        exit 1
    fi

    db_exec "UPDATE host_deployments SET pinned = 0, pin_reason = NULL
             WHERE host = '$host' AND protocol = '$protocol'"

    db_exec "INSERT INTO deployment_history (target_type, target, protocol, action, performed_by)
             VALUES ('host', '$host', '$protocol', 'unpin', 'user')"

    log_success "Unpinned $protocol on $host"
}

cmd_pins() {
    log_header "Pinned Deployments"

    local pins=$(db_query "SELECT * FROM pinned_deployments")
    if [ -z "$pins" ]; then
        echo "No pinned deployments"
        return
    fi

    echo "$pins" | while IFS='|' read -r type target protocol version reason deployed; do
        echo -e "${BOLD}$target${NC} ($type)"
        echo -e "  $protocol: $version"
        [ -n "$reason" ] && echo -e "  ${YELLOW}Reason: $reason${NC}"
        echo
    done
}

# ============================================================================
# HERDING COMMANDS
# ============================================================================

cmd_herd() {
    local subcmd="${1:-list}"
    shift || true

    case "$subcmd" in
        list)
            herd_list
            ;;
        new)
            herd_new "$@"
            ;;
        propose)
            herd_propose "$@"
            ;;
        process)
            herd_process "$@"
            ;;
        *)
            log_error "Unknown herd command: $subcmd"
            echo "Usage: shepard.sh herd [list|new <protocol>|propose <name>|process <file>]"
            exit 1
            ;;
    esac
}

herd_list() {
    log_header "Pending Feedback"

    local pending=$(ls -1 "$HERDING_DIR/pending/" 2>/dev/null | grep -v "^$" || true)
    if [ -z "$pending" ]; then
        echo "No pending feedback"
        return
    fi

    echo "$pending" | while read -r file; do
        echo "  📝 $file"
    done
}

herd_new() {
    local protocol="${1:-}"

    if [ -z "$protocol" ]; then
        log_error "Protocol name required"
        echo "Usage: shepard.sh herd new <protocol>"
        exit 1
    fi

    local date=$(date +%Y-%m-%d)
    local filename="${protocol}-${date}.md"
    local filepath="$HERDING_DIR/pending/$filename"

    cat > "$filepath" <<EOF
# Feedback: $protocol

**Submitted:** $date
**Source:** $(hostname)
**Protocol Version:** $(jq -r --arg p "$protocol" '.protocols[$p].version // "unknown"' "$CATALOG_FILE")

## What Worked Well

-

## What Could Be Better

-

## Suggested Changes

-

## Related Issues

-
EOF

    log_success "Created: $filepath"
    log_info "Edit this file to add your feedback"
}

herd_propose() {
    local name="${1:-}"

    if [ -z "$name" ]; then
        log_error "Protocol name required"
        echo "Usage: shepard.sh herd propose <name>"
        exit 1
    fi

    local date=$(date +%Y-%m-%d)
    local filename="new-protocol-${name}.md"
    local filepath="$HERDING_DIR/pending/$filename"

    cat > "$filepath" <<EOF
# Protocol Proposal: $name

**Proposed:** $date
**Proposer:** $(whoami)

## Problem Statement

What problem does this solve?

## Proposed Solution

How would this protocol work?

## Deployment Type

- [ ] Host-level (\`~/.claude/\`)
- [ ] Project-level (\`.claude/\`)

## Dependencies

What other protocols does this depend on?

## Implementation Notes

Technical considerations, file structure, hooks needed, etc.
EOF

    log_success "Created: $filepath"
    log_info "Edit this file to complete your proposal"
}

herd_process() {
    local file="${1:-}"

    if [ -z "$file" ]; then
        log_error "File name required"
        echo "Usage: shepard.sh herd process <filename>"
        exit 1
    fi

    local src="$HERDING_DIR/pending/$file"
    local dst="$HERDING_DIR/processed/$file"

    if [ ! -f "$src" ]; then
        log_error "File not found: $src"
        exit 1
    fi

    mv "$src" "$dst"
    log_success "Moved to processed: $file"
}

# ============================================================================
# BUNDLES COMMANDS
# ============================================================================

cmd_bundles() {
    log_header "Protocol Bundles"

    db_query "SELECT name, description, protocols FROM bundles" | \
    while IFS='|' read -r name desc protocols; do
        echo -e "${BOLD}$name${NC}"
        echo -e "  $desc"
        echo -e "  Protocols: $protocols"
        echo
    done
}

# ============================================================================
# UPGRADE COMMANDS
# ============================================================================

cmd_upgrade() {
    local protocol="${1:-}"
    local cascade=false
    local dry_run=false
    local include_pinned=false

    shift || true
    while [ $# -gt 0 ]; do
        case "$1" in
            --cascade) cascade=true; shift ;;
            --dry-run) dry_run=true; shift ;;
            --include-pinned) include_pinned=true; shift ;;
            *) shift ;;
        esac
    done

    if [ -z "$protocol" ]; then
        log_error "Protocol required"
        echo "Usage: shepard.sh upgrade <protocol> [--cascade] [--dry-run] [--include-pinned]"
        exit 1
    fi

    local source_version=$(jq -r --arg p "$protocol" '.protocols[$p].version' "$CATALOG_FILE")

    log_header "Upgrading $protocol to v$source_version"

    local upgraded=0
    local skipped=0

    db_query "SELECT host, version, pinned, pin_reason FROM host_deployments WHERE protocol = '$protocol'" | \
    while IFS='|' read -r host version pinned reason; do
        if [ "$version" = "$source_version" ]; then
            echo -e "  $host: ${GREEN}$version ✓ (current)${NC}"
            continue
        fi

        if [ "$pinned" = "1" ] && [ "$include_pinned" = false ]; then
            echo -e "  $host: ${YELLOW}⚠️ SKIPPED (pinned at $version)${NC}"
            echo -e "         Reason: \"$reason\""
            echo -e "         To upgrade anyway: shepard.sh upgrade $protocol --host $host --force"
            echo -e "         To unpin: shepard.sh unpin $protocol --host $host"
            skipped=$((skipped + 1))
            continue
        fi

        if [ "$dry_run" = true ]; then
            echo -e "  $host: ${CYAN}$version → $source_version [DRY RUN]${NC}"
        else
            db_exec "UPDATE host_deployments SET version = '$source_version', deployed_at = datetime('now')
                     WHERE host = '$host' AND protocol = '$protocol'"
            db_exec "INSERT INTO deployment_history (target_type, target, protocol, from_version, to_version, action)
                     VALUES ('host', '$host', '$protocol', '$version', '$source_version', 'upgrade')"
            echo -e "  $host: ${GREEN}$version → $source_version ✓ upgraded${NC}"
            upgraded=$((upgraded + 1))
        fi
    done

    echo
    echo "Summary: $upgraded upgraded, $skipped skipped (pinned)"
}

# ============================================================================
# PENDING COMMANDS
# ============================================================================

cmd_pending() {
    local project_filter=""
    local active_only=false
    local quiet=false

    while [ $# -gt 0 ]; do
        case "$1" in
            --project|-p) project_filter="$2"; shift 2 ;;
            --active-only|-a) active_only=true; shift ;;
            --quiet|-q) quiet=true; shift ;;
            *) shift ;;
        esac
    done

    if [ "$quiet" = false ]; then
        log_header "Pending Rollouts"
    fi

    local total_pending=0
    local projects_with_pending=0

    # Build jq filter based on options
    local jq_filter='.projects[]'
    if [ "$active_only" = true ]; then
        jq_filter="$jq_filter | select(.status == \"active\")"
    else
        jq_filter="$jq_filter | select(.status != \"archived\" and .status != \"retired\")"
    fi

    if [ -n "$project_filter" ]; then
        jq_filter="$jq_filter | select(.id == \"$project_filter\")"
    fi

    # Get projects and their pending migrations
    local output=$(jq -r "$jq_filter | \"\(.id)|\(.name)|\(.migrations // {} | to_entries | map(select(.value == \"pending\")) | map(.key) | join(\",\"))\"" "$PROJECTS_FILE")

    if [ -z "$output" ]; then
        if [ -n "$project_filter" ]; then
            log_error "Project not found: $project_filter"
        else
            echo "No projects found matching criteria"
        fi
        return 1
    fi

    # Use process substitution to avoid subshell variable scope issues
    while IFS='|' read -r id name pending_list; do
        if [ -z "$pending_list" ]; then
            if [ -n "$project_filter" ]; then
                echo -e "${GREEN}✓${NC} $name ($id): Up to date"
            fi
            continue
        fi

        projects_with_pending=$((projects_with_pending + 1))
        local count=$(echo "$pending_list" | tr ',' '\n' | wc -l)
        total_pending=$((total_pending + count))

        echo -e "${BOLD}$name${NC} ($id)"
        echo "$pending_list" | tr ',' '\n' | while read -r rollout; do
            [ -n "$rollout" ] && echo -e "  ${YELLOW}○${NC} $rollout"
        done
        echo
    done <<< "$output"

    if [ "$quiet" = false ]; then
        echo "────────────────────────────────────"
        if [ $total_pending -eq 0 ]; then
            echo -e "${GREEN}All projects up to date!${NC}"
        else
            echo -e "${YELLOW}$total_pending pending rollouts${NC} across $projects_with_pending project(s)"
            echo
            echo "To deploy: shepard.sh deploy <rollout> --project <project>"
        fi
    fi
}

# ============================================================================
# PHASE 5: SAFETY FEATURES
# ============================================================================

cmd_health() {
    local protocol="${1:-}"
    local host="${2:-}"

    if [ -z "$protocol" ]; then
        log_error "Protocol required"
        echo "Usage: shepard.sh health <protocol> [--host <host>]"
        exit 1
    fi

    # Parse options
    shift || true
    while [ $# -gt 0 ]; do
        case "$1" in
            --host|-h) host="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    # Get protocol info
    local proto_info=$(jq -r --arg p "$protocol" '.protocols[$p] // empty' "$CATALOG_FILE")
    if [ -z "$proto_info" ]; then
        log_error "Protocol not found: $protocol"
        exit 1
    fi

    local deploy_type=$(echo "$proto_info" | jq -r '.deploymentType')
    local repo=$(echo "$proto_info" | jq -r '.repo')

    log_header "Health Check: $protocol"

    # Determine hosts to check
    local hosts=()
    if [ -n "$host" ]; then
        hosts=("$host")
    elif [ "$deploy_type" = "host" ]; then
        hosts=($(db_query "SELECT name FROM hosts"))
    else
        log_error "For project-level protocols, specify --host"
        exit 1
    fi

    local healthy=0
    local unhealthy=0

    for h in "${hosts[@]}"; do
        echo -e "${BOLD}$h${NC}"

        # Check if deployed
        local deployed=$(db_query "SELECT version FROM host_deployments WHERE host = '$h' AND protocol = '$protocol'")
        if [ -z "$deployed" ]; then
            echo -e "  ${YELLOW}⚠ Not deployed${NC}"
            unhealthy=$((unhealthy + 1))
            continue
        fi

        # Check for health-check.sh in protocol repo
        local health_script="$repo/health-check.sh"
        if [ -f "$health_script" ]; then
            echo -e "  Running health check..."
            if ssh "$h" "bash -s" < "$health_script" 2>/dev/null; then
                echo -e "  ${GREEN}✓ Healthy (v$deployed)${NC}"
                healthy=$((healthy + 1))
            else
                echo -e "  ${RED}✗ Health check failed${NC}"
                unhealthy=$((unhealthy + 1))
            fi
        else
            # Basic checks
            local checks_passed=0
            local checks_total=0

            # Check protocol files exist based on type
            case "$protocol" in
                work-tracking)
                    checks_total=3
                    ssh "$h" "test -f ~/.claude/hooks/work-log.sh" 2>/dev/null && checks_passed=$((checks_passed + 1))
                    ssh "$h" "test -f ~/.claude/db/work-log.db" 2>/dev/null && checks_passed=$((checks_passed + 1))
                    ssh "$h" "test -f ~/.claude/hooks/work-log-start.sh" 2>/dev/null && checks_passed=$((checks_passed + 1))
                    ;;
                response-format)
                    checks_total=1
                    ssh "$h" "test -f ~/.claude/rules/response-format.md" 2>/dev/null && checks_passed=$((checks_passed + 1))
                    ;;
                *)
                    # Generic: just check if host is reachable
                    checks_total=1
                    ssh "$h" "echo ok" >/dev/null 2>&1 && checks_passed=$((checks_passed + 1))
                    ;;
            esac

            if [ $checks_passed -eq $checks_total ]; then
                echo -e "  ${GREEN}✓ Healthy (v$deployed) [$checks_passed/$checks_total checks]${NC}"
                healthy=$((healthy + 1))
            else
                echo -e "  ${RED}✗ Unhealthy [$checks_passed/$checks_total checks]${NC}"
                unhealthy=$((unhealthy + 1))
            fi
        fi
    done

    echo
    echo "────────────────────────────────────"
    echo -e "${GREEN}$healthy healthy${NC}, ${RED}$unhealthy unhealthy${NC}"
}

cmd_rollback() {
    local protocol="${1:-}"
    local host="${2:-}"

    if [ -z "$protocol" ]; then
        log_error "Protocol required"
        echo "Usage: shepard.sh rollback <protocol> --host <host>"
        exit 1
    fi

    shift || true
    while [ $# -gt 0 ]; do
        case "$1" in
            --host|-h) host="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [ -z "$host" ]; then
        log_error "Host required for rollback"
        echo "Usage: shepard.sh rollback <protocol> --host <host>"
        exit 1
    fi

    log_header "Rollback: $protocol on $host"

    # Get deployment history
    local history=$(db_query "SELECT to_version, from_version, performed_at FROM deployment_history
                              WHERE target = '$host' AND protocol = '$protocol'
                              ORDER BY performed_at DESC LIMIT 5")

    if [ -z "$history" ]; then
        log_error "No deployment history found for $protocol on $host"
        exit 1
    fi

    echo "Recent deployments:"
    echo "$history" | while IFS='|' read -r to_ver from_ver when; do
        echo "  $when: ${from_ver:-initial} → $to_ver"
    done
    echo

    # Get previous version
    local prev_version=$(db_query "SELECT from_version FROM deployment_history
                                   WHERE target = '$host' AND protocol = '$protocol'
                                   AND action IN ('deploy', 'upgrade')
                                   ORDER BY performed_at DESC LIMIT 1")

    if [ -z "$prev_version" ] || [ "$prev_version" = "" ]; then
        log_error "No previous version to rollback to"
        exit 1
    fi

    echo -e "${YELLOW}Would rollback to: $prev_version${NC}"
    echo
    echo "To confirm rollback, run:"
    echo "  shepard.sh rollback $protocol --host $host --confirm"
    echo
    log_warning "Rollback requires manual file restoration from backup"
}

cmd_conflicts() {
    local protocol1="${1:-}"
    local protocol2="${2:-}"

    if [ -z "$protocol1" ] || [ -z "$protocol2" ]; then
        log_error "Two protocols required"
        echo "Usage: shepard.sh conflicts <protocol1> <protocol2>"
        exit 1
    fi

    log_header "Conflict Check: $protocol1 vs $protocol2"

    # Get protocol info
    local p1_info=$(jq -r --arg p "$protocol1" '.protocols[$p] // empty' "$CATALOG_FILE")
    local p2_info=$(jq -r --arg p "$protocol2" '.protocols[$p] // empty' "$CATALOG_FILE")

    if [ -z "$p1_info" ]; then
        log_error "Protocol not found: $protocol1"
        exit 1
    fi
    if [ -z "$p2_info" ]; then
        log_error "Protocol not found: $protocol2"
        exit 1
    fi

    local conflicts=0

    # Check hooks overlap
    echo "Checking hook overlap..."
    local p1_hooks=$(echo "$p1_info" | jq -r '.hooks[]?' 2>/dev/null)
    local p2_hooks=$(echo "$p2_info" | jq -r '.hooks[]?' 2>/dev/null)

    for hook in $p1_hooks; do
        if echo "$p2_hooks" | grep -q "^$hook$"; then
            echo -e "  ${YELLOW}⚠ Both use hook: $hook${NC}"
            conflicts=$((conflicts + 1))
        fi
    done

    # Check deployment type compatibility
    echo "Checking deployment types..."
    local p1_type=$(echo "$p1_info" | jq -r '.deploymentType')
    local p2_type=$(echo "$p2_info" | jq -r '.deploymentType')

    if [ "$p1_type" = "$p2_type" ]; then
        echo -e "  ${GREEN}✓ Same deployment type ($p1_type)${NC}"
    else
        echo -e "  ${CYAN}ℹ Different types: $p1_type vs $p2_type${NC}"
    fi

    # Check dependency conflicts
    echo "Checking dependencies..."
    local p1_deps=$(echo "$p1_info" | jq -r '.dependencies[]?' 2>/dev/null)
    local p2_deps=$(echo "$p2_info" | jq -r '.dependencies[]?' 2>/dev/null)

    # Check if one depends on the other
    if echo "$p1_deps" | grep -q "^$protocol2$"; then
        echo -e "  ${CYAN}ℹ $protocol1 depends on $protocol2${NC}"
    fi
    if echo "$p2_deps" | grep -q "^$protocol1$"; then
        echo -e "  ${CYAN}ℹ $protocol2 depends on $protocol1${NC}"
    fi

    echo
    echo "────────────────────────────────────"
    if [ $conflicts -eq 0 ]; then
        echo -e "${GREEN}No conflicts detected${NC}"
    else
        echo -e "${YELLOW}$conflicts potential conflict(s) found${NC}"
    fi
}

# ============================================================================
# PHASE 6: ADVANCED FEATURES
# ============================================================================

cmd_impact() {
    local protocol="${1:-}"

    if [ -z "$protocol" ]; then
        log_error "Protocol required"
        echo "Usage: shepard.sh impact <protocol>"
        exit 1
    fi

    log_header "Impact Analysis: $protocol"

    # Get protocol info
    local proto_info=$(jq -r --arg p "$protocol" '.protocols[$p] // empty' "$CATALOG_FILE")
    if [ -z "$proto_info" ]; then
        log_error "Protocol not found: $protocol"
        exit 1
    fi

    local version=$(echo "$proto_info" | jq -r '.version')
    local repo=$(echo "$proto_info" | jq -r '.repo')

    echo "Protocol: $protocol v$version"
    echo "Source: $repo"
    echo

    # Show what depends on this protocol
    echo "Reverse dependencies (what depends on this):"
    local dependents=$(jq -r --arg p "$protocol" '
        .protocols | to_entries[]
        | select(.value.dependencies[]? == $p)
        | "  \(.key)"
    ' "$CATALOG_FILE")

    if [ -n "$dependents" ]; then
        echo "$dependents"
    else
        echo "  (none)"
    fi
    echo

    # Show deployments
    echo "Current deployments:"
    db_query "SELECT host, version FROM host_deployments WHERE protocol = '$protocol'" | while IFS='|' read -r host ver; do
        echo "  $host: v$ver"
    done

    local project_deps=$(db_query "SELECT project, version FROM project_deployments WHERE protocol = '$protocol'")
    if [ -n "$project_deps" ]; then
        echo "$project_deps" | while IFS='|' read -r proj ver; do
            echo "  $proj: v$ver"
        done
    fi

    echo
    echo -e "${CYAN}ℹ Graph integration not yet available${NC}"
    echo "  For full impact analysis, graph protocol is required."
    echo "  See: catalog.json → graph (status: planned)"
}

cmd_deploy_bundle() {
    local bundle="${1:-}"
    local target="${2:-}"
    local target_type=""
    local dry_run=false

    if [ -z "$bundle" ]; then
        log_error "Bundle required"
        echo "Usage: shepard.sh deploy-bundle <bundle> --project <project> [--dry-run]"
        exit 1
    fi

    shift || true
    while [ $# -gt 0 ]; do
        case "$1" in
            --project|-p) target="$2"; target_type="project"; shift 2 ;;
            --host|-h) target="$2"; target_type="host"; shift 2 ;;
            --dry-run) dry_run=true; shift ;;
            *) shift ;;
        esac
    done

    if [ -z "$target" ]; then
        log_error "Target required (--project or --host)"
        exit 1
    fi

    # Get bundle from database
    local bundle_info=$(db_query "SELECT protocols FROM bundles WHERE name = '$bundle'")
    if [ -z "$bundle_info" ]; then
        log_error "Bundle not found: $bundle"
        echo "Available bundles:"
        db_query "SELECT name, description FROM bundles" | while IFS='|' read -r name desc; do
            echo "  $name - $desc"
        done
        exit 1
    fi

    log_header "Deploy Bundle: $bundle → $target"

    # Parse protocols from JSON array
    local protocols=$(echo "$bundle_info" | jq -r '.[]' 2>/dev/null || echo "$bundle_info" | tr ',' '\n' | tr -d '[]"')

    echo "Protocols in bundle:"
    for protocol in $protocols; do
        protocol=$(echo "$protocol" | tr -d ' ')
        [ -z "$protocol" ] && continue

        local version=$(jq -r --arg p "$protocol" '.protocols[$p].version // "unknown"' "$CATALOG_FILE")
        echo "  - $protocol v$version"
    done
    echo

    if [ "$dry_run" = true ]; then
        echo -e "${CYAN}[DRY RUN] Would deploy the above protocols to $target${NC}"
    else
        echo "Deploying..."
        for protocol in $protocols; do
            protocol=$(echo "$protocol" | tr -d ' ')
            [ -z "$protocol" ] && continue

            if [ "$target_type" = "host" ]; then
                echo -e "  Deploying $protocol to $target..."
                # Record deployment
                local version=$(jq -r --arg p "$protocol" '.protocols[$p].version' "$CATALOG_FILE")
                db_exec "INSERT OR REPLACE INTO host_deployments (host, protocol, version, path, deployed_at)
                         VALUES ('$target', '$protocol', '$version', '~/.claude/', datetime('now'))"
                db_exec "INSERT INTO deployment_history (target_type, target, protocol, to_version, action)
                         VALUES ('host', '$target', '$protocol', '$version', 'deploy')"
                echo -e "    ${GREEN}✓ Recorded${NC}"
            else
                echo -e "  Deploying $protocol to project $target..."
                local version=$(jq -r --arg p "$protocol" '.protocols[$p].version' "$CATALOG_FILE")
                db_exec "INSERT OR REPLACE INTO project_deployments (project, protocol, version, deployed_at)
                         VALUES ('$target', '$protocol', '$version', datetime('now'))"
                db_exec "INSERT INTO deployment_history (target_type, target, protocol, to_version, action)
                         VALUES ('project', '$target', '$protocol', '$version', 'deploy')"
                echo -e "    ${GREEN}✓ Recorded${NC}"
            fi
        done

        echo
        log_success "Bundle deployed"
        log_warning "Note: Actual file deployment should be done manually or via rollout"
    fi
}

cmd_changelog() {
    local protocol="${1:-}"
    local range="${2:-}"

    if [ -z "$protocol" ]; then
        log_error "Protocol required"
        echo "Usage: shepard.sh changelog <protocol> [from..to]"
        echo "Example: shepard.sh changelog work-tracking 1.0.0..1.1.0"
        exit 1
    fi

    # Get protocol repo
    local repo=$(jq -r --arg p "$protocol" '.protocols[$p].repo // empty' "$CATALOG_FILE")
    if [ -z "$repo" ]; then
        log_error "Protocol not found: $protocol"
        exit 1
    fi

    log_header "Changelog: $protocol"

    if [ ! -d "$repo/.git" ]; then
        log_warning "Not a git repository: $repo"
        echo "Cannot generate changelog without git history"
        exit 1
    fi

    cd "$repo"

    if [ -n "$range" ]; then
        echo "Changes in $range:"
        echo
        git log --oneline --no-merges "$range" 2>/dev/null || {
            log_error "Invalid range: $range"
            echo "Use format: v1.0.0..v1.1.0 or commit..commit"
            exit 1
        }
    else
        echo "Recent changes:"
        echo
        git log --oneline --no-merges -20
    fi

    echo
    echo "────────────────────────────────────"
    echo "Full changelog: git log $repo"
}

# ============================================================================
# HELP
# ============================================================================

show_help() {
    local topic="${1:-}"

    case "$topic" in
        catalog)
            cat <<EOF
Catalog Commands - Protocol inventory management

Usage: shepard.sh catalog [list|show <protocol>]

  list              List all protocols in catalog
  show <protocol>   Show details for specific protocol

Examples:
  shepard.sh catalog
  shepard.sh catalog show work-tracking
EOF
            ;;
        hosts)
            cat <<EOF
Hosts Commands - Claude Code host management

Usage: shepard.sh hosts [list|status [<host>]]

  list              List all Claude Code hosts
  status            Show deployment status for all hosts
  status <host>     Show deployment status for specific host

Examples:
  shepard.sh hosts
  shepard.sh hosts status
  shepard.sh hosts status friday
EOF
            ;;
        herd)
            cat <<EOF
Herding Commands - Protocol feedback collection

Usage: shepard.sh herd [list|new <protocol>|propose <name>|process <file>]

  list              List pending feedback
  new <protocol>    Create feedback file for protocol
  propose <name>    Propose a new protocol
  process <file>    Move feedback to processed

Examples:
  shepard.sh herd list
  shepard.sh herd new work-tracking
  shepard.sh herd propose my-new-protocol
EOF
            ;;
        deploy)
            cat <<EOF
Deploy Commands - Protocol deployment

Usage: shepard.sh deploy-host <protocol> <host|--infra> [--dry-run]

Options:
  --infra           Deploy to friday + helicarrier
  --dry-run         Preview without making changes

Examples:
  shepard.sh deploy-host work-tracking friday
  shepard.sh deploy-host work-tracking --infra
  shepard.sh deploy-host work-tracking stark --dry-run
EOF
            ;;
        *)
            cat <<EOF
Shepherd - Protocol Lifecycle Management System v2.0.0

Usage: shepard.sh <command> [options]

Commands:
  ${BOLD}Inventory${NC}
    catalog [list|show]         Protocol catalog management
    hosts [list|status]         Claude Code host management
    bundles                     List protocol bundles

  ${BOLD}Deployment${NC}
    deploy-host <p> <host>      Deploy host-level protocol
    deploy-bundle <b> --project Deploy protocol bundle
    drift [protocol]            Version drift detection
    upgrade <protocol>          Upgrade protocol across hosts
    pending [--project <p>]     Show pending rollouts for projects

  ${BOLD}Safety${NC}
    health <protocol> [--host]  Verify deployment health
    rollback <p> --host <h>     Show rollback options
    conflicts <p1> <p2>         Check hook/dependency conflicts

  ${BOLD}Analysis${NC}
    deps <protocol>             Show dependency tree
    deps <protocol> --reverse   Show what depends on this
    impact <protocol>           Impact analysis (graph-enhanced)
    changelog <p> [from..to]    Generate changelog from git

  ${BOLD}Pinning${NC}
    pin <p> --host <h>          Pin protocol to current version
    unpin <p> --host <h>        Remove pin
    pins                        List all pins

  ${BOLD}Feedback${NC}
    herd [list|new|propose]     Protocol feedback collection

  ${BOLD}Legacy Rollouts${NC}
    list                        List available rollouts
    projects                    List projects
    status [migration]          Show migration status

Use 'shepard.sh help <command>' for detailed help.

Examples:
  shepard.sh catalog
  shepard.sh hosts status
  shepard.sh health work-tracking
  shepard.sh conflicts baton work-tracking
  shepard.sh impact shepherd
EOF
            ;;
    esac
}

# ============================================================================
# LEGACY ROLLOUT COMMANDS (preserved from v1)
# ============================================================================

cmd_list_migrations() {
    log_header "Available Rollouts"

    for dir in "$ROLLOUTS_DIR"/*/; do
        if [ -d "$dir" ]; then
            local name=$(basename "$dir")
            local readme="$dir/README.md"

            echo -e "${BOLD}$name${NC}"
            if [ -f "$readme" ]; then
                head -n 1 "$readme" | sed 's/^# /  /'
            fi
            echo
        fi
    done
}

cmd_list_projects() {
    local filter_type="${1:-all}"
    local filter_priority="${2:-all}"

    log_header "Projects"

    jq -r --arg type "$filter_type" --arg priority "$filter_priority" '
        .projects[]
        | select(
            ($type == "all" or .type == $type) and
            ($priority == "all" or .priority == $priority) and
            .status != "archived"
        )
        | "  \(.id) - \(.name) [\(.type)/\(.priority)]"
    ' "$PROJECTS_FILE"
}

cmd_status() {
    local migration="${1:-all}"

    log_header "Migration Status"

    if [ "$migration" = "all" ]; then
        jq -r '
            .projects[]
            | select(.status != "archived")
            | "\n\(.name) (\(.id)):\n" + (
                .migrations // {}
                | to_entries[]
                | "  \(.key): \(.value)"
            )
        ' "$PROJECTS_FILE"
    else
        jq -r --arg mig "$migration" '
            .projects[]
            | select(.status != "archived")
            | "\(.name) (\(.id)): \(.migrations[$mig] // "pending")"
        ' "$PROJECTS_FILE"
    fi
}

# ============================================================================
# MAIN DISPATCHER
# ============================================================================

main() {
    check_requirements

    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    local command="$1"
    shift

    case "$command" in
        # New v2 commands
        catalog)      cmd_catalog "$@" ;;
        hosts)        cmd_hosts "$@" ;;
        deploy-host)  cmd_deploy_host "$@" ;;
        drift)        cmd_drift "$@" ;;
        deps)         cmd_deps "$@" ;;
        pin)          cmd_pin "$@" ;;
        unpin)        cmd_unpin "$@" ;;
        pins)         cmd_pins "$@" ;;
        herd)         cmd_herd "$@" ;;
        bundles)      cmd_bundles "$@" ;;
        upgrade)      cmd_upgrade "$@" ;;
        pending)      cmd_pending "$@" ;;
        help)         show_help "$@" ;;

        # Phase 5: Safety Features
        health)       cmd_health "$@" ;;
        rollback)     cmd_rollback "$@" ;;
        conflicts)    cmd_conflicts "$@" ;;

        # Phase 6: Advanced Features
        impact)       cmd_impact "$@" ;;
        deploy-bundle) cmd_deploy_bundle "$@" ;;
        canary)       cmd_canary "$@" ;;
        methodology)  cmd_methodology "$@" ;;
        changelog)    cmd_changelog "$@" ;;

        # Legacy v1 commands
        list)         cmd_list_migrations ;;
        projects)     cmd_list_projects "$@" ;;
        status)       cmd_status "$@" ;;

        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"

# ============================================================================
# CANARY COMMANDS (v2)
# ============================================================================

cmd_canary() {
    local subcmd="${1:-status}"
    shift || true

    case "$subcmd" in
        start)
            canary_start "$@"
            ;;
        status)
            canary_status "$@"
            ;;
        promote)
            canary_promote "$@"
            ;;
        abort)
            canary_abort "$@"
            ;;
        *)
            log_error "Unknown canary command: $subcmd"
            echo "Usage: shepard.sh canary [start|status|promote|abort]"
            exit 1
            ;;
    esac
}

canary_start() {
    local protocol=""
    local project=""
    local version=""
    local notes=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --protocol|-p) protocol="$2"; shift 2 ;;
            --project) project="$2"; shift 2 ;;
            --version|-v) version="$2"; shift 2 ;;
            --notes|-n) notes="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [ -z "$protocol" ] || [ -z "$project" ]; then
        log_error "Protocol and project required"
        echo "Usage: shepard.sh canary start --protocol <p> --project <proj> [--version <v>] [--notes \"...\"]"
        exit 1
    fi

    # Get version from catalog if not specified
    if [ -z "$version" ]; then
        version=$(jq -r --arg p "$protocol" '.protocols[$p].version // "unknown"' "$CATALOG_FILE")
    fi

    local today=$(date +%Y-%m-%d)
    local rollout_date=$(date -d "+7 days" +%Y-%m-%d 2>/dev/null || date -v+7d +%Y-%m-%d)

    # Get all other active projects for pending list
    local pending=$(jq -r --arg proj "$project" '.projects[] | select(.status == "active" and .id != $proj) | .id' "$PROJECTS_FILE" | tr '\n' ',' | sed 's/,$//')

    log_header "Starting Canary: $protocol v$version"
    echo "Canary project: $project"
    echo "Expected rollout: $rollout_date"
    echo "Pending projects: $pending"
    [ -n "$notes" ] && echo "Notes: $notes"
    echo

    # Add to projects.json canaries array
    local canary_entry=$(cat <<EOF
{
  "protocol": "$protocol",
  "version": "$version",
  "canary_project": "$project",
  "started": "$today",
  "expected_rollout": "$rollout_date",
  "status": "testing",
  "pending_projects": [$(echo "$pending" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')],
  "notes": "$notes"
}
EOF
)

    # Check if canaries array exists
    local has_canaries=$(jq 'has("canaries")' "$PROJECTS_FILE")
    if [ "$has_canaries" = "false" ]; then
        jq --argjson c "$canary_entry" '. + {canaries: [$c]}' "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp" && mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"
    else
        jq --argjson c "$canary_entry" '.canaries += [$c]' "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp" && mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"
    fi

    log_success "Canary started"
    log_info "Deploy $protocol v$version to $project, then monitor for 7 days"
    log_info "To check status: shepard.sh canary status"
    log_info "To promote: shepard.sh canary promote --protocol $protocol"
}

canary_status() {
    log_header "Active Canaries"

    local canaries=$(jq -r '.canaries // [] | .[] | select(.status == "testing")' "$PROJECTS_FILE" 2>/dev/null)
    
    if [ -z "$canaries" ] || [ "$canaries" = "" ]; then
        echo "No active canaries"
        return
    fi

    jq -r '.canaries // [] | .[] | select(.status == "testing") |
        "Protocol: \(.protocol) v\(.version)",
        "  Canary: \(.canary_project)",
        "  Started: \(.started)",
        "  Rollout: \(.expected_rollout)",
        "  Pending: \(.pending_projects | join(\", \"))",
        (if .notes != "" then "  Notes: \(.notes)" else empty end),
        ""
    ' "$PROJECTS_FILE"

    # Check for stale canaries
    local today=$(date +%Y-%m-%d)
    jq -r --arg today "$today" '.canaries // [] | .[] | select(.status == "testing" and .expected_rollout < $today) |
        "⚠️  STALE: \(.protocol) v\(.version) - expected rollout was \(.expected_rollout)"
    ' "$PROJECTS_FILE"
}

canary_promote() {
    local protocol=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --protocol|-p) protocol="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [ -z "$protocol" ]; then
        log_error "Protocol required"
        echo "Usage: shepard.sh canary promote --protocol <p>"
        exit 1
    fi

    # Find the canary
    local canary=$(jq -r --arg p "$protocol" '.canaries // [] | .[] | select(.protocol == $p and .status == "testing")' "$PROJECTS_FILE")
    
    if [ -z "$canary" ] || [ "$canary" = "" ]; then
        log_error "No active canary found for $protocol"
        exit 1
    fi

    local version=$(echo "$canary" | jq -r '.version')
    local pending=$(echo "$canary" | jq -r '.pending_projects | join(", ")')

    log_header "Promoting Canary: $protocol v$version"
    echo "Ready to deploy to: $pending"
    echo

    # Update canary status
    jq --arg p "$protocol" '(.canaries[] | select(.protocol == $p and .status == "testing")).status = "promoted"' "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp" && mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"

    log_success "Canary marked as promoted"
    log_info "Now deploy $protocol v$version to the pending projects:"
    echo "$pending" | tr ',' '\n' | while read -r proj; do
        proj=$(echo "$proj" | tr -d ' ')
        [ -n "$proj" ] && echo "  shepard.sh upgrade $protocol --project $proj"
    done
}

canary_abort() {
    local protocol=""
    local reason=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --protocol|-p) protocol="$2"; shift 2 ;;
            --reason|-r) reason="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [ -z "$protocol" ]; then
        log_error "Protocol required"
        echo "Usage: shepard.sh canary abort --protocol <p> [--reason \"...\"]"
        exit 1
    fi

    log_header "Aborting Canary: $protocol"

    # Update canary status
    jq --arg p "$protocol" --arg r "$reason" '(.canaries[] | select(.protocol == $p and .status == "testing")) |= . + {status: "aborted", abort_reason: $r}' "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp" && mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"

    log_success "Canary aborted"
    [ -n "$reason" ] && log_info "Reason: $reason"
    log_warning "Consider reverting the canary project to previous version"
}

# ============================================================================
# METHODOLOGY COMMANDS (v2)
# ============================================================================

cmd_methodology() {
    local subcmd="${1:-list}"
    shift || true

    case "$subcmd" in
        list)
            methodology_list
            ;;
        detect)
            methodology_detect "$@"
            ;;
        set)
            methodology_set "$@"
            ;;
        *)
            log_error "Unknown methodology command: $subcmd"
            echo "Usage: shepard.sh methodology [list|detect|set]"
            exit 1
            ;;
    esac
}

methodology_list() {
    log_header "Project Methodologies"

    jq -r '.projects[] | select(.status == "active") |
        "\(.name) (\(.id)): \(.methodology.type // "none")" +
        (if .methodology.version then " v\(.methodology.version)" else "" end) +
        (if .methodology.commands then " [\(.methodology.commands | join(\", \"))]" else "" end)
    ' "$PROJECTS_FILE"
}

methodology_detect() {
    local project="${1:-}"

    if [ -z "$project" ]; then
        log_error "Project required"
        echo "Usage: shepard.sh methodology detect <project>"
        exit 1
    fi

    # Get project path and host
    local proj_info=$(jq -r --arg p "$project" '.projects[] | select(.id == $p) | "\(.path)|\(.host)"' "$PROJECTS_FILE")
    if [ -z "$proj_info" ]; then
        log_error "Project not found: $project"
        exit 1
    fi

    local path=$(echo "$proj_info" | cut -d'|' -f1)
    local host=$(echo "$proj_info" | cut -d'|' -f2)

    log_header "Detecting Methodology: $project"
    echo "Path: $path"
    echo "Host: $host"
    echo

    local methodology="none"

    # Check for _bmad directory (lowercase, case-sensitive)
    if ssh "$host" "test -d '$path/_bmad'" 2>/dev/null; then
        methodology="bmad"
        log_success "Detected: BMAD (_bmad directory found)"
    # Check for design-os markers
    elif ssh "$host" "test -f '$path/.claude/skills/wf/SKILL.md' && grep -q 'design-os\|Design OS' '$path/.claude/skills/wf/SKILL.md'" 2>/dev/null; then
        methodology="design-os"
        log_success "Detected: Design OS (wf skill found)"
    # Check for agent-os markers
    elif ssh "$host" "test -d '$path/_agent-os' || test -f '$path/.agent-os.json'" 2>/dev/null; then
        methodology="agent-os"
        log_success "Detected: Agent OS"
    else
        log_info "No formal methodology detected"
    fi

    echo
    echo "Detected: $methodology"
    echo
    echo "To set: shepard.sh methodology set $project $methodology"
}

methodology_set() {
    local project="${1:-}"
    local methodology="${2:-}"

    if [ -z "$project" ] || [ -z "$methodology" ]; then
        log_error "Project and methodology required"
        echo "Usage: shepard.sh methodology set <project> <bmad|design-os|agent-os|custom|none>"
        exit 1
    fi

    # Validate methodology type
    case "$methodology" in
        bmad|design-os|agent-os|custom|none) ;;
        *) log_error "Invalid methodology: $methodology"; exit 1 ;;
    esac

    # Update projects.json
    jq --arg p "$project" --arg m "$methodology" '
        (.projects[] | select(.id == $p)) |= . + {methodology: {type: $m}}
    ' "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp" && mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"

    log_success "Set methodology for $project: $methodology"
}
