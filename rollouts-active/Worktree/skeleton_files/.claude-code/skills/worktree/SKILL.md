---
name: worktree
description: Manage git worktrees with structured workflow lifecycle. Includes phases for development, testing, review, deployment, and human verification. Triggers on "/worktree".
---

# Worktree - Parallel Work Management

Manages git worktrees with integrated baton context and a structured workflow lifecycle for isolated parallel work streams.

## Workflow Lifecycle

Every worktree progresses through these phases:

```
┌─────────┐   ┌────────────┐   ┌─────────┐   ┌────────┐   ┌───────────┐   ┌──────────────┐   ┌───────────┐
│ created │ → │ developing │ → │ testing │ → │ review │ → │ deploying │ → │ human-testing│ → │ completed │
└─────────┘   └────────────┘   └─────────┘   └────────┘   └───────────┘   └──────────────┘   └───────────┘
```

| Phase | Description | Next Command |
|-------|-------------|--------------|
| `created` | Worktree just created, work starting | (begin development) |
| `developing` | Active development in progress | `/worktree test write` |
| `testing` | Tests being written and run | `/worktree test run` |
| `review` | PR created, awaiting code review | `/worktree deploy` |
| `deploying` | Being deployed to staging/prod | `/worktree verify` |
| `human-testing` | Deployed, awaiting human verification | `/worktree complete` |
| `completed` | Verified and ready for cleanup | `/worktree delete` |

**Phase tracked in:** `.claude/worktrees/{worktree-name}/state.json`

## Auto-Detection (First Message Behavior)

**When to trigger automatically:**
- User starts a new conversation with a task description
- Project has `.claude/` directory (baton enabled)
- User is in a git repository
- The task involves code changes

**On first message, Claude should:**

1. **Summarize the task** in 1-2 sentences
2. **Propose a worktree name** (kebab-case, 2-4 words, descriptive)
3. **Ask user to confirm** or suggest alternative name
4. **Create worktree** and initialize baton
5. **Begin work** in the new worktree

**Example flow:**

```
User: "I need to fix the order validation logic - it's not checking for minimum quantities"

Claude: I'll fix the order validation to check minimum quantities.

Proposed worktree: `fix-order-min-quantity`

Creating worktree and starting work...

[Creates worktree, initializes baton, begins implementation]
```

**Naming conventions:**
- `fix-<thing>` for bug fixes
- `feat-<thing>` for new features
- `refactor-<thing>` for refactoring
- `update-<thing>` for updates/changes
- Max 30 chars, kebab-case

**Skip auto-detection if:**
- User explicitly says "in this directory" or "here"
- User is asking questions (not requesting changes)
- Already in a worktree (not main branch)
- Task is trivial (< 5 minutes of work)

---

## Why Worktrees?

When running multiple Claude conversations on the same project:
- Each conversation may modify the same files
- Commits from one conversation affect others
- Context gets confused across conversations

**Solution:** Each conversation gets its own worktree (separate directory + branch).

## Command Reference

| Command | Purpose |
|---------|---------|
| `/worktree help` | Show this command reference |
| `/worktree new <description>` | Create worktree with AI-generated name |
| `/worktree new --hotfix <desc>` | Create hotfix (skips to review→deploy→complete) |
| `/worktree new --quick <desc>` | Create quick fix (skips tests/deploy phases) |
| `/worktree list` | List all worktrees with phases |
| `/worktree flow` | Show current worktree status and next steps |
| `/worktree diff` | Show changes from main (PR preview) |
| `/worktree sync` | Rebase/merge latest main into worktree |
| `/worktree note <text>` | Add note to current phase |
| `/worktree block [add\|remove\|list\|clear]` | Manage blockers |
| `/worktree test write` | Write/generate test cases |
| `/worktree test run` | Execute test suite |
| `/worktree review` | Create PR for code review |
| `/worktree deploy [env]` | Deploy to staging/production |
| `/worktree verify [env]` | Mark environment verification complete |
| `/worktree complete` | Finalize worktree, cleanup |
| `/worktree abort` | Abandon worktree, cleanup |
| `/worktree resume` | Show where you left off, continue |
| `/worktree switch <name>` | Switch to different worktree |
| `/worktree merge <name>` | Merge worktree to main |
| `/worktree delete <name>` | Remove worktree |

---

## Commands

### /worktree help

Display command reference and workflow overview.

**Output:**
```
╔══════════════════════════════════════════════════════════════════════╗
║  WORKTREE - Parallel Work Management                                 ║
╠══════════════════════════════════════════════════════════════════════╣
║  Lifecycle: created → developing → testing → review →               ║
║             deploying → human-testing → completed                    ║
║                                                                      ║
║  Modes: standard (full), quick (skip tests/deploy), hotfix (urgent)  ║
╠══════════════════════════════════════════════════════════════════════╣
║  COMMAND                       │ PURPOSE                             ║
║  ──────────────────────────────┼───────────────────────────────────  ║
║  /worktree help                │ Show this help                      ║
║  /worktree new <description>   │ Create worktree (standard mode)     ║
║  /worktree new --quick <desc>  │ Quick fix (skip tests/deploy)       ║
║  /worktree new --hotfix <desc> │ Hotfix (straight to deploy)         ║
║  /worktree list                │ List all worktrees with phases      ║
║  /worktree flow                │ Show status, blockers, next steps   ║
║  /worktree resume              │ Continue where you left off         ║
║  ──────────────────────────────┼───────────────────────────────────  ║
║  /worktree diff                │ Show changes from main              ║
║  /worktree sync                │ Rebase/merge latest main            ║
║  /worktree note <text>         │ Add note to current phase           ║
║  /worktree block [action]      │ Manage blockers (add/remove/list)   ║
║  ──────────────────────────────┼───────────────────────────────────  ║
║  /worktree test write          │ Generate tests for changes          ║
║  /worktree test run            │ Run test suite, record results      ║
║  /worktree review              │ Create PR for code review           ║
║  /worktree deploy [env]        │ Deploy to staging/production        ║
║  /worktree verify [env]        │ Record verification complete        ║
║  /worktree complete            │ Merge PR and cleanup                ║
║  ──────────────────────────────┼───────────────────────────────────  ║
║  /worktree abort               │ Abandon worktree, cleanup           ║
║  /worktree switch <name>       │ Switch to different worktree        ║
║  /worktree merge <name>        │ Merge worktree branch to main       ║
║  /worktree delete <name>       │ Remove worktree and branch          ║
╚══════════════════════════════════════════════════════════════════════╝

Workflows:
  Standard:  new → develop → test write → test run → review → deploy → verify → complete
  Quick:     new --quick → develop → review → complete
  Hotfix:    new --hotfix → develop → review → deploy prod → verify → complete
```

