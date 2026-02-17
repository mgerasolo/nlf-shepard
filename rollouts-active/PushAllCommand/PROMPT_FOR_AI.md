# AI Agent Deployment Instructions: PushAllCommand

**Rollout ID:** PushAllCommand
**Created:** 2025-12-26
**For:** Claude Code agents deploying `/push-all` command

---

## Quick Start

```bash
# Copy the source command to target project
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   /path/to/target-project/.claude/commands/push-all.md

# Verify file exists
ls -la /path/to/target-project/.claude/commands/push-all.md

# Set permissions
chmod 644 /path/to/target-project/.claude/commands/push-all.md
```

---

## Pre-Deployment Checklist

Before deploying to a project:

- [ ] Project has `.claude/` directory
- [ ] Project is actively maintained (not in experimental/paused list)
- [ ] Git repository is initialized
- [ ] No uncommitted changes in target project (or user aware)

---

## Deployment Steps

### 1. Identify Target Project

**Phase 1 (Critical):**
- Infrastructure: `/home/mgerasolo/Infrastructure/`

**Phase 2 (Critical/High):**
- AppBrain: `/mnt/foundry_project/Development/AppBrain/`
- Finance-Ingest: `/mnt/foundry_project/Development/finance-ingest/`
- DoughFlow: `/mnt/foundry_project/Development/DoughFlow/`
- Self-Improving AI: `/mnt/foundry_project/Development/self-improving-ai/`

**Phase 3 (Medium):**
- Admin: `/mnt/foundry_project/Development/admin/`
- Basic-Habits: `/mnt/foundry_project/Development/basic-habits/`
- Start.Matt: `/mnt/foundry_project/Development/start.matt/`
- Shadcn-Wireframer: `/mnt/foundry_project/Development/shadcn-wireframer/`

### 2. Copy Command File

```bash
# Set target project path
TARGET_PROJECT="/path/to/target-project"

# Copy the command
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   "${TARGET_PROJECT}/.claude/commands/push-all.md"

# Set correct permissions
chmod 644 "${TARGET_PROJECT}/.claude/commands/push-all.md"
```

### 3. Verify Installation

```bash
# Check file exists
ls -la "${TARGET_PROJECT}/.claude/commands/push-all.md"

# Check file size (should be ~555 lines, ~18KB)
wc -l "${TARGET_PROJECT}/.claude/commands/push-all.md"

# Verify it's readable
head -20 "${TARGET_PROJECT}/.claude/commands/push-all.md"
```

**Expected output:**
```
# Commit and Push Everything

⚠️ **CAUTION:** Use only when confident all changes belong together.
```

### 4. Update projects.json

```bash
# Read current projects.json
cat /mnt/foundry_project/AppServices/ShepardProtocol/projects.json

# Update the project's rollout status
# Add to deployed_rollouts array: "PushAllCommand"
```

**Example update:**
```json
{
  "name": "Infrastructure",
  "status": "active",
  "deployed_rollouts": [
    "Baton&PromptResponseFormat",
    "PushAllCommand"
  ]
}
```

### 5. Test Command (Optional)

If you want to verify the command works:

```bash
cd "${TARGET_PROJECT}"

# Check git status
git status

# The /push-all command is now available in Claude Code
# User can test by running: /push-all
```

### 6. Document Deployment

Update the rollout's README.md success criteria:

```markdown
## Success Criteria

- [x] `.claude/commands/push-all.md` created
- [x] Command follows NLF standards and patterns
- [x] Command deployed to Infrastructure ← UPDATE THIS
- [x] projects.json updated for Infrastructure ← UPDATE THIS
- [ ] Command deployed to all 10 active projects
- [ ] Rollout audit log updated
```

---

## Per-Project Deployment Commands

### Infrastructure (Phase 1)

```bash
# Already deployed (source location)
ls -la /home/mgerasolo/Infrastructure/.claude/commands/push-all.md

# Just verify and update projects.json
```

### AppBrain (Phase 2)

```bash
TARGET="/mnt/foundry_project/Development/AppBrain"
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   "${TARGET}/.claude/commands/push-all.md"
chmod 644 "${TARGET}/.claude/commands/push-all.md"
ls -la "${TARGET}/.claude/commands/push-all.md"
```

### Finance-Ingest (Phase 2)

```bash
TARGET="/mnt/foundry_project/Development/finance-ingest"
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   "${TARGET}/.claude/commands/push-all.md"
chmod 644 "${TARGET}/.claude/commands/push-all.md"
ls -la "${TARGET}/.claude/commands/push-all.md"
```

