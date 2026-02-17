# /wf:help - Workflow Command Reference

## Available Commands

| Command | Purpose |
|---------|---------|
| `/wf:status` | Show issues by phase with counts |
| `/wf:pending` | Show items needing human review |
| `/wf:approve #N` | Approve issue and advance to next phase |
| `/wf:deny #N [reason]` | Reject with feedback |
| `/wf:issue` | Create new issue interactively |
| `/wf:deploy` | Deploy pending items |
| `/wf:review` | Start human review session |

## Workflow Phases

| Phase | Who | Purpose |
|-------|-----|---------|
| 0-backlog | Human | Triage, prioritize |
| 1-refining | AI | Clarify requirements |
| 2-designing | AI | Design solution |
| 3-tests-writing | AI | Write tests (TDD) |
| 4-developing | AI | Implement code |
| 5-tea-testing | AI | Run tests |
| 6-deployment | AI | Deploy to staging |
| 7-human-review | Human | Test deployed feature |
| 8-docs-update | AI | Update documentation |
| 9-done | - | Complete |

## Quick Reference

**Move issue forward:** Natural language like "approve #42" or "looks good on #42"

**Block issue:** Add `next:human-input` label with comment explaining what's needed

**Skip phases:** Use `workflow:quick` label for simple fixes