---

### /worktree new <description> [--quick|--hotfix]

Create a new worktree with AI-summarized name from description.

**Modes:**
| Mode | Flag | Workflow | Use Case |
|------|------|----------|----------|
| Standard | (default) | Full lifecycle | Features, refactoring |
| Quick | `--quick` | Skip tests/deploy | Typos, small fixes |
| Hotfix | `--hotfix` | Straight to deploy | Critical production bugs |

**AI Name Generation:**
1. Claude summarizes the user's description into a kebab-case name (2-4 words, max 30 chars)
2. Uses prefixes: `fix-`, `feat-`, `refactor-`, `update-`, `chore-`, `hotfix-`
3. Presents name for user confirmation before creating

**Examples:**
```
/worktree new "fix order validation for minimum quantities"
→ Creates: fix-order-min-quantity (standard mode)

/worktree new --quick "fix typo in readme"
→ Creates: fix-readme-typo (quick mode, skips tests/deploy)

/worktree new --hotfix "critical auth bypass vulnerability"
→ Creates: hotfix-auth-bypass (hotfix mode, deploys to prod immediately)
```

**Implementation:**
```bash
# Parse flags
MODE="standard"
if [[ "$1" == "--quick" ]]; then MODE="quick"; shift; fi
if [[ "$1" == "--hotfix" ]]; then MODE="hotfix"; shift; fi

# AI generates NAME from user description
# Example: "fix-order-min-quantity" from "fix order validation for minimum quantities"
NAME="$AI_GENERATED_NAME"
BASE_DIR="$(dirname $(pwd))"
BRANCH="work/$NAME"
WORKTREE_DIR="$BASE_DIR/$(basename $(pwd))-$NAME"
DESCRIPTION="$USER_DESCRIPTION"

# Create worktree
git worktree add "$WORKTREE_DIR" -b "$BRANCH"

# Initialize state tracking
cd "$WORKTREE_DIR"
mkdir -p .claude/worktrees/$NAME
mkdir -p .claude/conversations

# Create state.json for workflow tracking
cat > .claude/worktrees/$NAME/state.json << EOF
{
  "name": "$NAME",
  "description": "$DESCRIPTION",
  "branch": "$BRANCH",
  "directory": "$WORKTREE_DIR",
  "phase": "created",
  "mode": "$MODE",
  "created": "$(date -Iseconds)",
  "dependencies": [],
  "tests": {
    "written": false,
    "passing": null,
    "lastRun": null,
    "skipped": false
  },
  "pr": {
    "number": null,
    "url": null,
    "approved": false
  },
  "deployments": {
    "staging": {
      "url": null,
      "deployedAt": null,
      "verified": false,
      "verifiedBy": null,
      "verifiedAt": null
    },
    "production": {
      "url": null,
      "deployedAt": null,
      "verified": false,
      "verifiedBy": null,
      "verifiedAt": null
    }
  },
  "notes": [],
  "blockers": []
}
EOF

# Initialize baton conversation
CONV_ID="conv-$(date +%Y%m%d-%H%M%S)"
echo "$CONV_ID" > .claude/CURRENT_CONVERSATION_ID

mkdir -p .claude/conversations/$CONV_ID
cat > .claude/conversations/$CONV_ID/SUMMARY.md << EOF
# Conversation $CONV_ID - TLDR

**Title:** $NAME
**Status:** Active
**Started:** $(date '+%Y-%m-%d %H:%M')
**Worktree:** $WORKTREE_DIR
**Branch:** $BRANCH
**Phase:** created
**Parent:** $(pwd)

## Context in 3 Lines
$DESCRIPTION
Branch: $BRANCH
Isolated worktree for parallel development.

## Task Checklist
- [ ] Implement changes
- [ ] Write tests
- [ ] Create PR
- [ ] Deploy and verify

## Workflow Status
**Phase:** created → developing → testing → review → deploying → human-testing → completed
**Next:** Begin development, then run \`/worktree test write\`

## State Snapshot
**Current Persona:** none
**Current Task:** Starting work on $NAME
**Blockers:** None
**Ready to:** Begin implementation
EOF

# Update phase to developing
jq '.phase = "developing"' .claude/worktrees/$NAME/state.json > tmp && mv tmp .claude/worktrees/$NAME/state.json
```

**Output:**
```
Created worktree: ../outvestments-scoring-fix
Branch: work/scoring-fix
Directory: /home/user/Dev/outvestments-scoring-fix

Open in new terminal:
  cd /home/user/Dev/outvestments-scoring-fix

Or open in VSCode:
  code /home/user/Dev/outvestments-scoring-fix
```

---

### /worktree list

List all worktrees with their workflow phase and status.

**Implementation:**
```bash
git worktree list --porcelain | while read line; do
  # Parse worktree info
  # For each, read .claude/worktrees/$NAME/state.json to get phase
done
```

