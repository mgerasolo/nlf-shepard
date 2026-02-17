# Standards-v2 Migration Verification Checklist

Use this checklist to verify the migration was completed successfully.

## Pre-Migration

- [ ] Read [ROLLOUT_PROMPT.md](ROLLOUT_PROMPT.md) thoroughly
- [ ] Understand which standards are app-relevant (shared/ and apps/ only)
- [ ] Create a backup or commit current state before changes

## Migration Steps

- [ ] Scanned project for `Standards/` references
- [ ] Identified all files that need updating
- [ ] Updated paths according to mapping table
- [ ] Verified new paths are correct (app projects should only use shared/ and apps/)

## Verification

- [ ] **Run automated verification script (RECOMMENDED):**
  ```bash
  bash UpdateAllDevProjects/migrationtostandards2/verify-migration.sh
  ```
  _(This checks all items below automatically)_

- [ ] **All references updated:** No old `Standards/` paths remain
  ```bash
  grep -r "Standards/" . \
    --include="*.md" \
    --include="*.json" \
    --include="*.yml" \
    --include="*.yaml" \
    --include="*.sh" \
    --include=".env*" \
    --include="CLAUDE.md" \
    --exclude-dir="node_modules" \
    --exclude-dir=".git" \
    | grep -v "Standards-v2"
  ```
  _(Should return empty or only comments about the migration)_

- [ ] **Files exist:** All new referenced paths actually exist
  ```bash
  # Manually check a few key references
  ls /mnt/foundry_project/Forge/Standards-v2/shared/secrets.md
  ls /mnt/foundry_project/Forge/Standards-v2/shared/Containers/
  ```

- [ ] **Documentation renders:** Markdown links work correctly
  - Open README.md and verify links aren't broken
  - Check any documentation that references standards

- [ ] **CLAUDE.md updated:** If CLAUDE.md references standards, it's updated
  ```bash
  cat CLAUDE.md | grep "Standards/"
  ```

- [ ] **Build/tests pass:** Run project build or tests to verify nothing broke
  ```bash
  # Example - adjust for your project
  npm run build
  npm test
  ```

## App-Specific Checks

- [ ] **No infrastructure refs:** Verify you're NOT referencing `Standards-v2/infrastructure/`
  ```bash
  grep -r "Standards-v2/infrastructure" . \
    --include="*.md" \
    --include="*.json" \
    --include="*.yml" \
    --include="*.yaml" \
    --exclude-dir="node_modules" \
    --exclude-dir=".git"
  ```
  _(Should be empty for app projects - only use shared/ and apps/)_

- [ ] **Appropriate standards:** Only referencing app-relevant standards
  - ✓ Containers (shared)
  - ✓ Secrets (shared)
  - ✓ Security (shared)
  - ✓ Documentation format (shared)
  - ✓ Design specs (apps)
  - ✗ NOT infrastructure-specific files (ports, deployments, VM setup, etc.)

## Post-Migration

- [ ] **Commit changes:**
  ```bash
  git add .
  git commit -m "chore: migrate to Standards-v2 directory structure"
  ```

- [ ] **Test in development:** Verify application still works as expected

- [ ] **Clean up:** Remove this rollout directory after verification
  ```bash
  rm -rf UpdateAllDevProjects/migrationtostandards2
  ```

- [ ] **Mark complete:** Report migration completion

## Rollback (if needed)

If issues are found:

1. Revert the commit:
   ```bash
   git revert HEAD
   ```

2. Or restore from backup

3. Report issues for investigation

4. Old `Standards/` directory still exists for a few days as fallback

## Questions or Issues?

- Check `/mnt/foundry_project/Forge/Standards-v2/MIGRATION.md`
- Ask infrastructure team for clarification
- Verify you're using the correct paths for app projects (shared/ and apps/ only)
