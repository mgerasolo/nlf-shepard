# Phase to Infisical Migration Guide

> **For:** Manual migration by users
> **Time:** 30-60 minutes per project
> **Prerequisites:** Infisical CLI installed and authenticated

---

## Table of Contents

1. [Pre-Migration](#pre-migration)
2. [Step 1: Backup Current Setup](#step-1-backup-current-setup)
3. [Step 2: Export from Phase](#step-2-export-from-phase)
4. [Step 3: Import to Infisical](#step-3-import-to-infisical)
5. [Step 4: Update Scripts](#step-4-update-scripts)
6. [Step 5: Update Documentation](#step-5-update-documentation)
7. [Step 6: Verify Migration](#step-6-verify-migration)
8. [Step 7: Cleanup](#step-7-cleanup)
9. [Troubleshooting](#troubleshooting)

---

## Pre-Migration

### Install Infisical CLI

```bash
# Ubuntu/Debian
curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash
sudo apt-get update
sudo apt-get install -y infisical
```

### Authenticate with Infisical

Choose one method:

**Method 1: Interactive login**
```bash
infisical login
```

**Method 2: Service token**
```bash
export INFISICAL_TOKEN="st.xxx.yyy.zzz"
```

### Verify authentication

```bash
infisical whoami
```

---

## Step 1: Backup Current Setup

### Backup .env files

```bash
# Create backup directory
mkdir -p ~/.secrets/backups/$(date +%Y%m%d)

# Backup infrastructure secrets
cp ~/.secrets/nlf-infrastructure.env ~/.secrets/backups/$(date +%Y%m%d)/

# Backup app services secrets (if exists)
cp ~/.secrets/nlf-appservices.env ~/.secrets/backups/$(date +%Y%m%d)/ 2>/dev/null || true

# Verify backup
ls -lh ~/.secrets/backups/$(date +%Y%m%d)/
```

### Backup Phase tokens (optional)

```bash
# If you have Phase CLI configured
cp -r ~/.phase ~/.secrets/backups/$(date +%Y%m%d)/ 2>/dev/null || true
```

---

## Step 2: Export from Phase

### Option A: Phase CLI available

If you still have Phase CLI and access:

```bash
# Export infrastructure secrets
phase secrets export \
  --app "NLF-Infrastructure" \
  --env "Production" \
  --format dotenv \
  > /tmp/phase-export-infra.env

# Export app services secrets (if applicable)
phase secrets export \
  --app "NLF-AppServices" \
  --env "Production" \
  --format dotenv \
  > /tmp/phase-export-apps.env 2>/dev/null || true
```

### Option B: Use existing .env files

If Phase is no longer accessible, use existing .env files:

```bash
# Infrastructure secrets already in .env
cp ~/.secrets/nlf-infrastructure.env /tmp/phase-export-infra.env

# App services secrets already in .env
cp ~/.secrets/nlf-appservices.env /tmp/phase-export-apps.env 2>/dev/null || true
```

### Verify export

```bash
# Check exported files
cat /tmp/phase-export-infra.env | head -n 5
echo "Total secrets: $(grep -c "^[A-Z]" /tmp/phase-export-infra.env)"
```

---

## Step 3: Import to Infisical

### Create or verify Infisical project

```bash
# List existing projects
infisical projects list

# If project doesn't exist, create it
infisical projects create --name "NLF-Infrastructure"
# Note the project ID from output
```

### Import secrets

**For Infrastructure project:**
```bash
# Set project ID (from project list or create command)
export INFISICAL_PROJECT_ID="your-project-id-here"

# Import from file
infisical secrets import --env prod --path / < /tmp/phase-export-infra.env

# Or set manually
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# || "$key" =~ ^export ]] && continue
  # Remove 'export ' prefix if present
  key="${key#export }"
  key="${key## }" # trim leading spaces
  infisical secrets set "$key"="$value" --env prod
done < /tmp/phase-export-infra.env
```

**For AppServices project (if applicable):**
```bash
# Set AppServices project ID
export INFISICAL_PROJECT_ID="your-appservices-project-id"

# Import
infisical secrets import --env prod --path / < /tmp/phase-export-apps.env
```

### Verify import

```bash
# List all secrets in Infisical
infisical secrets list --env prod

# Test retrieval of specific secret
infisical secrets get PORTAINER_USERNAME --env prod --plain
```

---

## Step 4: Update Scripts

### Update secrets.sh (if project-specific)

If your project has its own `secrets.sh`:

**Find Phase references:**
```bash
grep -n "phase" scripts/secrets.sh
```

**Replace with Infisical:**
```bash
# OLD
phase secrets get "$key" --app "APP" --env "ENV"

# NEW
infisical secrets get "$key" --env prod --plain --projectId="$PROJECT_ID"
```

**Or use the standard helper:**
```bash
# Instead of custom script, use:
source ~/Infrastructure/scripts/secrets.sh
```

### Update deployment scripts

**Find Phase usage:**
```bash
grep -r "phase secrets" --include="*.sh" scripts/
```

**Common replacements:**

```bash
# Pattern 1: Get single secret
# OLD:
TOKEN=$(phase secrets get PORTAINER_PASSWORD --app "APP" --env "ENV")

# NEW:
source ~/Infrastructure/scripts/secrets.sh
TOKEN=$(secret_get PORTAINER_PASSWORD)
```

```bash
# Pattern 2: Export all secrets
# OLD:
phase secrets export --app "APP" --env "ENV" --format dotenv > .env

# NEW:
infisical secrets export --env prod --format dotenv > .env
```

```bash
# Pattern 3: Run command with secrets
# OLD:
phase run --app "APP" --env "ENV" -- docker compose up

# NEW:
source ~/Infrastructure/scripts/secrets.sh
load_secrets
docker compose up
```

---

## Step 5: Update Documentation

### Find Phase references

```bash
grep -r "Phase" --include="*.md" . | grep -v "DEPRECATED"
```

### Update README.md

**OLD:**
```markdown
## Secrets Management

Secrets are managed via Phase CLI.

### Setup
```bash
phase auth login
phase secrets get SECRET_NAME --app "APP" --env "ENV"
```
```

**NEW:**
```markdown
## Secrets Management

Secrets are managed via Infisical with automatic fallback to local .env files.

### Setup
```bash
# Primary: Use Infisical
infisical login
infisical secrets get SECRET_NAME --env prod --plain

# OR use helper script
source ~/Infrastructure/scripts/secrets.sh
secret_get SECRET_NAME
```

**Note:** If Infisical is unavailable, secrets are loaded from `~/.secrets/nlf-infrastructure.env`
```

### Update other docs

Update any of these files if they exist:
- `DEPLOYMENT.md` or `DEPLOYMENTS.md`
- `docs/secrets.md`
- `CONTRIBUTING.md`
- `.claude/CLAUDE.md`
- Service-specific README files

**Search and replace patterns:**
- "Phase CLI" → "Infisical CLI"
- "phase secrets" → "infisical secrets"
- "Phase service token" → "Infisical service token"
- "console.phase.dev" → "app.infisical.com"

**Add deprecation notices where appropriate:**
```markdown
> **Note:** This project previously used Phase for secrets management.
> Migrated to Infisical on 2025-12-26.
```

---

## Step 6: Verify Migration

### Run verification script

```bash
cd /mnt/foundry_project/AppServices/ShepardProtocol/rollouts-active/InfisicalMigration
./verify-migration.sh --verify
```

### Manual verification

**Test Infisical retrieval:**
```bash
source ~/Infrastructure/scripts/secrets.sh
secret_get PORTAINER_USERNAME
# Should return your username
```

**Test fallback:**
```bash
# Temporarily break Infisical auth
export INFISICAL_TOKEN=""
source ~/Infrastructure/scripts/secrets.sh
secret_get PORTAINER_USERNAME
# Should still work from .env file
```

**Check for Phase references:**
```bash
# Should return nothing (or only deprecated/historical)
grep -r "phase secrets" --include="*.sh" . | grep -v "#archived" | grep -v "DEPRECATED"
```

**Test application deployment:**
```bash
# Try deploying an app or running a script that uses secrets
# Verify it works with Infisical
```

---

## Step 7: Cleanup

### Archive Phase scripts

```bash
# Create archive directory
mkdir -p scripts/#archived

# Move Phase-specific scripts
mv scripts/phase-secrets.sh scripts/#archived/ 2>/dev/null || true
mv scripts/phase-setup.sh scripts/#archived/ 2>/dev/null || true

# Add deprecation notice
cat > scripts/#archived/README.md <<'EOF'
# Archived Phase Scripts

These scripts are deprecated and no longer used.

**Migration date:** $(date +%Y-%m-%d)
**Replaced by:** Infisical secrets management
**See:** /mnt/foundry_project/Forge/Standards-v2/shared/secrets.md
EOF
```

### Remove Phase tokens (optional)

```bash
# Only if you're completely done with Phase
rm -rf ~/.phase
unset PHASE_SERVICE_TOKEN
```

### Clean up temporary files

```bash
# Remove exports
rm /tmp/phase-export-*.env

# Keep backups!
# Do NOT remove ~/.secrets/backups/
```

---

## Troubleshooting

### Issue: "infisical: command not found"

**Solution:**
```bash
# Install Infisical CLI
curl -1sLf 'https://dl.cloudsmith.io/public/infisical/infisical-cli/setup.deb.sh' | sudo -E bash
sudo apt-get update && sudo apt-get install -y infisical
```

### Issue: "Unauthorized" when accessing secrets

**Solutions:**

1. **Re-authenticate:**
   ```bash
   infisical login
   ```

2. **Check project ID:**
   ```bash
   # Make sure you're using the right project
   infisical projects list
   ```

3. **Verify service token (if using):**
   ```bash
   echo $INFISICAL_TOKEN
   # Should start with "st."
   ```

### Issue: Secrets not found in Infisical

**Solution:**
```bash
# List all secrets to verify import
infisical secrets list --env prod

# If missing, import again
infisical secrets import --env prod < ~/.secrets/nlf-infrastructure.env
```

### Issue: .env fallback not working

**Check .env file format:**
```bash
cat ~/.secrets/nlf-infrastructure.env

# Should have lines like:
# export SECRET_NAME="value"
# OR
# SECRET_NAME=value
```

**Fix format if needed:**
```bash
# Add 'export' prefix if missing
sed -i 's/^PORTAINER/export PORTAINER/' ~/.secrets/nlf-infrastructure.env
```

### Issue: "Too many Phase references" in verification

**Find and review each:**
```bash
# List all Phase references
grep -r "phase" --include="*.sh" --include="*.md" .

# Determine which are:
# - Active code (needs update)
# - Historical references (can stay)
# - Deprecated notices (should stay)
```

**Update active code only.**

### Issue: Application deployments fail after migration

**Debug steps:**

1. **Check secret retrieval:**
   ```bash
   source scripts/secrets.sh
   secret_get PORTAINER_PASSWORD  # Should work
   ```

2. **Test Infisical directly:**
   ```bash
   infisical secrets get PORTAINER_PASSWORD --env prod --plain
   ```

3. **Check .env fallback:**
   ```bash
   grep PORTAINER_PASSWORD ~/.secrets/nlf-infrastructure.env
   ```

4. **Review script changes:**
   ```bash
   git diff scripts/
   # Make sure replacements are correct
   ```

---

## Rollback

If something goes wrong:

### Restore from backup

```bash
# Restore .env files
cp ~/.secrets/backups/$(date +%Y%m%d)/* ~/.secrets/

# Restore Phase config (if backed up)
cp -r ~/.secrets/backups/$(date +%Y%m%d)/.phase ~/.phase

# Test
source ~/.secrets/nlf-infrastructure.env
echo $PORTAINER_USERNAME  # Should not be empty
```

### Revert code changes

```bash
# If using git
git restore scripts/
git restore *.md

# Or restore from backup
cp /path/to/backup/scripts/* scripts/
```

---

## Post-Migration

### Update team

If working in a team:
1. Notify team members of migration
2. Share Infisical project access
3. Update team documentation
4. Deprecate Phase access

### Update CI/CD

If using CI/CD pipelines:
1. Update secrets injection
2. Replace Phase tokens with Infisical tokens
3. Test pipeline runs
4. Update pipeline documentation

### Monitor

For the first week after migration:
- Watch for secret retrieval errors
- Verify fallback works when needed
- Check application deployments
- Monitor logs for Phase-related errors

---

## Next Steps

After successful migration:

1. **Remove Phase CLI** (optional):
   ```bash
   sudo rm /usr/local/bin/phase
   ```

2. **Update other projects** using the same process

3. **Document project-specific notes** in service documentation

4. **Share feedback** on migration process for future improvements

---

## Support

**Questions or issues:**
- Review [PROMPT_FOR_AI.md](PROMPT_FOR_AI.md) for detailed technical info
- Check [verify-migration.sh](verify-migration.sh) for automated checks
- See [README.md](README.md) for overview

**Standards reference:**
- `/mnt/foundry_project/Forge/Standards-v2/shared/secrets.md`
- `~/Infrastructure/scripts/secrets.sh`