**Output:**
```
Worktrees:
  PHASE          NAME              BRANCH           DIRECTORY                              STATUS
  ────────────── ───────────────── ──────────────── ────────────────────────────────────── ──────────────
  (main)         main              main             /home/user/Dev/outvestments            5 uncommitted
  developing     fix-order-valid   work/fix-order   /home/user/Dev/outvestments-fix-order  clean
  testing        feat-scoring      work/feat-score  /home/user/Dev/outvestments-scoring    tests passing
  human-testing  refactor-auth     work/ref-auth    /home/user/Dev/outvestments-auth       deployed staging
```

---

### /worktree diff

Show changes from main branch (preview what will be in PR).

**What it does:**
1. Shows file changes compared to main
2. Displays summary of additions/deletions
3. Useful for reviewing before creating PR

**Implementation:**
```bash
echo "Changes from main:"
echo ""
git diff main --stat
echo ""
echo "Files changed: $(git diff main --name-only | wc -l)"
echo ""
echo "View full diff? Run: git diff main"
```

**Output:**
```
Changes from main:

 src/orders/validation.ts | 45 +++++++++++++++++++++++++++++++++++
 src/orders/types.ts      |  8 +++++--
 tests/validation.test.ts | 62 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 113 insertions(+), 2 deletions(-)

Files changed: 3

View full diff? Run: git diff main
```

---

### /worktree sync

Rebase or merge latest changes from main into worktree.

**What it does:**
1. Fetches latest main from origin
2. Rebases current branch on main (or merges if conflicts)
3. Reports any conflicts that need resolution

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
BRANCH=$(git branch --show-current)

echo "Syncing with main..."
git fetch origin main

# Try rebase first (cleaner history)
if git rebase origin/main; then
    echo "✅ Successfully rebased on latest main"
else
    echo "⚠️  Rebase had conflicts. Options:"
    echo "   1. Resolve conflicts and run: git rebase --continue"
    echo "   2. Abort rebase and merge instead: git rebase --abort && git merge origin/main"
fi
```

**Output (success):**
```
Syncing with main...
Fetching origin/main...
Successfully rebased work/fix-order-validation on origin/main

✅ Worktree is up to date with main
   Your branch is 3 commits ahead of main
```

**Output (conflicts):**
```
Syncing with main...
Fetching origin/main...

⚠️  Conflicts detected in:
   - src/orders/validation.ts

Options:
  1. Resolve conflicts, then: git rebase --continue
  2. Abort and merge instead: git rebase --abort && git merge origin/main
  3. Abort completely: git rebase --abort
```

---

### /worktree note <text>

Add a note to the current worktree's state (persisted across sessions).

**What it does:**
1. Appends timestamped note to state.json
2. Associates note with current phase
3. Notes are displayed in `/worktree flow`

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
STATE_FILE=".claude/worktrees/$NAME/state.json"
NOTE_TEXT="$*"
PHASE=$(jq -r '.phase' "$STATE_FILE")
TIMESTAMP=$(date -Iseconds)

# Add note to notes array
jq ".notes += [{\"phase\": \"$PHASE\", \"text\": \"$NOTE_TEXT\", \"timestamp\": \"$TIMESTAMP\"}]" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"

echo "📝 Note added to $PHASE phase"
```

**Example:**
```
/worktree note "Discovered edge case with negative quantities - need to handle"
📝 Note added to developing phase

/worktree note "Tests failing due to missing mock - investigating"
📝 Note added to testing phase
```

---

### /worktree block [action] [text]

Manage blockers for the current worktree.

**Actions:**
- `add <text>` - Add a blocker
- `remove <index>` - Remove blocker by index (1-based)
- `list` - Show all blockers (default)
- `clear` - Remove all blockers

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
STATE_FILE=".claude/worktrees/$NAME/state.json"
ACTION="${1:-list}"

case "$ACTION" in
    add)
        shift
        BLOCKER_TEXT="$*"
        jq ".blockers += [\"$BLOCKER_TEXT\"]" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
        echo "🚫 Blocker added: $BLOCKER_TEXT"
        ;;
    remove)
        INDEX=$(($2 - 1))  # Convert to 0-based
        jq "del(.blockers[$INDEX])" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
        echo "✅ Blocker removed"
        ;;
    clear)
        jq ".blockers = []" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
        echo "✅ All blockers cleared"
        ;;
    list|*)
        BLOCKERS=$(jq -r '.blockers | length' "$STATE_FILE")
        if [ "$BLOCKERS" -eq 0 ]; then
            echo "No blockers. Proceed with workflow!"
        else
            echo "🚫 BLOCKERS ($BLOCKERS):"
            jq -r '.blockers | to_entries[] | "  \(.key + 1). \(.value)"' "$STATE_FILE"
        fi
        ;;
esac
```

**Examples:**
```
/worktree block add "Waiting for API spec from backend team"
🚫 Blocker added: Waiting for API spec from backend team

/worktree block list
🚫 BLOCKERS (2):
  1. Waiting for API spec from backend team
  2. Database migration pending

/worktree block remove 1
✅ Blocker removed

/worktree block clear
✅ All blockers cleared
```

---

### /worktree resume

Show where you left off and continue work (useful after session break).

**What it does:**
1. Reads current state from state.json
2. Shows last activity and notes
3. Displays next recommended action
4. Loads baton context

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
STATE_FILE=".claude/worktrees/$NAME/state.json"

PHASE=$(jq -r '.phase' "$STATE_FILE")
DESCRIPTION=$(jq -r '.description' "$STATE_FILE")
MODE=$(jq -r '.mode' "$STATE_FILE")
LAST_NOTE=$(jq -r '.notes[-1] // empty' "$STATE_FILE")

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║  RESUMING: $NAME"
echo "╠══════════════════════════════════════════════════════════════════════╣"
echo "║  Description: $DESCRIPTION"
echo "║  Mode: $MODE"
echo "║  Current Phase: $PHASE"
if [ -n "$LAST_NOTE" ]; then
    echo "║  Last Note: $(echo $LAST_NOTE | jq -r '.text')"
fi
echo "╠══════════════════════════════════════════════════════════════════════╣"
# Show next action based on phase
echo "║  NEXT: [phase-specific recommendation]"
echo "╚══════════════════════════════════════════════════════════════════════╝"

# Also load baton context
/baton load
```

