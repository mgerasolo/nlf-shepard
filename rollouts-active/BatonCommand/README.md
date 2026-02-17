# BatonCommand - Add Baton as Command (Not Just Skill)

This rollout adds `/baton` as a Claude Code command in addition to being a skill, improving accessibility and ensuring consistent behavior across all projects.

## What This Rollout Does

1. Creates `.claude/commands/baton.md` in each project
2. Updates the global `~/.claude/commands/baton.md` symlink (if on local machine)
3. Verifies baton works as both `/baton` command and skill

## Why This Change

Previously, baton was only available as a skill (via `.claude-code/skills/baton/SKILL.md`). Commands are simpler to invoke and more discoverable in Claude Code. Having both ensures:
- Consistent `/baton` invocation across all environments
- Better discoverability
- Fallback if skill loading has issues

## Prerequisites

- Project should have `Baton&PromptResponseFormat` rollout complete (or can be done together)
- `.claude/` directory should exist

## Files Changed

| File | Action |
|------|--------|
| `.claude/commands/baton.md` | Created (new) |

## Execution Time

~2 minutes per project (mostly file copy)

## Verification

After rollout, verify:
1. `.claude/commands/baton.md` exists
2. File contains baton command documentation
3. `/baton` command is recognized in Claude Code session
