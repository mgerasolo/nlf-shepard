# AI Migration Instructions: Phase to Infisical

> **Audience:** AI agents (Claude Code, etc.)
> **Purpose:** Automate migration from Phase to Infisical secrets management
> **Trigger:** When detecting Phase references in project being worked on

---

## Detection Triggers

Run migration when you detect any of:
- `phase secrets` commands in scripts
- `PHASE_SERVICE_TOKEN` or `PHASE_HOST` environment variables
- `phase-secrets.sh` or `phase-setup.sh` scripts
- Documentation mentioning "Phase" as current secrets tool
- `phase` CLI invocations

**Do NOT migrate:**
- Historical references in changelogs
- Deprecation warnings (keep them)
- Already-migrated projects (check for `infisical` usage)

---

## Pre-Migration Checklist

Before starting, verify:

1. **Infisical CLI available:**
   ```bash
   which infisical || echo "BLOCKED: Infisical CLI not installed"
   ```

2. **Infisical authenticated:**
   ```bash
   infisical secrets list --env prod 2>/dev/null || echo "BLOCKED: Not authenticated"
   ```

3. **Phase CLI available** (for export):
   ```bash
   which phase || echo "WARNING: Phase CLI not available - manual export needed"
   ```

4. **Backup exists:**
   ```bash
   ls ~/.secrets/*.env.backup 2>/dev/null || echo "WARNING: Create backup first"
   ```

If any BLOCKED items, stop and notify user.

---

## Migration Workflow

### Step 1: Identify Phase Usage

Search for Phase references:
```bash
# Find Phase CLI commands
grep -r "phase secrets" --include="*.sh" --include="*.md" .

# Find Phase environment variables
grep -r "PHASE_SERVICE_TOKEN\|PHASE_HOST" --include="*.sh" --include="*.env*" .

# Find Phase scripts
find . -name "*phase*.sh" -type f
```

**Document findings:**
- List files with Phase references
- Note which are active vs. historical
- Identify scripts vs. documentation

### Step 2: Export Secrets (if needed)

If Phase CLI is available and secrets not yet in .env:
```bash
# Export from Phase
phase secrets export --app "APP_NAME" --env "ENV_NAME" --format dotenv > /tmp/phase-export.env

# Merge into .env fallback
cat /tmp/phase-export.env >> ~/.secrets/nlf-infrastructure.env
rm /tmp/phase-export.env
```

**Verify export:**
```bash
# Check .env file has all expected secrets
source ~/.secrets/nlf-infrastructure.env
echo "Checking: $PORTAINER_USERNAME"  # Should not be empty
```

### Step 3: Import to Infisical

Create/verify Infisical project:
```bash
# List existing projects
infisical projects list

# Create if needed (get project ID from output)
infisical projects create --name "Project Name"
```

Import secrets:
```bash
# From .env file
infisical secrets import --env prod --path / < ~/.secrets/nlf-infrastructure.env

# Or set individually
infisical secrets set SECRET_NAME="value" --env prod
```

**Verify import:**
```bash
# List all secrets
infisical secrets list --env prod

# Test retrieval
infisical secrets get SECRET_NAME --env prod --plain
```

### Step 4: Update Scripts

Replace Phase CLI commands with Infisical:

**Pattern 1: Direct secret retrieval**
```bash
# OLD
phase secrets get SECRET_NAME --app "APP" --env "ENV"

# NEW
infisical secrets get SECRET_NAME --env prod --plain
```

**Pattern 2: Exporting all secrets**
```bash
# OLD
phase secrets export --app "APP" --env "ENV" --format dotenv

# NEW
infisical secrets export --format dotenv --env prod
```

**Pattern 3: Using helper functions**
```bash
# OLD
source scripts/phase-secrets.sh
TOKEN=$(phase_get PORTAINER_PASSWORD)

# NEW (no change - helpers are compatible)
source scripts/secrets.sh
TOKEN=$(secret_get PORTAINER_PASSWORD)
```

