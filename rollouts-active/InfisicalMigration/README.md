# Infisical Migration Rollout

> **Status:** Active
> **Created:** 2025-12-26
> **Target:** All projects using Phase secrets management
> **Impact:** Critical - secrets management infrastructure change

---

## Overview

Migrate all secrets management from Phase to Infisical across all NLF projects. This ensures consistency, better access control, and unified secrets infrastructure.

**What changes:**
- Phase CLI replaced with Infisical CLI
- `phase secrets` commands → `infisical secrets` commands
- Phase service tokens → Infisical service tokens
- Documentation updated to reflect Infisical as standard
- Fallback .env files remain unchanged (same format)

**What stays the same:**
- Helper script interface (`secrets.sh` functions)
- Fallback .env file paths (`~/.secrets/*.env`)
- Environment variable names
- Secret naming conventions

---

## Why This Migration

**Current state:**
- Infrastructure already uses Infisical (migrated 2025-12-23)
- Phase is deprecated in our stack
- Inconsistency between projects creates confusion

**Benefits:**
- Single secrets management platform
- Better UI and access controls
- More active development and support
- Unified audit trail
- Seamless fallback to .env files (same as before)

---

## Scope

### In Scope
- All references to Phase CLI in code and documentation
- Scripts using `phase secrets` commands
- Documentation mentioning Phase as current tool
- Service tokens and authentication
- Migration verification

### Out of Scope
- Historical references in changelogs (keep for context)
- Deprecation notices (keep as warnings)
- .env file format (unchanged)
- Environment variable names (unchanged)

---

## Time Estimate

**Per project:**
- Small project (1-5 secrets): 15-30 minutes
- Medium project (6-20 secrets): 30-60 minutes
- Large project (20+ secrets): 1-2 hours

**Activities:**
- Export secrets from Phase: 5 minutes
- Import to Infisical: 5-10 minutes
- Update scripts and docs: 15-30 minutes
- Verification: 10-15 minutes

---

## Prerequisites

Before starting migration:

1. **Infisical CLI installed:**
   ```bash
   curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash
   sudo apt-get update && sudo apt-get install -y infisical
   ```

2. **Infisical authentication:**
   ```bash
   infisical login
   # OR use service token
   export INFISICAL_TOKEN="your-token-here"
   ```

3. **Phase CLI still available** (for export):
   ```bash
   phase --version
   ```

4. **Backup existing .env files:**
   ```bash
   cp ~/.secrets/nlf-infrastructure.env ~/.secrets/nlf-infrastructure.env.backup
   cp ~/.secrets/nlf-appservices.env ~/.secrets/nlf-appservices.env.backup
   ```

---

## Migration Phases

### Phase 1: Export from Phase
Export all secrets to local .env files (if not already done)

### Phase 2: Import to Infisical
Create Infisical projects and import secrets

### Phase 3: Update Code
Replace Phase CLI usage with Infisical CLI

### Phase 4: Update Documentation
Remove Phase references, add Infisical references

### Phase 5: Verify
Test secret retrieval and fallback behavior

### Phase 6: Cleanup
Remove Phase CLI and old tokens

---

## Quick Start

For AI agents (see PROMPT_FOR_AI.md for detailed instructions):
```bash
# Run verification first
./verify-migration.sh --check

# If Phase detected, run migration
./verify-migration.sh --migrate

# Verify after migration
./verify-migration.sh --verify
```

For manual migration:
```bash
# See migration-guide.md for step-by-step instructions
cat migration-guide.md
```

---

## Success Criteria

Migration is complete when:

- [ ] All secrets accessible via Infisical CLI
- [ ] No Phase CLI commands in active code
- [ ] Documentation updated (Phase marked as deprecated)
- [ ] Verification script passes all checks
- [ ] Fallback .env files still work
- [ ] All scripts use Infisical or helper functions
- [ ] Service tokens updated

---

## Rollback Plan

If migration fails:

1. **Secrets still in Phase:** Continue using Phase temporarily
2. **Fallback .env files:** Always work regardless of CLI tool
3. **Helper scripts:** Backwards compatible (support both)
4. **No data loss:** Phase and Infisical both retain secrets

**Recovery steps:**
```bash
# Restore backup .env files
cp ~/.secrets/*.env.backup ~/.secrets/

# Re-authenticate with Phase
export PHASE_SERVICE_TOKEN="your-phase-token"

# Verify connection
phase secrets list
```

---

## Support

**Issues during migration:**
- Check verification script output
- Review migration-guide.md
- Test fallback .env files
- Check PROMPT_FOR_AI.md for AI-specific help

**Questions:**
- See `/mnt/foundry_project/Forge/Standards-v2/shared/secrets.md`
- Check Infrastructure/scripts/secrets.sh for helper functions

---

## Related Documents

- [PROMPT_FOR_AI.md](PROMPT_FOR_AI.md) - Detailed AI instructions
- [verify-migration.sh](verify-migration.sh) - Automated verification
- [migration-guide.md](migration-guide.md) - Manual migration steps
- [/mnt/foundry_project/Forge/Standards-v2/shared/secrets.md](../../../Forge/Standards-v2/shared/secrets.md) - Secrets standard