**Output:**
```
╔══════════════════════════════════════════════════════════════════════╗
║  RESUMING: fix-order-min-quantity                                    ║
╠══════════════════════════════════════════════════════════════════════╣
║  Description: Fix order validation to check minimum quantities       ║
║  Mode: standard                                                      ║
║  Current Phase: testing                                              ║
║  Last Note: Tests failing due to missing mock - investigating        ║
╠══════════════════════════════════════════════════════════════════════╣
║  NEXT: Fix failing tests, then run `/worktree test run`              ║
╚══════════════════════════════════════════════════════════════════════╝

[Baton context loaded...]
```

---

### /worktree abort

Abandon a worktree mid-workflow and cleanup.

**What it does:**
1. Confirms abandonment (destructive action)
2. Stashes or discards uncommitted changes
3. Removes worktree directory
4. Deletes branch (local and remote if pushed)
5. Updates state to "aborted"

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
STATE_FILE=".claude/worktrees/$NAME/state.json"
BRANCH=$(jq -r '.branch' "$STATE_FILE")
WORKTREE_DIR=$(pwd)
MAIN_DIR=$(dirname "$WORKTREE_DIR")/$(basename "$WORKTREE_DIR" | sed "s/-$NAME//")

echo "⚠️  ABORT WORKTREE: $NAME"
echo ""
echo "This will:"
echo "  - Discard all uncommitted changes"
echo "  - Delete worktree directory: $WORKTREE_DIR"
echo "  - Delete branch: $BRANCH"
echo ""
echo "Are you sure? (type 'abort' to confirm)"
read CONFIRM

if [ "$CONFIRM" != "abort" ]; then
    echo "Cancelled."
    exit 0
fi

# Return to main worktree
cd "$MAIN_DIR"

# Remove worktree
git worktree remove "$WORKTREE_DIR" --force

# Delete branch
git branch -D "$BRANCH" 2>/dev/null
git push origin --delete "$BRANCH" 2>/dev/null

echo ""
echo "✅ Worktree aborted and cleaned up"
echo "   Directory removed: $WORKTREE_DIR"
echo "   Branch deleted: $BRANCH"
```

**Output:**
```
⚠️  ABORT WORKTREE: fix-order-min-quantity

This will:
  - Discard all uncommitted changes
  - Delete worktree directory: /home/user/Dev/outvestments-fix-order
  - Delete branch: work/fix-order-min-quantity

Are you sure? (type 'abort' to confirm)
> abort

Removing worktree...
Deleting local branch...
Deleting remote branch...

✅ Worktree aborted and cleaned up
   Directory removed: /home/user/Dev/outvestments-fix-order
   Branch deleted: work/fix-order-min-quantity
```

---

### /worktree flow

Show current worktree's status in the workflow lifecycle and next steps.

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')  # Extract name from directory
STATE_FILE=".claude/worktrees/$NAME/state.json"

if [ ! -f "$STATE_FILE" ]; then
    echo "Not in a tracked worktree. Use /worktree new to create one."
    exit 1
fi

# Read state
PHASE=$(jq -r '.phase' "$STATE_FILE")
MODE=$(jq -r '.mode' "$STATE_FILE")
DESCRIPTION=$(jq -r '.description' "$STATE_FILE")
BRANCH=$(jq -r '.branch' "$STATE_FILE")
TESTS_WRITTEN=$(jq -r '.tests.written' "$STATE_FILE")
TESTS_PASSING=$(jq -r '.tests.passing' "$STATE_FILE")
PR_URL=$(jq -r '.pr.url' "$STATE_FILE")
STAGING_URL=$(jq -r '.deployments.staging.url' "$STATE_FILE")
STAGING_VERIFIED=$(jq -r '.deployments.staging.verified' "$STATE_FILE")
PROD_URL=$(jq -r '.deployments.production.url' "$STATE_FILE")
PROD_VERIFIED=$(jq -r '.deployments.production.verified' "$STATE_FILE")
BLOCKERS=$(jq -r '.blockers | length' "$STATE_FILE")
NOTES_COUNT=$(jq -r '.notes | length' "$STATE_FILE")

# Show blockers if any
if [ "$BLOCKERS" -gt 0 ]; then
    echo "🚫 BLOCKERS:"
    jq -r '.blockers[] | "   - \(.)"' "$STATE_FILE"
fi

# Display flow status with mode indicator
```

**Output (standard mode):**
```
╔══════════════════════════════════════════════════════════════════════╗
║  WORKTREE FLOW: fix-order-min-quantity                    [standard] ║
╠══════════════════════════════════════════════════════════════════════╣
║  Description: Fix order validation to check minimum quantities       ║
║  Branch: work/fix-order-min-quantity                                 ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  ✅ created      → ✅ developing → 🔵 testing → ⚪ review →          ║
║  ⚪ deploying    → ⚪ human-testing → ⚪ completed                    ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║  Current Phase: testing                                              ║
║  Tests Written: ✅ Yes                                               ║
║  Tests Passing: ❌ 3 failing                                         ║
║  PR: Not created                                                     ║
║  Staging: Not deployed                                               ║
║  Production: Not deployed                                            ║
║  Notes: 2 notes recorded                                             ║
╠══════════════════════════════════════════════════════════════════════╣
║  NEXT: Fix failing tests, then run `/worktree test run`              ║
╚══════════════════════════════════════════════════════════════════════╝
```