**Files to update:**
- `scripts/*-secrets.sh` → Use `secrets.sh` instead
- `scripts/*-setup.sh` → Update installation/auth instructions
- `.env.example` or similar → Update comments
- CI/CD configs → Update secret injection

### Step 5: Update Documentation

**In markdown files:**
```markdown
<!-- OLD -->
Secrets are managed via Phase. Use:
```bash
phase secrets get SECRET_NAME
```

<!-- NEW -->
Secrets are managed via Infisical. Use:
```bash
infisical secrets get SECRET_NAME --env prod --plain
# OR use helper script
source scripts/secrets.sh
secret_get SECRET_NAME
```
```

**Key documentation files:**
- `README.md` - Update secrets section
- `DEPLOYMENT.md` or `DEPLOYMENTS.md` - Update deployment instructions
- `docs/secrets.md` or similar - Update secrets documentation
- `.claude/CLAUDE.md` - Update if it references Phase

**Patterns to update:**
- "Using Phase" → "Using Infisical"
- "Phase service token" → "Infisical service token"
- "`phase secrets`" → "`infisical secrets`"
- Links to Phase docs → Links to Infisical docs

**Keep (mark as deprecated):**
- Historical references: "Previously used Phase (migrated 2025-12-26)"
- Deprecation warnings: "DEPRECATED: Phase CLI is no longer used"

### Step 6: Update Helper Scripts

If project has custom secrets helper:

```bash
# Check for phase-specific functions
grep -n "phase_get\|load_phase\|PHASE_" scripts/*.sh

# Update function names (if not using compatibility aliases)
phase_get → secret_get
load_phase_secrets → load_secrets
verify_phase_connection → verify_secrets_connection

# Update environment variables
PHASE_SERVICE_TOKEN → INFISICAL_TOKEN
PHASE_HOST → (remove, not needed)
```

**Preserve compatibility:**
If scripts are used by multiple projects, keep compatibility aliases:
```bash
# Add to helper script
phase_get() {
    secret_get "$@"
}
```

### Step 7: Verification

Run the verification script:
```bash
./verify-migration.sh --verify
```

**Manual checks:**
1. **Secret retrieval works:**
   ```bash
   source scripts/secrets.sh
   secret_get PORTAINER_PASSWORD  # Should return value
   ```

2. **Fallback works:**
   ```bash
   # Temporarily disable Infisical
   export INFISICAL_TOKEN=""
   source scripts/secrets.sh
   secret_get PORTAINER_PASSWORD  # Should still work from .env
   ```

3. **No Phase commands remain:**
   ```bash
   grep -r "phase secrets\|phase run" --include="*.sh" . | grep -v "DEPRECATED\|historical"
   # Should return nothing (or only deprecated/historical)
   ```

4. **Documentation updated:**
   ```bash
   grep -r "Using Phase" --include="*.md" . | grep -v "Previously\|DEPRECATED"
   # Should return nothing
   ```

### Step 8: Cleanup

**Safe to remove:**
- `scripts/phase-secrets.sh` (if not used by other projects)
- `scripts/phase-setup.sh` (if not needed for reference)
- `.phase/` directory (after backing up tokens)
- Phase service tokens (from environment)

**Keep for reference:**
- `.env.backup` files (for rollback)
- Documentation of old Phase setup (mark as deprecated)

**Archive approach:**
```bash
# Create archive directory
mkdir -p scripts/#archived

# Move Phase-specific scripts
mv scripts/phase-*.sh scripts/#archived/

# Add deprecation notice
echo "DEPRECATED: Migrated to Infisical on $(date)" > scripts/#archived/README.md
```

---

## Common Issues and Solutions

### Issue: Infisical CLI not authenticated

**Symptoms:**
- `infisical secrets list` returns auth error
- Can't import/export secrets

**Solution:**
```bash
# Interactive login
infisical login

# OR use service token
export INFISICAL_TOKEN="st.xxx.yyy.zzz"
```

