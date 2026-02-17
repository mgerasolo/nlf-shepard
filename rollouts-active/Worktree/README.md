# Worktree - Git Worktree Management with Workflow Lifecycle

This rollout adds `/worktree` as a Claude Code command for managing parallel development work using git worktrees with structured lifecycle tracking.

## What This Rollout Does

1. Creates `.claude/commands/worktree.md` in each project
2. Creates `.claude-code/skills/worktree/SKILL.md` with full implementation
3. Creates `.claude/worktrees/` directory for state tracking
4. Enables structured workflow phases: created → developing → testing → review → deploying → human-testing → completed

## Why This Change

Git worktrees allow parallel development without branch switching overhead. This command adds:
- Structured 7-phase workflow lifecycle
- Three workflow modes: standard, quick, hotfix
- Blocker tracking and notes
- Multi-environment deployment tracking (staging + production)
- Human testing verification gates
- Baton integration for per-worktree context

## Prerequisites

- Git repository initialized
- `.claude/` directory should exist (created by baton rollout)
- Optionally: `BatonCommand` rollout for context integration

## Files Changed

| File | Action |
|------|--------|
| `.claude/commands/worktree.md` | Created (new) |
| `.claude-code/skills/worktree/SKILL.md` | Created (new) |
| `.claude/worktrees/` | Directory created |

## Execution Time

~3 minutes per project (file copy + directory creation)

## Key Features

### Workflow Modes

| Mode | Flag | Phases | Use Case |
|------|------|--------|----------|
| Standard | (default) | All 7 phases | Features, refactoring |
| Quick | `--quick` | created → developing → review → completed | Typos, small fixes |
| Hotfix | `--hotfix` | 6 phases (direct to prod) | Critical production bugs |

### Blocker Tracking

```
/worktree block add "Waiting for API spec"
/worktree block list
/worktree block remove 1
/worktree block clear
```

### Multi-Environment Deployment

```
/worktree deploy staging
/worktree verify staging
/worktree deploy production
/worktree verify production
```

## Verification

After rollout, verify:
1. `.claude/commands/worktree.md` exists
2. `.claude-code/skills/worktree/SKILL.md` exists
3. `.claude/worktrees/` directory exists
4. `/worktree help` command is recognized in Claude Code session

## Integration with Baton

Each worktree has its own `.claude/` directory with:
- Independent `CURRENT_CONVERSATION_ID`
- Separate `SUMMARY.md` per worktree
- Symlinked shared files (BUGS.md, DECISIONS.md)

This enables isolated context management per parallel work stream.