**Output (with blockers):**
```
╔══════════════════════════════════════════════════════════════════════╗
║  WORKTREE FLOW: fix-order-min-quantity                    [standard] ║
╠══════════════════════════════════════════════════════════════════════╣
║  Description: Fix order validation to check minimum quantities       ║
║  Branch: work/fix-order-min-quantity                                 ║
╠══════════════════════════════════════════════════════════════════════╣
║  🚫 BLOCKERS:                                                        ║
║     - Waiting for API spec clarification from backend team           ║
║     - Database schema migration pending                              ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  ✅ created      → ✅ developing → 🔵 testing → ⚪ review →          ║
║  ⚪ deploying    → ⚪ human-testing → ⚪ completed                    ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║  Current Phase: testing                                              ║
║  Tests Written: ✅ Yes                                               ║
║  Tests Passing: ⏸️ Blocked                                           ║
║  PR: Not created                                                     ║
║  Staging: Not deployed                                               ║
║  Production: Not deployed                                            ║
╠══════════════════════════════════════════════════════════════════════╣
║  NEXT: Resolve blockers before continuing                            ║
╚══════════════════════════════════════════════════════════════════════╝
```

**Output (quick mode - simplified phases):**
```
╔══════════════════════════════════════════════════════════════════════╗
║  WORKTREE FLOW: fix-readme-typo                              [quick] ║
╠══════════════════════════════════════════════════════════════════════╣
║  Description: Fix typo in readme                                     ║
║  Branch: work/fix-readme-typo                                        ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  ✅ created → ✅ developing → 🔵 review → ⚪ completed                ║
║  (tests and deploy skipped in quick mode)                            ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║  Current Phase: review                                               ║
║  PR: https://github.com/user/project/pull/45                         ║
╠══════════════════════════════════════════════════════════════════════╣
║  NEXT: After PR merged, run `/worktree complete`                     ║
╚══════════════════════════════════════════════════════════════════════╝
```

**Output (hotfix mode - streamlined phases):**
```
╔══════════════════════════════════════════════════════════════════════╗
║  WORKTREE FLOW: hotfix-auth-bypass                          [hotfix] ║
╠══════════════════════════════════════════════════════════════════════╣
║  Description: Critical auth bypass vulnerability                     ║
║  Branch: work/hotfix-auth-bypass                                     ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  ✅ created → ✅ developing → ✅ review → 🔵 deploying →              ║
║  ⚪ human-testing → ⚪ completed                                      ║
║  (deploying directly to production)                                  ║
║                                                                      ║
╠══════════════════════════════════════════════════════════════════════╣
║  Current Phase: deploying                                            ║
║  PR: https://github.com/user/project/pull/46 (emergency merged)      ║
║  Production: Deploying...                                            ║
╠══════════════════════════════════════════════════════════════════════╣
║  NEXT: Verify fix in production, then `/worktree verify production`  ║
╚══════════════════════════════════════════════════════════════════════╝
```

---

### /worktree test write

Write or generate test cases for the worktree changes.

**What it does:**
1. Analyzes the changes made in this worktree (git diff from main)
2. Identifies files/functions that need tests
3. Generates or helps write test cases
4. Updates state to `testing` phase
5. Marks `tests.written = true` in state.json

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
STATE_FILE=".claude/worktrees/$NAME/state.json"

# Get changed files
CHANGED_FILES=$(git diff main --name-only)

# Claude analyzes changes and generates tests for:
# - New functions
# - Modified logic
# - Edge cases
# - Error handling

# After tests written, update state
jq '.phase = "testing" | .tests.written = true' "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
```

**Behavior:**
- Claude reads the diff and identifies testable units
- Proposes test cases with expected behavior
- Writes tests to appropriate test files
- Ensures test coverage for new/changed code

**Output:**
```
Analyzing changes from main...

Changed files:
  - src/orders/validation.ts (modified)
  - src/orders/types.ts (modified)

Generating tests for:
  ✓ validateMinimumQuantity() - 4 test cases
  ✓ OrderValidation.check() - 2 test cases
  ✓ Edge case: zero quantity - 1 test case

Tests written to: src/orders/__tests__/validation.test.ts

Phase updated: developing → testing
Run `/worktree test run` to execute tests.
```

---

### /worktree test run

Execute the test suite and record results.

**What it does:**
1. Runs the project's test suite (npm test, pytest, etc.)
2. Records pass/fail status in state.json
3. If all pass, suggests moving to review phase
4. If failures, shows what needs fixing

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
STATE_FILE=".claude/worktrees/$NAME/state.json"

# Detect test runner
if [ -f "package.json" ]; then
    npm test 2>&1 | tee /tmp/test-output.txt
    EXIT_CODE=$?
elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
    pytest 2>&1 | tee /tmp/test-output.txt
    EXIT_CODE=$?
fi

# Update state
TIMESTAMP=$(date -Iseconds)
if [ $EXIT_CODE -eq 0 ]; then
    jq ".tests.passing = true | .tests.lastRun = \"$TIMESTAMP\"" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
    echo "All tests passing! Run /worktree review to create PR."
else
    jq ".tests.passing = false | .tests.lastRun = \"$TIMESTAMP\"" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
    echo "Tests failing. Fix issues and run again."
fi
```

**Output (passing):**
```
Running tests...

 PASS  src/orders/__tests__/validation.test.ts
  ✓ validateMinimumQuantity returns error for quantity below min (3ms)
  ✓ validateMinimumQuantity passes for valid quantity (1ms)
  ✓ validateMinimumQuantity handles edge case zero (2ms)
  ✓ OrderValidation.check integrates validation (5ms)

Tests: 4 passed, 4 total
Time: 1.234s

✅ All tests passing!
Next: Run `/worktree review` to create PR.
```

**Output (failing):**
```
Running tests...

 FAIL  src/orders/__tests__/validation.test.ts
  ✓ validateMinimumQuantity returns error for quantity below min (3ms)
  ✗ validateMinimumQuantity passes for valid quantity (1ms)
    Expected: { valid: true }
    Received: { valid: false, error: "..." }

Tests: 1 failed, 3 passed, 4 total

❌ Tests failing. Fix issues and run `/worktree test run` again.
```

---

### /worktree review

Create a PR for code review (replaces `/worktree done`).

**What it does:**
1. Commits any uncommitted changes
2. Pushes branch to origin
3. Creates PR with auto-generated description
4. Updates state to `review` phase
5. Records PR URL in state.json

