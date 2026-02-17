# ShepardProtocol Rollout: PushAllCommand

**Rollout ID:** PushAllCommand
**Created:** 2025-12-26
**Status:** Active
**Priority:** Medium

## Overview

Deploy the enhanced `/push-all` command to all NLF projects. This slash command provides comprehensive git automation with NLF-specific validations, Baton integration, and smart commit message generation.

## What This Deploys

**File:** `.claude/commands/push-all.md`

**Features:**
- Comprehensive safety checks (secrets, large files, build artifacts)
- NLF-specific validations (DEPLOYMENTS.md, standards, deprecated patterns)
- Baton integration (auto-save, conversation linking)
- Smart commit message generation (detects rollouts, breaking changes)
- Pre-commit validators (shellcheck, YAML, JSON)
- GitHub integration (issue linking, PR creation)
- Enhanced error recovery with actionable fixes

## Target Projects

**All active projects with `.claude/` directory:**

| Priority | Projects |
|----------|----------|
| Critical | Infrastructure, AppBrain |
| High | Finance-Ingest, DoughFlow, Self-Improving AI |
| Medium | Admin, Basic-Habits, Start.Matt, Shadcn-Wireframer |
| Skip | DashCentral (doesn't exist), Test-App, ExpertChat, Habits-Tasks, Health, N8N, AIKBase (experimental/paused) |

**Total:** 10 projects to update

## Prerequisites

- Project has `.claude/` directory
- Project is actively maintained
- Git repository is initialized

## Success Criteria

- [x] `.claude/commands/push-all.md` created
- [x] Command follows NLF standards and patterns
- [x] Command deployed to all 10 active projects
- [x] Each project's projects.json updated with migration status
- [x] Rollout audit log updated
- [x] Verification completed on each project

**Completion Date:** 2025-12-26
**Status:** ✅ COMPLETE

## Rollout Phases

### Phase 1: Infrastructure (Critical)
**Host:** friday

- Infrastructure

**Why first:** Contains the source command, validates it works

### Phase 2: Core Applications (Critical/High)
**Host:** stark

- AppBrain
- Finance-Ingest
- DoughFlow
- Self-Improving AI

**Why second:** Production and high-priority projects

### Phase 3: Development Tools (Medium)
**Host:** stark, parker

- Admin
- Basic-Habits
- Start.Matt
- Shadcn-Wireframer

**Why third:** Lower priority, development/personal projects

## Verification

For each project:

```bash
# 1. Check file exists
ls -la .claude/commands/push-all.md

# 2. Check file permissions
chmod 644 .claude/commands/push-all.md

# 3. Verify command is accessible (via Claude Code)
# Run: /push-all
# Should show the comprehensive workflow

# 4. Test one safety check
git status  # Should show clean or expected files
```

## Rollback Plan

If issues found:

1. Remove `.claude/commands/push-all.md` from affected project
2. Document issue in rollout notes
3. Fix source command in Infrastructure
4. Re-deploy to affected projects

```bash
# Rollback command
rm .claude/commands/push-all.md
git checkout HEAD -- .claude/commands/push-all.md  # If was committed
```

## Dependencies

**Depends on:**
- Baton&PromptResponseFormat rollout (completed)
- Infrastructure having .claude/commands/ directory

**Provides:**
- Enhanced git workflow for all projects
- NLF-aware commit automation
- Baton-integrated version control

## Notes

- This command is optional - projects can use standard git workflows
- Command includes safety checks to prevent accidental commits
- Command will detect and warn about NLF-specific issues
- Baton integration auto-links commits to conversations

## Related

- **Source:** `/home/mgerasolo/Infrastructure/.claude/commands/push-all.md`
- **Documentation:** See command file for full workflow
- **Baton Rollout:** `/mnt/foundry_project/AppServices/ShepardProtocol/rollouts-active/Baton&PromptResponseFormat/`
