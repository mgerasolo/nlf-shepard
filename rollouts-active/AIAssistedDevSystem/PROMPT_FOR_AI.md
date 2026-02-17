# AI Prompt: Setup AI-Assisted Development System

> **Copy this entire prompt and paste it into each project's AI assistant (Cursor, Claude Code)**

---

## Task: Initialize AI-Assisted Development System

You are setting up the AI-Assisted Development System for this project. This includes:
1. GitHub labels for 10-phase pipeline
2. Baton context management
3. Workflow commands (/wf:*)
4. CLAUDE.md integration

## Reference Documentation

- Full workflow guide: `/mnt/foundry_project/AppServices/Standards-v2/shared/project-management/ai-assisted-workflow.md`
- Setup guide: `/mnt/foundry_project/AppServices/Standards-v2/shared/project-management/setup-guide.md`
- Baton protocol: `/mnt/foundry_project/AppServices/Standards-v2/shared/context-management/baton-protocol.md`
- Workflow commands: `/mnt/foundry_project/AppServices/Standards-v2/shared/workflow-commands/wf-commands.md`

---

## Step 1: Create GitHub Labels

Run the label setup script:

```bash
/mnt/foundry_project/AppServices/Standards-v2/shared/project-management/scripts/setup-labels.sh
```

Or create labels manually using `gh label create` commands (see setup-guide.md for full list).

**Required Label Categories:**
- Phase labels (10): `phase:0-backlog` through `phase:9-done`
- Next action (4): `next:ai-ready`, `next:human-input`, `next:human-verification`, `next:ai-testing`
- Workflow type (2): `workflow:full`, `workflow:quick`
- Type (6): `type:bug`, `type:feature`, `type:enhancement`, `type:docs`, `type:config`, `type:security`
- Priority (4): `priority:critical`, `priority:high`, `priority:medium`, `priority:low`
- Tests (4): `tests:passed`, `tests:failed-1`, `tests:failed-2`, `tests:failed-3+`

---

## Step 2: Initialize Baton Context Management

### Create Directory Structure

```bash
mkdir -p .claude/{conversations,archive,templates,worktrees}
mkdir -p .claude/archive/{conversations,bugs,decisions}
```

### Create Core Files

```bash
touch .claude/{BUGS.md,DECISIONS.md,CONVERSATION_HISTORY.md,ENHANCEMENTS.md,USER_FEEDBACK.md}
```

### Create settings.json

Create `.claude/settings.json`:

```json
{
  "autoSave": {
    "enabled": true,
    "thresholds": [70, 85, 95],
    "notifyOnSave": true
  },
  "archiveThresholds": {
    "conversations": 10,
    "bugs": 20,
    "decisions": 15
  },
  "defaultTemplate": "standard",
  "gitIntegration": {
    "enabled": true,
    "tagCommits": true,
    "addConvIdToMessage": true
  }
}
```

### Create Standard Template

Create `.claude/templates/standard.md`:

```markdown
# Conversation {conv-id} - TLDR

**Title:** [Set via /baton rename]
**Status:** Active
**Started:** {date}
**Duration:** 0h
**Compactions:** 0

## Context in 3 Lines

## Task Checklist

## Decisions Made

## Key Files Created/Modified

## Failed Attempts (Don't Retry)

## Next Actions

## State Snapshot
**Current file:**
**Current line:**
**Current task:**
**Current agent:**
**Blockers:**
**Ready to:**
```

### Initialize History

Create `.claude/CONVERSATION_HISTORY.md`:

```markdown
# Conversation History

| ID | Title | Started | Last Save | Status |
|----|-------|---------|-----------|--------|
```

---

## Step 3: Setup Workflow Commands

### Create Command Directory

```bash
mkdir -p .claude/commands/wf
```

### Create Workflow Commands

Create these files in `.claude/commands/wf/`:

**help.md:**
```markdown
## /wf:help - Workflow Command Reference

| Command | Purpose |
|---------|---------|
| `/wf:status` | Show issues by phase |
| `/wf:pending` | Show items needing human review |
| `/wf:approve #N` | Approve issue and advance |
| `/wf:deny #N [reason]` | Reject with feedback |
| `/wf:issue` | Create new issue |
| `/wf:deploy` | Deploy pending items |
| `/wf:review` | Start review session |
```

**status.md:**
```markdown
## /wf:status - Show Workflow Status

Run: `gh issue list --json number,title,labels -q '.[] | select(.labels[].name | startswith("phase:")) | {number, title, phase: .labels[] | select(.name | startswith("phase:")).name}'`

