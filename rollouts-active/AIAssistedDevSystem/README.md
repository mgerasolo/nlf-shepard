# AI-Assisted Development System

Complete AI-assisted development workflow with 10-phase GitHub pipeline, BMAD agent integration, enhanced baton context management, and workflow commands.

## What This Rollout Adds

### 1. GitHub Labels (45+)

| Category | Count | Purpose |
|----------|-------|---------|
| Phase | 10 | `phase:0-backlog` through `phase:9-done` |
| Next Action | 4 | `next:ai-ready`, `next:human-input`, `next:human-verification`, `next:ai-testing` |
| Workflow Type | 2 | `workflow:full`, `workflow:quick` |
| Type | 6 | `type:bug`, `type:feature`, `type:enhancement`, etc. |
| Priority | 4 | `priority:critical/high/medium/low` |
| Tests | 4 | `tests:passed`, `tests:failed-1/2/3+` |
| Area | varies | `area:ui`, `area:api`, `area:database`, etc. |

### 2. Baton Context Management (Enhanced)

- Two-tier context (TLDR ~1K tokens, full ~50K tokens)
- Auto-save at 70%, 85%, 95% thresholds
- Conversation switching and search
- BMAD agent persistence after compaction
- Template system

### 3. Workflow Commands (/wf:*)

| Command | Purpose |
|---------|---------|
| `/wf:help` | List all commands |
| `/wf:status` | Current status by phase |
| `/wf:pending` | Items awaiting human review |
| `/wf:approve #N` | Approve and advance issue |
| `/wf:deny #N [reason]` | Reject with feedback |
| `/wf:deploy` | Deploy pending items |
| `/wf:review` | Human review session |
| `/wf:issue` | Create new issue |

### 4. BMAD Agent Integration

| Phase | Agent | Purpose |
|-------|-------|---------|
| 1-refining | Analyst | Clarify requirements |
| 2-designing | Architect | Design solution |
| 3-tests, 5-testing | TEA | Test engineering |
| 4-developing | Developer | Write code |
| 8-docs | PM | Update documentation |

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Claude Code installed
- Node.js (for optional automation scripts)
- Git repository initialized

## What Changes

- Creates `.claude/` directory structure
- Creates `.claude/commands/wf/` workflow commands
- Adds GitHub labels via `gh` CLI
- Adds CLAUDE.md section for workflow integration
- Optional: Symlinks baton skill

## Expected Outcome

After migration:
1. Project has 45+ GitHub labels for workflow tracking
2. Baton context management initialized
3. Workflow commands available via `/wf:*`
4. CLAUDE.md includes AI workflow integration
5. Ready for AI-assisted development

## Verification

- [ ] `.claude/` directory exists with proper structure
- [ ] GitHub labels created (check with `gh label list | wc -l`)
- [ ] CONVERSATION_HISTORY.md exists
- [ ] settings.json configured
- [ ] Workflow commands accessible
- [ ] CLAUDE.md includes workflow section

## Rollback

```bash
# Remove baton structure (if new project)
rm -rf .claude/

# Remove labels (if desired)
gh label list --json name -q '.[].name' | while read label; do
  gh label delete "$label" --yes
done

# Remove CLAUDE.md workflow section manually
```

## Timeline

Estimated time per project: 15-30 minutes

## Known Issues

### Project-Specific Notes

**Existing Projects with Partial Setup:**
- May already have some labels - script handles duplicates
- May have existing `.claude/` - script preserves existing files

**Projects Without Tests:**
- Skip `tests:*` labels
- Skip Phase 3 (tests-writing) in workflow

---

**Created:** 2026-01-06
**Author:** Claude Code (Opus)
**Reference:** HabitArcade-PoC implementation