**Pre-requisites:**
- Tests must be written (`tests.written = true`)
- Tests should be passing (warns if not)

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
STATE_FILE=".claude/worktrees/$NAME/state.json"
BRANCH=$(git branch --show-current)

# Check prerequisites
TESTS_WRITTEN=$(jq -r '.tests.written' "$STATE_FILE")
TESTS_PASSING=$(jq -r '.tests.passing' "$STATE_FILE")

if [ "$TESTS_WRITTEN" != "true" ]; then
    echo "⚠️  Tests not written. Run /worktree test write first."
    exit 1
fi

if [ "$TESTS_PASSING" != "true" ]; then
    echo "⚠️  Warning: Tests not passing. Create PR anyway? (y/n)"
    read CONFIRM
    [ "$CONFIRM" != "y" ] && exit 1
fi

# Commit and push
git add -A
git commit -m "$(jq -r '.description' "$STATE_FILE")"
git push -u origin "$BRANCH"

# Create PR
PR_URL=$(gh pr create --base main --head "$BRANCH" --fill --json url --jq '.url')

# Update state
jq ".phase = \"review\" | .pr.url = \"$PR_URL\" | .pr.number = $(gh pr view --json number --jq '.number')" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
```

**Output:**
```
Checking prerequisites...
  ✅ Tests written
  ✅ Tests passing

Committing changes...
[work/fix-order-min-quantity abc1234] Fix order validation to check minimum quantities

Pushing to origin...
Creating PR...

✅ PR Created: https://github.com/user/project/pull/42

Phase updated: testing → review
Next: After approval, run `/worktree deploy staging`
```

---

### /worktree deploy [environment]

Deploy the worktree branch to staging or production.

**What it does:**
1. Validates PR is approved (if required)
2. Triggers deployment to specified environment
3. Records deployment URL in state.json under deployments.{env}
4. Updates phase based on mode and environment

**Environments:** `staging` (default), `production`

**Workflow by mode:**
| Mode | First Deploy | Second Deploy |
|------|--------------|---------------|
| Standard | `/worktree deploy staging` | `/worktree deploy production` (after staging verified) |
| Quick | N/A (no deploy phase) | N/A |
| Hotfix | `/worktree deploy production` | N/A (direct to prod) |

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
STATE_FILE=".claude/worktrees/$NAME/state.json"
ENV="${1:-staging}"
MODE=$(jq -r '.mode' "$STATE_FILE")

# Check PR status
PR_NUMBER=$(jq -r '.pr.number' "$STATE_FILE")
if [ "$PR_NUMBER" == "null" ]; then
    echo "❌ No PR created. Run /worktree review first."
    exit 1
fi

# For production, check staging is verified (unless hotfix mode)
if [ "$ENV" == "production" ] && [ "$MODE" != "hotfix" ]; then
    STAGING_VERIFIED=$(jq -r '.deployments.staging.verified' "$STATE_FILE")
    if [ "$STAGING_VERIFIED" != "true" ]; then
        echo "⚠️  Staging not verified. Deploy to staging first, or use --force"
        exit 1
    fi
fi

# Update phase
jq ".phase = \"deploying\"" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"

# Deploy (project-specific - adjust for your CI/CD)
# Examples:
# - Vercel: vercel --env $ENV
# - Docker: docker-compose -f docker-compose.$ENV.yml up -d
# - Railway: railway up --environment $ENV
# - Portainer: curl -X POST "https://portainer.../stacks/..."

DEPLOY_URL="https://$ENV.project.example.com"  # Generated by deploy
TIMESTAMP=$(date -Iseconds)

# Update state with deployment info for this environment
jq ".phase = \"human-testing\" | .deployments.$ENV.url = \"$DEPLOY_URL\" | .deployments.$ENV.deployedAt = \"$TIMESTAMP\"" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"
```

**Output (staging):**
```
Deploying to staging...

Triggering deployment pipeline...
  ✓ Building image
  ✓ Pushing to registry
  ✓ Deploying to staging cluster

✅ Deployed to staging!
URL: https://staging.project.example.com

Phase updated: review → human-testing
Next: Verify changes at the URL, then run `/worktree verify staging`
```

**Output (production after staging verified):**
```
Deploying to production...

Checking prerequisites...
  ✅ Staging deployed and verified

Triggering deployment pipeline...
  ✓ Building production image
  ✓ Pushing to registry
  ✓ Deploying to production cluster

✅ Deployed to production!
URL: https://project.example.com

Next: Verify changes in production, then run `/worktree verify production`
```

**Output (hotfix - direct to production):**
```
🚨 HOTFIX MODE: Deploying directly to production...

Triggering deployment pipeline...
  ✓ Building production image
  ✓ Pushing to registry
  ✓ Deploying to production cluster (expedited)

✅ Deployed to production!
URL: https://project.example.com

⚠️  HOTFIX: Please verify immediately!
Next: Verify fix in production, then run `/worktree verify production`
```

---

### /worktree verify [environment]

Mark environment verification as complete after manual testing.

**What it does:**
1. Prompts for verification notes (what was tested)
2. Records who verified and when in deployments.{env}
3. Determines next step based on mode and verified environments

**Environments:** `staging` (default), `production`

**Workflow:**
- Standard mode: Verify staging → Deploy production → Verify production → Complete
- Hotfix mode: Deploy production → Verify production → Complete
- Quick mode: No deploy/verify phases

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
STATE_FILE=".claude/worktrees/$NAME/state.json"
ENV="${1:-staging}"
MODE=$(jq -r '.mode' "$STATE_FILE")

# Check deployment exists for this environment
DEPLOY_URL=$(jq -r ".deployments.$ENV.url" "$STATE_FILE")
if [ "$DEPLOY_URL" == "null" ]; then
    echo "❌ $ENV not deployed yet. Run /worktree deploy $ENV first."
    exit 1