### Issue: Secret names differ between Phase and Infisical

**Symptoms:**
- Some secrets not found after migration
- Different naming conventions

**Solution:**
```bash
# List secrets in both systems
phase secrets list --app "APP" --env "ENV"
infisical secrets list --env prod

# Compare and rename in Infisical if needed
infisical secrets set NEW_NAME="$(infisical secrets get OLD_NAME --plain)" --env prod
infisical secrets delete OLD_NAME --env prod
```

### Issue: Fallback .env doesn't work

**Symptoms:**
- Secrets not loaded when Infisical unavailable
- Empty values returned

**Solution:**
```bash
# Check .env file format
cat ~/.secrets/nlf-infrastructure.env
# Should have: export SECRET_NAME="value"

# Verify sourcing works
source ~/.secrets/nlf-infrastructure.env
echo $SECRET_NAME  # Should not be empty

# Fix format if needed
sed -i 's/^SECRET_/export SECRET_/' ~/.secrets/nlf-infrastructure.env
```

### Issue: Scripts still reference Phase functions

**Symptoms:**
- `phase_get: command not found`
- Old function names fail

**Solution:**
```bash
# Add compatibility aliases to secrets.sh
cat >> scripts/secrets.sh <<'EOF'

# === Backward Compatibility (Phase) ===
phase_get() {
    echo "WARNING: phase_get is deprecated, use secret_get" >&2
    secret_get "$@"
}
EOF
```

---

## Testing Checklist

After migration, verify:

- [ ] `infisical secrets list --env prod` works
- [ ] `source scripts/secrets.sh && secret_get PORTAINER_PASSWORD` returns value
- [ ] Fallback works (test with `INFISICAL_TOKEN=""`)
- [ ] No active Phase CLI commands in code
- [ ] Documentation mentions Infisical as current tool
- [ ] Phase references marked as deprecated/historical
- [ ] Verification script passes
- [ ] Application deployments still work
- [ ] CI/CD pipelines updated (if applicable)

---

## Output Format

After migration, provide summary:

```markdown
## Migration Complete: Phase → Infisical

**Secrets migrated:** X secrets from Phase to Infisical
**Files updated:**
- scripts/secrets.sh (updated to use Infisical)
- README.md (updated secrets section)
- docs/deployment.md (updated instructions)

**Phase references removed:**
- scripts/phase-secrets.sh → archived
- Documentation updated (5 files)

**Verification:**
- ✓ Infisical connection works
- ✓ Fallback .env works
- ✓ All secrets retrievable
- ✓ No active Phase references

**Next steps:**
- User should verify application deployments
- Consider removing Phase CLI if no longer needed
- Update team documentation if applicable
```

---

## Edge Cases

### Multiple Projects

If migrating multiple related projects:
1. Migrate infrastructure first
2. Then app-specific projects
3. Update shared documentation last
4. Test each project independently

### Existing Infisical Setup

If project partially migrated:
1. Check which secrets are already in Infisical
2. Migrate remaining secrets only
3. Update documentation for consistency
4. Remove Phase references

### Custom Secret Patterns

If project uses non-standard patterns:
1. Document custom usage before changing
2. Test extensively after migration
3. Keep compatibility layer longer
4. Update gradually if needed

---

## Reference

**Infisical CLI docs:** https://infisical.com/docs/cli/overview
**NLF Secrets standard:** `/mnt/foundry_project/Forge/Standards-v2/shared/secrets.md`
**Helper script:** `~/Infrastructure/scripts/secrets.sh`

**Common Infisical commands:**
```bash
# List secrets
infisical secrets list --env prod

# Get secret
infisical secrets get SECRET_NAME --env prod --plain

# Set secret
infisical secrets set SECRET_NAME="value" --env prod

# Export all
infisical secrets export --format dotenv --env prod

# Import from file
infisical secrets import --env prod < secrets.env
```
