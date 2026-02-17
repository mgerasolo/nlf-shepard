# Worktree - Parallel Work Management Command

**Usage:** `/worktree [subcommand] [args]`

Manage git worktrees with structured workflow lifecycle. Each worktree progresses through phases: created → developing → testing → review → deploying → human-testing → completed.

## Command Reference

| Command | Purpose |
|---------|---------|
| `/worktree help` | Show command reference |
| `/worktree new <description>` | Create worktree with AI-generated name |
| `/worktree new --quick <desc>` | Quick fix (skip tests/deploy phases) |
| `/worktree new --hotfix <desc>` | Hotfix (straight to production deploy) |
| `/worktree list` | List all worktrees with phases |
| `/worktree flow` | Show current worktree status and next steps |
| `/worktree diff` | Show changes from main (PR preview) |
| `/worktree sync` | Rebase/merge latest main into worktree |
| `/worktree note <text>` | Add note to current phase |
| `/worktree block [add\|remove\|list\|clear]` | Manage blockers |
| `/worktree resume` | Show where you left off, continue |
| `/worktree test write` | Write/generate test cases |
| `/worktree test run` | Execute test suite |
| `/worktree review` | Create PR for code review |
| `/worktree deploy [env]` | Deploy to staging/production |
| `/worktree verify [env]` | Mark environment verification complete |
| `/worktree complete` | Finalize worktree, cleanup |
| `/worktree abort` | Abandon worktree, cleanup |
| `/worktree switch <name>` | Switch to different worktree |
| `/worktree merge <name>` | Merge worktree to main |
| `/worktree delete <name>` | Remove worktree |

## Workflow Modes

| Mode | Flag | Workflow | Use Case |
|------|------|----------|----------|
| Standard | (default) | Full lifecycle with staging + prod | Features, refactoring |
| Quick | `--quick` | Skip tests/deploy phases | Typos, small fixes |
| Hotfix | `--hotfix` | Direct to production deploy | Critical production bugs |

## Workflow Lifecycle

```
Standard Mode:
┌─────────┐   ┌────────────┐   ┌─────────┐   ┌────────┐   ┌───────────┐   ┌──────────────┐   ┌───────────┐
│ created │ → │ developing │ → │ testing │ → │ review │ → │ deploying │ → │ human-testing│ → │ completed │
└─────────┘   └────────────┘   └─────────┘   └────────┘   └───────────┘   └──────────────┘   └───────────┘

Quick Mode:
┌─────────┐   ┌────────────┐   ┌────────┐   ┌───────────┐
│ created │ → │ developing │ → │ review │ → │ completed │
└─────────┘   └────────────┘   └────────┘   └───────────┘

Hotfix Mode:
┌─────────┐   ┌────────────┐   ┌────────┐   ┌───────────┐   ┌──────────────┐   ┌───────────┐
│ created │ → │ developing │ → │ review │ → │ deploying │ → │ human-testing│ → │ completed │
└─────────┘   └────────────┘   └────────┘   └───────────┘   └──────────────┘   └───────────┘
                                             (direct to prod)
```

## Quick Reference

### Start New Work
```
/worktree new "fix order validation for minimum quantities"
# Creates: worktree fix-order-min-quantity (standard mode)

/worktree new --quick "fix typo in readme"
# Creates: worktree fix-readme-typo (quick mode)

/worktree new --hotfix "critical auth bypass vulnerability"
# Creates: worktree hotfix-auth-bypass (hotfix mode)
```

### Check Progress
```
/worktree flow
# Shows current phase, blockers, and next steps
```

### Manage Blockers
```
/worktree block add "Waiting for API spec"
/worktree block list
/worktree block remove 1
```

### Standard Workflow
```
# 1. Create worktree
/worktree new "add user authentication"

# 2. Develop... (phase: developing)

# 3. Write tests
/worktree test write

# 4. Run tests
/worktree test run

# 5. Create PR
/worktree review

# 6. Deploy to staging
/worktree deploy staging

# 7. Human verifies staging
/worktree verify staging

# 8. Deploy to production
/worktree deploy production

# 9. Human verifies production
/worktree verify production

# 10. Complete and cleanup
/worktree complete
```

### Quick Fix Workflow
```
/worktree new --quick "fix typo in readme"
# ... make fix ...
/worktree review
/worktree complete
```

### Hotfix Workflow
```
/worktree new --hotfix "critical auth bypass"
# ... emergency fix ...
/worktree review
/worktree deploy production
/worktree verify production
/worktree complete
```

## State Tracking

State stored in: `.claude/worktrees/{name}/state.json`

```json
{
  "name": "fix-order-min-quantity",
  "description": "Fix order validation to check minimum quantities",
  "branch": "work/fix-order-min-quantity",
  "directory": "/path/to/worktree",
  "phase": "testing",
  "mode": "standard",
  "created": "2025-12-31T12:00:00Z",
  "dependencies": [],
  "tests": {
    "written": true,
    "passing": false,
    "lastRun": "2025-12-31T14:00:00Z",
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
```

## Integration with Baton

Each worktree has its own `.claude/` directory with:
- Independent `CURRENT_CONVERSATION_ID`
- Separate `SUMMARY.md` per worktree
- Symlinked shared files (BUGS.md, DECISIONS.md)

See full documentation: `/mnt/foundry_project/Claude_skills/worktree/SKILL.md`
