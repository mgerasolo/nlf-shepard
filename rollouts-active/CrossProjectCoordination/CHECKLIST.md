# Cross-Project Coordination Rollout Checklist

Use this checklist for each project during rollout.

## Pre-Rollout

- [ ] Identify project type (core/plugin/standalone)
- [ ] List upstream dependencies (if plugin)
- [ ] List downstream dependents (if core)
- [ ] Verify GitHub CLI installed and authenticated (`gh auth status`)
- [ ] Verify Infisical integration working (`source ~/Infrastructure/scripts/secrets.sh && secret_get TEST_KEY`)

## Per-Project Rollout

**Project:** ___________________________
**Type:** ⬜ Core ⬜ Plugin ⬜ Standalone
**Dependencies:** ___________________________
**Dependents:** ___________________________

### 1. Add Helper Script
- [ ] Create `scripts/check-dependencies.sh` with correct template (core vs plugin)
- [ ] Replace `{PROJECT_ID}` with actual project ID
- [ ] Replace `{DEPENDENCIES_ARRAY}` or `{DEPENDENTS_ARRAY}` with actual projects
- [ ] Make executable: `chmod +x scripts/check-dependencies.sh`
- [ ] Test: `./scripts/check-dependencies.sh` runs without errors

### 2. Update CLAUDE.md
- [ ] Add "Cross-Project Coordination" section
- [ ] Use correct template for project type (core vs plugin)
- [ ] Replace all variables (`{PROJECT_ID}`, `{DEPENDENCY}`, etc.)
- [ ] Verify bash commands are syntactically correct
- [ ] Test: Read CLAUDE.md, verify instructions make sense

### 3. Create GitHub Labels
- [ ] `breaking:next-release` - #d73a4a
- [ ] `breaking:deployed` - #b60205
- [ ] `provides` - #0e8a16
- [ ] `blocked` - #fbca04
- [ ] `upstream-breaking` - #d93f0b
- [ ] **If core:** Create `blocks:{dependent}` for each dependent
- [ ] **If plugin:** Create `depends-on:{dependency}` for each dependency

### 4. Test Coordination
- [ ] Run `./scripts/check-dependencies.sh` - verify output
- [ ] Create test issue with `breaking:next-release` label (core) or `blocked` label (plugin)
- [ ] Verify test issue appears in script output
- [ ] Open new Claude Code session
- [ ] **If plugin:** Verify Claude mentions checking for upstream changes
- [ ] Delete test issue

### 5. Update Registry
- [ ] Update `projects.json` rollout status to "completed"
- [ ] Commit changes: `git add . && git commit -m "Add cross-project coordination to {PROJECT_NAME}"`

## Post-Rollout Verification

- [ ] Script exists: `ls -la scripts/check-dependencies.sh`
- [ ] Script is executable: `test -x scripts/check-dependencies.sh && echo "✓ Executable"`
- [ ] CLAUDE.md has coordination section: `grep -q "Cross-Project Coordination" CLAUDE.md && echo "✓ Found"`
- [ ] Labels created: `gh label list | grep -E "(breaking|blocked|provides)"`
- [ ] Projects registry updated: `grep -A 2 '"CrossProjectCoordination"' ~/ShepardProtocol/projects.json`

## Troubleshooting

### Script fails with "gh: command not found"
```bash
# Install GitHub CLI
brew install gh  # macOS
# or
sudo apt install gh  # Ubuntu/Debian

# Authenticate
gh auth login
```

### Labels already exist
```bash
# Delete and recreate
gh label delete "breaking:next-release" --yes
gh label create "breaking:next-release" --color "d73a4a" --description "Breaking change coming in next release"
```

### Claude doesn't auto-check dependencies
- Verify CLAUDE.md section is present and correctly formatted
- Try explicit: "Check for upstream breaking changes"
- Ensure bash commands in CLAUDE.md are in code blocks
- Check that project dependencies are correctly listed

### Script shows no results
- Expected if no issues with coordination labels exist yet
- Create test issue to verify script works
- Check repo names are correct in script

## Rollout Complete

**Date:** _______________
**Completed by:** _______________
**Notes:** _______________________________________________________________

---

Move to next project in registry.
