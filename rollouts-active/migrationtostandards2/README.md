# Standards-v2 Rollout Package

This directory contains everything needed to update all app development projects to use the new Standards-v2 directory structure.

## Quick Start

For each app development project:

1. **Copy this directory** to the project's root
2. **Read** [ROLLOUT_PROMPT.md](ROLLOUT_PROMPT.md) - Main instructions
3. **Execute** updates using [QUICK_COMMANDS.md](QUICK_COMMANDS.md)
4. **Verify** by running `verify-migration.sh` or using [VERIFICATION_CHECKLIST.md](VERIFICATION_CHECKLIST.md)
5. **Track** progress in [PROJECT_STATUS.md](PROJECT_STATUS.md)
6. **Delete** this rollout directory after successful migration

## Files in This Package

| File | Purpose |
|------|---------|
| `ROLLOUT_PROMPT.md` | Main migration instructions for AI agents and developers |
| `QUICK_COMMANDS.md` | Fast command reference for common tasks |
| `verify-migration.sh` | Automated verification script (run this to check migration) |
| `VERIFICATION_CHECKLIST.md` | Step-by-step verification checklist (manual alternative) |
| `PROJECT_STATUS.md` | Track which projects have been migrated |
| `README.md` | This file |

## AI Agent Prompt

If using Claude Code or another AI agent to perform the migration, provide this prompt:

```
Please migrate this project to use the new Standards-v2 directory structure.

Read the instructions in UpdateAllDevProjects/migrationtostandards2/ROLLOUT_PROMPT.md
and follow the verification checklist in VERIFICATION_CHECKLIST.md.

This is an app development project, so:
- Only reference Standards-v2/shared/ and Standards-v2/apps/
- Do NOT reference Standards-v2/infrastructure/
- Update all old Standards/ paths according to the mapping table

After completion, mark this project as complete in PROJECT_STATUS.md
```

## Migration Strategy

**Option A: Automated (Recommended)**
- Use the batch update script in QUICK_COMMANDS.md
- Run `verify-migration.sh` to check results
- Faster, consistent results

**Option B: Manual**
- Update each reference individually
- More time-consuming but more control
- Good for projects with few references

**Option C: AI Agent**
- Provide the prompt above to Claude Code
- Agent reads instructions and performs migration
- Review changes before committing

## Timeline

- **Day 0-2:** Both Standards/ and Standards-v2/ coexist
- **Day 2:** Old Standards/ directory will be deleted
- **Deadline:** Update all projects before Day 2

## Resources

- **Migration Guide:** `/mnt/foundry_project/Forge/Standards-v2/MIGRATION.md`
- **New Standards README:** `/mnt/foundry_project/Forge/Standards-v2/README.md`
- **Infrastructure Script:** `/mnt/foundry_project/Forge/scripts/migrate-standards-references.sh` (for infrastructure repos)

## Support

Questions? Check:
1. ROLLOUT_PROMPT.md for common questions
2. Standards-v2/MIGRATION.md for complete path mappings
3. Standards-v2/README.md for directory structure
4. Ask infrastructure team if still unclear
