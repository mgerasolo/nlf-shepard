#!/bin/bash
#
# ShepardProtocol New Project Setup
# Interactive rollout selector for new NLF projects
#
set -euo pipefail

SHEPARD_DIR="/mnt/foundry_project/AppServices/ShepardProtocol"
ROLLOUTS_DIR="$SHEPARD_DIR/rollouts-active"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Track selected rollouts
declare -A SELECTED

print_header() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           ShepardProtocol - New Project Setup                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_rollout_info() {
    local rollout="$1"
    local readme="$ROLLOUTS_DIR/$rollout/README.md"

    if [[ -f "$readme" ]]; then
        # Extract first paragraph (description)
        head -10 "$readme" | grep -v "^#" | grep -v "^$" | head -3
    else
        echo "No description available"
    fi
}

list_rollouts() {
    local i=1
    echo -e "${BOLD}Available Rollouts:${NC}\n"

    for dir in "$ROLLOUTS_DIR"/*/; do
        local rollout=$(basename "$dir")
        [[ "$rollout" == "_ROLLOUT_TEMPLATE" ]] && continue

        local status="${SELECTED[$rollout]:-}"
        local marker=" "
        local color=""

        if [[ "$status" == "selected" ]]; then
            marker="✓"
            color="${GREEN}"
        fi

        echo -e "${color}  ${marker} ${BOLD}[$i]${NC}${color} $rollout${NC}"

        # Show brief description
        local readme="$ROLLOUTS_DIR/$rollout/README.md"
        if [[ -f "$readme" ]]; then
            local desc=$(head -5 "$readme" | grep -v "^#" | grep -v "^$" | head -1 | cut -c1-60)
            [[ -n "$desc" ]] && echo -e "      ${CYAN}$desc${NC}"
        fi
        echo
        ((i++))
    done
}

get_rollout_by_number() {
    local num="$1"
    local i=1

    for dir in "$ROLLOUTS_DIR"/*/; do
        local rollout=$(basename "$dir")
        [[ "$rollout" == "_ROLLOUT_TEMPLATE" ]] && continue

        if [[ "$i" -eq "$num" ]]; then
            echo "$rollout"
            return
        fi
        ((i++))
    done
}

count_rollouts() {
    local count=0
    for dir in "$ROLLOUTS_DIR"/*/; do
        local rollout=$(basename "$dir")
        [[ "$rollout" == "_ROLLOUT_TEMPLATE" ]] && continue
        ((count++))
    done
    echo "$count"
}

toggle_rollout() {
    local rollout="$1"
    if [[ "${SELECTED[$rollout]:-}" == "selected" ]]; then
        unset SELECTED[$rollout]
    else
        SELECTED[$rollout]="selected"
    fi
}

select_recommended() {
    # Recommended rollouts for new projects
    SELECTED["mcp-gateway-config"]="selected"
    SELECTED["AIAssistedDevSystem"]="selected"
    SELECTED["Worktree"]="selected"
    SELECTED["ImageGeneration"]="selected"
}

select_all() {
    for dir in "$ROLLOUTS_DIR"/*/; do
        local rollout=$(basename "$dir")
        [[ "$rollout" == "_ROLLOUT_TEMPLATE" ]] && continue
        SELECTED[$rollout]="selected"
    done
}

clear_all() {
    SELECTED=()
}

show_selected() {
    echo -e "\n${BOLD}Selected Rollouts:${NC}"
    local count=0
    for rollout in "${!SELECTED[@]}"; do
        echo -e "  ${GREEN}✓${NC} $rollout"
        ((count++))
    done

    if [[ "$count" -eq 0 ]]; then
        echo -e "  ${YELLOW}(none selected)${NC}"
    fi
}