fi

echo "Verification URL ($ENV): $DEPLOY_URL"
echo ""
echo "What did you test? (Enter notes, then Ctrl+D):"
NOTES=$(cat)

TIMESTAMP=$(date -Iseconds)
VERIFIED_BY=$(git config user.name)

# Update verification for this environment
jq ".deployments.$ENV.verified = true | .deployments.$ENV.verifiedBy = \"$VERIFIED_BY\" | .deployments.$ENV.verifiedAt = \"$TIMESTAMP\"" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"

# Add note with verification details
jq ".notes += [{\"phase\": \"human-testing\", \"text\": \"$ENV verified: $NOTES\", \"timestamp\": \"$TIMESTAMP\"}]" "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"

echo ""
echo "✅ $ENV verification recorded!"
echo "Verified by: $VERIFIED_BY"
echo "Verified at: $TIMESTAMP"

# Determine next step
if [ "$MODE" == "hotfix" ]; then
    if [ "$ENV" == "production" ]; then
        echo ""
        echo "Next: Run /worktree complete to finalize hotfix."
    fi
elif [ "$MODE" == "standard" ]; then
    if [ "$ENV" == "staging" ]; then
        echo ""
        echo "Next: Run /worktree deploy production to deploy to prod."
    elif [ "$ENV" == "production" ]; then
        echo ""
        echo "Next: Run /worktree complete to finalize."
    fi
fi
```

**Output (staging verification):**
```
Verification URL (staging): https://staging.project.example.com

What did you test? (Enter notes, then Ctrl+D):
> Tested order form with quantities 0, 1, 5, 100
> Verified error message appears for invalid quantities
> Checked database shows correct validation results
^D

✅ staging verification recorded!
Verified by: Matt Gerasolo
Verified at: 2025-12-31T15:30:00

Next: Run /worktree deploy production to deploy to prod.
```

**Output (production verification):**
```
Verification URL (production): https://project.example.com

What did you test? (Enter notes, then Ctrl+D):
> Smoke tested order flow in production
> Verified no regressions in related features
^D

✅ production verification recorded!
Verified by: Matt Gerasolo
Verified at: 2025-12-31T16:45:00

Next: Run /worktree complete to finalize.
```

**Output (hotfix production verification):**
```
Verification URL (production): https://project.example.com

What did you test? (Enter notes, then Ctrl+D):
> Confirmed auth bypass is fixed
> Tested login with known exploit - properly rejected
^D

✅ production verification recorded!
Verified by: Matt Gerasolo
Verified at: 2025-12-31T12:05:00

🚨 HOTFIX verified! Run /worktree complete to finalize.
```

---

### /worktree complete

Finalize the worktree after successful verification.

**What it does:**
1. Validates all phases completed
2. Merges PR (or prompts to merge)
3. Updates phase to `completed`
4. Offers to delete worktree

**Implementation:**
```bash
NAME=$(basename $(pwd) | sed 's/.*-//')
STATE_FILE=".claude/worktrees/$NAME/state.json"

# Validate all phases
VERIFIED=$(jq -r '.verification.verified' "$STATE_FILE")
if [ "$VERIFIED" != "true" ]; then
    echo "❌ Not verified. Run /worktree verify first."
    exit 1
fi

# Check PR merge status
PR_NUMBER=$(jq -r '.pr.number' "$STATE_FILE")
PR_STATE=$(gh pr view $PR_NUMBER --json state --jq '.state')

if [ "$PR_STATE" == "OPEN" ]; then
    echo "PR #$PR_NUMBER is still open."
    echo "Merge it now? (y/n)"
    read CONFIRM
    if [ "$CONFIRM" == "y" ]; then
        gh pr merge $PR_NUMBER --squash --delete-branch
    fi
fi

# Update phase
jq '.phase = "completed"' "$STATE_FILE" > tmp && mv tmp "$STATE_FILE"

echo ""
echo "✅ Worktree completed!"
echo ""
echo "Summary:"
echo "  Description: $(jq -r '.description' "$STATE_FILE")"
echo "  Branch: $(jq -r '.branch' "$STATE_FILE")"
echo "  PR: #$PR_NUMBER (merged)"
echo "  Verified by: $(jq -r '.verification.verifiedBy' "$STATE_FILE")"
echo ""
echo "Delete worktree directory? Run: /worktree delete $NAME"
```

**Output:**
```
Checking completion status...
  ✅ Tests written and passing
  ✅ PR created and approved
  ✅ Deployed to staging
  ✅ Human verification complete

PR #42 is still open.
Merge it now? (y/n) y

Merging PR #42...
✅ Merged and branch deleted on remote.

╔══════════════════════════════════════════════════════════════════════╗
║  ✅ WORKTREE COMPLETED: fix-order-min-quantity                       ║
╠══════════════════════════════════════════════════════════════════════╣
║  Description: Fix order validation to check minimum quantities       ║
║  Branch: work/fix-order-min-quantity (merged)                        ║
║  PR: #42 (merged)                                                    ║
║  Verified by: Matt Gerasolo                                          ║
║  Duration: 2h 15m                                                    ║
╚══════════════════════════════════════════════════════════════════════╝

Delete worktree directory? Run: /worktree delete fix-order-min-quantity
```

---

### /worktree switch <name>

Switch to a different worktree (prints cd command).

**Implementation:**
```bash
NAME="$1"
WORKTREE=$(git worktree list | grep "$NAME" | awk '{print $1}')
echo "cd $WORKTREE"
# Also: /baton load in that directory to show context
```

---

### /worktree merge <name>

Merge a worktree branch back to main.

**Implementation:**
```bash
NAME="$1"
BRANCH="work/$NAME"

# Ensure clean working directory
git stash

# Checkout main and merge
git checkout main
git merge "$BRANCH" --no-ff -m "Merge $BRANCH"