Group output by phase and show counts.
```

**approve.md:**
```markdown
## /wf:approve #N - Approve and Advance

1. Verify issue #N is in `phase:7-human-review`
2. Remove `phase:7-human-review` label
3. Add `phase:8-docs-update` label
4. Add comment: "✅ Approved via /wf:approve"
5. If no docs needed, advance to `phase:9-done` and close
```

**deny.md:**
```markdown
## /wf:deny #N [reason] - Reject with Feedback

1. Verify issue #N is in review phase
2. Return to appropriate earlier phase
3. Add `next:ai-ready` label
4. Add comment with rejection reason
5. Reference what needs to change
```

**issue.md:**
```markdown
## /wf:issue - Create New Issue

Interactive wizard:
1. Ask for title
2. Ask for type (bug/feature/enhancement)
3. Ask for priority
4. Ask for workflow type (full/quick)
5. Create issue with labels: `phase:0-backlog`, type, priority, workflow type
```

---

## Step 4: Update CLAUDE.md

Add this section to your project's CLAUDE.md:

```markdown
## AI-Assisted Development Workflow

This project uses the NLF AI-Assisted Development System.

### Workflow Overview

| Phase | Actor | Purpose |
|-------|-------|---------|
| 0-backlog | Human | Triage and prioritize |
| 1-refining | AI | Clarify requirements |
| 2-designing | AI | Design solution |
| 3-tests-writing | AI | Write tests (TDD) |
| 4-developing | AI | Implement code |
| 5-tea-testing | AI | Run tests |
| 6-deployment | AI | Deploy to staging |
| 7-human-review | Human | Test deployed feature |
| 8-docs-update | AI | Update documentation |
| 9-done | - | Complete |

### Workflow Commands

- `/wf:status` - Show workflow status
- `/wf:pending` - Items needing human review
- `/wf:approve #N` - Approve issue
- `/wf:deny #N reason` - Reject with feedback

### Baton Context Management

- `/baton init` - Start new conversation
- `/baton save` - Save current state
- `/baton load` - Load context (run after compaction)

### Quality Gates

1. **Clarification Gate:** If requirements unclear, apply `next:human-input`
2. **Split Gate:** If >3 acceptance criteria, apply `needs:split`
3. **Test Gate:** After 3+ test failures, apply `next:human-input`

### Standards Reference

- Workflow: `/mnt/foundry_project/AppServices/Standards-v2/shared/project-management/ai-assisted-workflow.md`
- Baton: `/mnt/foundry_project/AppServices/Standards-v2/shared/context-management/baton-protocol.md`
```

---

## Step 5: Symlink Baton Skill (Optional)

If using baton skill from centralized location:

```bash
mkdir -p .claude-code/skills
ln -sf /mnt/foundry_project/AppServices/Standards-v2/shared/Claude/Claude_skills/baton .claude-code/skills/baton
```

---

## Step 6: Update .gitignore

Add these patterns:

```
# Baton context (sensitive)
.claude/conversations/*/
.claude/CURRENT_CONVERSATION_ID

# Keep structure files
!.claude/
!.claude/CONVERSATION_HISTORY.md
!.claude/templates/
!.claude/settings.json
```

---

## Verification Checklist

After completing setup, verify:

- [ ] GitHub labels created: `gh label list | wc -l` should show 40+
- [ ] `.claude/` directory exists with proper structure
- [ ] `.claude/settings.json` exists
- [ ] `.claude/templates/standard.md` exists
- [ ] `.claude/CONVERSATION_HISTORY.md` exists
- [ ] `.claude/commands/wf/` directory with command files
- [ ] CLAUDE.md includes workflow section

---

## Testing the Setup

### Test 1: Create an Issue

```bash
gh issue create \
  --title "Test: Verify AI workflow setup" \
  --body "Test issue to verify workflow setup" \
  --label "phase:0-backlog,type:enhancement,priority:low,workflow:quick"
```

### Test 2: Run Workflow Command

Use `/wf:status` to see the new issue in backlog.

### Test 3: Test Baton

Use `/baton init` to start a new conversation tracking session.

---

## Next Steps After Setup

1. **First Issue:** Create your first real issue with `phase:0-backlog`
2. **Triage:** Apply `workflow:full` or `workflow:quick`
3. **Activate:** Change to `phase:1-refining` with `next:ai-ready`
4. **Work:** Follow the 10-phase pipeline

---

**Estimated time:** 15-30 minutes

Begin implementation now.
