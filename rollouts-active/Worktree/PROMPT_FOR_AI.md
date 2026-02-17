# Worktree Rollout - AI Prompt

## Objective

Add `/worktree` command for managing git worktrees with structured workflow lifecycle. Each worktree progresses through phases: created → developing → testing → review → deploying → human-testing → completed.

## Steps

1. **Check for .claude directory**
   ```bash
   ls -la .claude/
   ```
   If it doesn't exist, create it:
   ```bash
   mkdir -p .claude/commands
   ```

2. **Create commands directory if needed**
   ```bash
   mkdir -p .claude/commands
   ```

3. **Create .claude-code/skills/worktree directory**
   ```bash
   mkdir -p .claude-code/skills/worktree
   ```

4. **Copy worktree command file**

   Copy the content from skeleton_files/.claude/commands/worktree.md to `.claude/commands/worktree.md`

5. **Copy worktree SKILL.md file**

   Copy the content from skeleton_files/.claude-code/skills/worktree/SKILL.md to `.claude-code/skills/worktree/SKILL.md`

6. **Create worktrees state directory**
   ```bash
   mkdir -p .claude/worktrees
   ```

7. **Verify the files were created**
   ```bash
   ls -la .claude/commands/worktree.md
   ls -la .claude-code/skills/worktree/SKILL.md
   ls -la .claude/worktrees/
   ```

## Key Commands

| Command | Purpose |
|---------|---------|
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

## Workflow Modes

| Mode | Flag | Workflow | Use Case |
|------|------|----------|----------|
| Standard | (default) | Full lifecycle with staging + prod | Features, refactoring |
| Quick | `--quick` | Skip tests/deploy phases | Typos, small fixes |
| Hotfix | `--hotfix` | Direct to production deploy | Critical production bugs |

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

## Verification Checklist

- [ ] `.claude/commands/` directory exists
- [ ] `.claude/commands/worktree.md` file exists
- [ ] `.claude-code/skills/worktree/` directory exists
- [ ] `.claude-code/skills/worktree/SKILL.md` file exists
- [ ] `.claude/worktrees/` directory exists
- [ ] File contains worktree command documentation (check first 20 lines)

## Report

When complete, report:
- Files created/modified
- Any issues encountered
- Verification status