# Optionally delete worktree
echo "Worktree merged. Delete it? /worktree delete $NAME"
```

---

### /worktree delete <name>

Remove a worktree and optionally its branch.

**Implementation:**
```bash
NAME="$1"
BRANCH="work/$NAME"
WORKTREE_DIR="$(git worktree list | grep "$NAME" | awk '{print $1}')"

git worktree remove "$WORKTREE_DIR"
git branch -d "$BRANCH"  # Use -D to force if unmerged
```

---

### /worktree done

Complete workflow for finishing work in a worktree. This is the primary way to close out.

**What it does:**
1. Commit any uncommitted changes (if any)
2. Push branch to origin
3. Create PR (or show existing PR)
4. Optionally delete worktree after PR is merged

**Implementation:**

```bash
# Detect current worktree
BRANCH=$(git branch --show-current)
if [[ ! "$BRANCH" == work/* ]]; then
    echo "Not in a worktree (branch doesn't start with work/)"
    exit 1
fi

NAME="${BRANCH#work/}"
WORKTREE_DIR=$(pwd)

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Uncommitted changes detected. Committing..."
    git add -A
    git commit -m "WIP: Complete work on $NAME"
fi

# Push to origin
git push -u origin "$BRANCH"

# Check if PR exists
EXISTING_PR=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number')

if [ -n "$EXISTING_PR" ]; then
    echo "PR already exists: #$EXISTING_PR"
    gh pr view "$EXISTING_PR" --web
else
    echo "Creating PR..."
    gh pr create --base main --head "$BRANCH" --fill
fi

echo ""
echo "Worktree: $WORKTREE_DIR"
echo "Branch: $BRANCH"
echo ""
echo "After PR is merged, run from main:"
echo "  /worktree delete $NAME"
```

**Output:**

```
Uncommitted changes detected. Committing...
[work/fix-order-validation abc1234] WIP: Complete work on fix-order-validation

Pushing to origin...
Creating PR...
https://github.com/user/outvestments/pull/42

Worktree: /home/user/Dev/outvestments-fix-order-validation
Branch: work/fix-order-validation

After PR is merged, run from main:
  /worktree delete fix-order-validation
```

---

### /worktree pr <name>

Create a PR from the worktree branch (alternative to `/worktree done`).

**Implementation:**

```bash
NAME="$1"
BRANCH="work/$NAME"
WORKTREE_DIR="$(git worktree list | grep "$NAME" | awk '{print $1}')"

cd "$WORKTREE_DIR"
git push -u origin "$BRANCH"
gh pr create --base main --head "$BRANCH"
```

---

## Auto-Behaviors

When `.claude/` exists and SUMMARY.md contains `Worktree:` field:

**On Session Start:**
1. Detect current working directory
2. Check if in a worktree (vs main)
3. Load correct baton context for this worktree
4. Show worktree status in context restoration

**In SUMMARY.md:**
```markdown
**Worktree:** /home/user/Dev/outvestments-scoring
**Branch:** work/scoring-fix
**Parent:** /home/user/Dev/outvestments
```

---

## Integration with Baton

Each worktree has its own `.claude/` directory with:
- Independent `CURRENT_CONVERSATION_ID`
- Separate `SUMMARY.md` per worktree
- Shared `BUGS.md` and `DECISIONS.md` (via symlinks to parent)

**Symlink shared files:**
```bash
# In new worktree .claude/
ln -s ../../outvestments/.claude/BUGS.md BUGS.md
ln -s ../../outvestments/.claude/DECISIONS.md DECISIONS.md
ln -s ../../outvestments/.claude/CONVERSATION_HISTORY.md CONVERSATION_HISTORY.md
```

This way:
- Bugs discovered in any worktree are visible everywhere
- Decisions are shared across parallel streams
- Each stream has its own SUMMARY.md

---

## Workflow Example

**Starting 3 parallel scoring fixes:**

```
# Terminal 1 (main)
/worktree new scoring-metrics
# Opens: ../outvestments-scoring-metrics

# Terminal 2
cd ../outvestments-scoring-metrics
# Start new Claude conversation here
# Work on scoring metrics changes

# Terminal 3
/worktree new scoring-grades  # From main
# Start another Claude conversation

# Terminal 4
/worktree new scoring-ui  # From main
# Start third Claude conversation
```

**Merging back:**

```
# Each worktree creates PR
/worktree pr scoring-metrics
/worktree pr scoring-grades
/worktree pr scoring-ui

# Review and merge PRs on GitHub
# Then cleanup:
/worktree delete scoring-metrics
/worktree delete scoring-grades
/worktree delete scoring-ui
```

---

## Tips

1. **Name worktrees descriptively** - `scoring-fix` not `fix1`
2. **One task per worktree** - Keep scope focused
3. **Commit frequently** - Each worktree should have clean commits
4. **Merge to main regularly** - Avoid long-lived worktrees
5. **Delete after merge** - Keep worktree list clean

---

## File Structure

```
/home/user/Dev/
├── outvestments/                    # Main worktree
│   ├── .claude/
│   │   ├── CONVERSATION_HISTORY.md  # Shared
│   │   ├── BUGS.md                  # Shared
│   │   ├── DECISIONS.md             # Shared
│   │   └── conversations/
│   │       └── conv-main/SUMMARY.md
│   └── [project files]
│
├── outvestments-scoring/            # Worktree 1
│   ├── .claude/
│   │   ├── BUGS.md -> ../outvestments/.claude/BUGS.md
│   │   ├── DECISIONS.md -> ../outvestments/.claude/DECISIONS.md
│   │   └── conversations/
│   │       └── conv-scoring/SUMMARY.md
│   └── [project files on work/scoring branch]
│
└── outvestments-orders/             # Worktree 2
    ├── .claude/
    │   ├── BUGS.md -> ../outvestments/.claude/BUGS.md
    │   ├── DECISIONS.md -> ../outvestments/.claude/DECISIONS.md
    │   └── conversations/
    │       └── conv-orders/SUMMARY.md
    └── [project files on work/orders branch]
```