### DoughFlow (Phase 2)

```bash
TARGET="/mnt/foundry_project/Development/DoughFlow"
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   "${TARGET}/.claude/commands/push-all.md"
chmod 644 "${TARGET}/.claude/commands/push-all.md"
ls -la "${TARGET}/.claude/commands/push-all.md"
```

### Self-Improving AI (Phase 2)

```bash
TARGET="/mnt/foundry_project/Development/self-improving-ai"
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   "${TARGET}/.claude/commands/push-all.md"
chmod 644 "${TARGET}/.claude/commands/push-all.md"
ls -la "${TARGET}/.claude/commands/push-all.md"
```

### Admin (Phase 3)

```bash
TARGET="/mnt/foundry_project/Development/admin"
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   "${TARGET}/.claude/commands/push-all.md"
chmod 644 "${TARGET}/.claude/commands/push-all.md"
ls -la "${TARGET}/.claude/commands/push-all.md"
```

### Basic-Habits (Phase 3)

```bash
TARGET="/mnt/foundry_project/Development/basic-habits"
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   "${TARGET}/.claude/commands/push-all.md"
chmod 644 "${TARGET}/.claude/commands/push-all.md"
ls -la "${TARGET}/.claude/commands/push-all.md"
```

### Start.Matt (Phase 3)

```bash
TARGET="/mnt/foundry_project/Development/start.matt"
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   "${TARGET}/.claude/commands/push-all.md"
chmod 644 "${TARGET}/.claude/commands/push-all.md"
ls -la "${TARGET}/.claude/commands/push-all.md"
```

### Shadcn-Wireframer (Phase 3)

```bash
TARGET="/mnt/foundry_project/Development/shadcn-wireframer"
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   "${TARGET}/.claude/commands/push-all.md"
chmod 644 "${TARGET}/.claude/commands/push-all.md"
ls -la "${TARGET}/.claude/commands/push-all.md"
```

---

## Troubleshooting

### .claude/commands/ directory doesn't exist

```bash
# Create it
mkdir -p "${TARGET}/.claude/commands"

# Try again
cp /home/mgerasolo/Infrastructure/.claude/commands/push-all.md \
   "${TARGET}/.claude/commands/push-all.md"
```

### Source file doesn't exist

```bash
# Verify source
ls -la /home/mgerasolo/Infrastructure/.claude/commands/push-all.md

# If missing, it was moved or deleted - check rollout README for alternate location
```

### Permission denied

```bash
# Check ownership
ls -la "${TARGET}/.claude/commands/"

# Fix if needed
sudo chown mgerasolo:mgerasolo "${TARGET}/.claude/commands/push-all.md"
chmod 644 "${TARGET}/.claude/commands/push-all.md"
```

---

## Post-Deployment Verification

For each deployed project:

```bash
# 1. File exists and has correct size
ls -lh "${TARGET}/.claude/commands/push-all.md"
# Should be ~18K

# 2. File is readable
head -5 "${TARGET}/.claude/commands/push-all.md"
# Should show "# Commit and Push Everything"

# 3. File has correct permissions
stat -c "%a %n" "${TARGET}/.claude/commands/push-all.md"
# Should be 644
```

---

## Rollout Completion

When all projects deployed:

1. **Update rollout README:**
   - Mark all success criteria as complete
   - Add completion date

2. **Update projects.json:**
   - All 10 projects should have "PushAllCommand" in deployed_rollouts

3. **Create completion summary:**
   - Document any issues encountered
   - Note any projects that couldn't be deployed
   - Record total time and resources used

4. **Archive if needed:**
   - If rollout had issues, keep in `rollouts-active/`
   - If successful and stable, can move to `rollouts-complete/` after 1 week

---

## Notes

- This is a read-only file deployment - no configuration needed
- Projects can use or ignore the command - it's optional
- No breaking changes - existing git workflows still work
- Command includes safety checks to prevent accidental commits
- Baton integration auto-detects and links to conversations

---

## Related

- **Source:** `/home/mgerasolo/Infrastructure/.claude/commands/push-all.md`
- **Rollout README:** `/mnt/foundry_project/AppServices/ShepardProtocol/rollouts-active/PushAllCommand/README.md`
- **Projects registry:** `/mnt/foundry_project/AppServices/ShepardProtocol/projects.json`