generate_commands() {
    local project_path="$1"

    echo -e "\n${BOLD}${CYAN}Generated Setup Commands:${NC}\n"
    echo "# Run these commands to apply selected rollouts"
    echo "cd $project_path"
    echo

    for rollout in "${!SELECTED[@]}"; do
        local prompt_file="$ROLLOUTS_DIR/$rollout/PROMPT_FOR_AI.md"
        if [[ -f "$prompt_file" ]]; then
            echo "# === $rollout ==="
            echo "# Review: cat $prompt_file"
            echo "# Verify: bash $ROLLOUTS_DIR/$rollout/verify-migration.sh 2>/dev/null || true"
            echo
        fi
    done

    echo -e "${YELLOW}Note: Copy the PROMPT_FOR_AI.md content to Claude Code for each rollout${NC}"
}

show_prompt_content() {
    local rollout="$1"
    local prompt_file="$ROLLOUTS_DIR/$rollout/PROMPT_FOR_AI.md"

    if [[ -f "$prompt_file" ]]; then
        echo -e "\n${BOLD}${CYAN}=== $rollout PROMPT_FOR_AI.md ===${NC}\n"
        cat "$prompt_file"
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read -r
    else
        echo -e "${RED}No PROMPT_FOR_AI.md found for $rollout${NC}"
    fi
}

interactive_menu() {
    local total=$(count_rollouts)

    while true; do
        print_header
        list_rollouts
        show_selected

        echo -e "\n${BOLD}Options:${NC}"
        echo -e "  ${CYAN}1-$total${NC}  Toggle rollout selection"
        echo -e "  ${CYAN}r${NC}      Select recommended (mcp-gateway, baton, worktree, imagegen)"
        echo -e "  ${CYAN}a${NC}      Select all"
        echo -e "  ${CYAN}c${NC}      Clear all selections"
        echo -e "  ${CYAN}v${NC}      View a rollout's PROMPT_FOR_AI.md"
        echo -e "  ${CYAN}g${NC}      Generate setup commands"
        echo -e "  ${CYAN}q${NC}      Quit"
        echo
        read -rp "Enter choice: " choice

        case "$choice" in
            [1-9]|[1-9][0-9])
                local rollout=$(get_rollout_by_number "$choice")
                if [[ -n "$rollout" ]]; then
                    toggle_rollout "$rollout"
                fi
                ;;
            r|R)
                select_recommended
                ;;
            a|A)
                select_all
                ;;
            c|C)
                clear_all
                ;;
            v|V)
                echo -e "\n${BOLD}Enter rollout number to view:${NC}"
                read -rp "> " view_num
                local view_rollout=$(get_rollout_by_number "$view_num")
                if [[ -n "$view_rollout" ]]; then
                    show_prompt_content "$view_rollout"
                fi
                ;;
            g|G)
                echo -e "\n${BOLD}Enter project path:${NC}"
                read -rp "> " project_path
                if [[ -d "$project_path" ]]; then
                    generate_commands "$project_path"
                    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
                    read -r
                else
                    echo -e "${RED}Directory not found: $project_path${NC}"
                    sleep 2
                fi
                ;;
            q|Q)
                echo -e "\n${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                sleep 1
                ;;
        esac
    done
}

# Quick mode - just list rollouts
quick_list() {
    echo -e "${BOLD}Available ShepardProtocol Rollouts:${NC}\n"

    for dir in "$ROLLOUTS_DIR"/*/; do
        local rollout=$(basename "$dir")
        [[ "$rollout" == "_ROLLOUT_TEMPLATE" ]] && continue

        echo -e "${GREEN}•${NC} ${BOLD}$rollout${NC}"

        local readme="$ROLLOUTS_DIR/$rollout/README.md"
        if [[ -f "$readme" ]]; then
            local desc=$(head -5 "$readme" | grep -v "^#" | grep -v "^$" | head -1 | cut -c1-70)
            [[ -n "$desc" ]] && echo -e "  ${CYAN}$desc${NC}"
        fi
    done

    echo -e "\n${YELLOW}Run with --interactive for full menu${NC}"
}

# Main
case "${1:-}" in
    --list|-l)
        quick_list
        ;;
    --interactive|-i|"")
        interactive_menu
        ;;
    --help|-h)
        echo "ShepardProtocol New Project Setup"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --interactive, -i   Interactive rollout selector (default)"
        echo "  --list, -l          Quick list of available rollouts"
        echo "  --help, -h          Show this help"
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage"
        exit 1
        ;;
esac
