# AI Rollout Prompt: Cross-Project Coordination

**Task:** Add cross-project dependency coordination to {PROJECT_NAME}

## Context

You are adding automated dependency tracking between interdependent projects. This enables Claude Code sessions to automatically check for upstream breaking changes, downstream blockers, and cross-project dependencies.

## Project Information

- **Project:** {PROJECT_NAME}
- **Path:** {PROJECT_PATH}
- **Type:** {PROJECT_TYPE} (core/plugin/standalone)
- **Dependencies:** {DEPENDENCIES} (comma-separated project names)
- **Dependents:** {DEPENDENTS} (comma-separated project names)

## Steps

### 1. Determine Coordination Needs

**If project type is "standalone":**
- Skip this rollout (no coordination needed)
- Mark as "skipped" in projects.json

**If project type is "core" or "plugin":**
- Proceed with rollout

### 2. Add Helper Script

Create `scripts/check-dependencies.sh`:

**For core/framework projects:**
```bash
#!/bin/bash
# Check which projects depend on this core framework

REPO_OWNER="mgerasolo"
REPO_NAME="{PROJECT_ID}"

echo "=== Projects Depending on ${REPO_NAME} ==="

# Add dependent repos here
DEPENDENTS="{DEPENDENTS_ARRAY}"

for dep in $DEPENDENTS; do
    echo ""
    echo "--- $dep ---"
    gh issue list --repo "${REPO_OWNER}/${dep}" \
        --search "depends-on:${REPO_NAME}" \
        --json number,title \
        --template '{{range .}}#{{.number}}: {{.title}}{{"\n"}}{{end}}'
done

echo ""
echo "=== Breaking Changes in This Repo ==="
gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" \
    --label "breaking:next-release" \
    --json number,title,createdAt \
    --template '{{range .}}#{{.number}}: {{.title}} ({{timeago .createdAt}}){{"\n"}}{{end}}'
```

**For plugin/consumer projects:**
```bash
#!/bin/bash
# Check upstream dependencies for breaking changes

REPO_OWNER="mgerasolo"
DEPENDENCIES="{DEPENDENCIES_ARRAY}"

echo "=== Upstream Breaking Changes ==="

for dep in $DEPENDENCIES; do
    echo ""
    echo "--- $dep ---"
    gh issue list --repo "${REPO_OWNER}/${dep}" \
        --label "breaking:next-release" \
        --json number,title,body \
        --template '{{range .}}#{{.number}}: {{.title}}{{"\n"}}{{end}}'
done

echo ""
echo "=== Blocking Issues in This Project ==="
gh issue list --repo "${REPO_OWNER}/{PROJECT_ID}" \
    --label "blocked" \
    --json number,title,labels
```

Make executable:
```bash
chmod +x scripts/check-dependencies.sh
```

### 3. Update CLAUDE.md

Add section based on project type.

**For core/framework projects:**

```markdown
## Cross-Project Coordination

**Before making breaking changes:**

1. Check dependent projects:
```bash
./scripts/check-dependencies.sh
# Or manually:
gh issue list --repo mgerasolo/{DEPENDENT_PROJECT} --search "depends-on:{PROJECT_ID}" --json number,title
```

2. Create notification issue:
```bash
gh issue create --title "Breaking: [description]" \
  --label "breaking:next-release" \
  --body "**Impact:** [affected areas]
**Timeline:** [merge date]
**Migration:** [steps needed]
**Affects:** {COMMA_SEPARATED_DEPENDENTS}"
```

3. After merge, update Infisical state:
```bash
source ~/Infrastructure/scripts/secrets.sh
secret_set {PROJECT_ID_UPPER}_BREAKING_CHANGES "$(gh issue list --label breaking:next-release --json number,title --jq '[.[] | "#\(.number): \(.title)"] | join(",")')"
secret_set {PROJECT_ID_UPPER}_VERSION "$(git describe --tags --abbrev=0)"
```

**Cross-project labels:**
- `breaking:next-release` - Breaking change coming soon
- `provides:feature-name` - New capability available
- `blocks:{project-name}` - Blocker for specific project
```

**For plugin/consumer projects:**

```markdown
## Cross-Project Coordination

**At session start, check upstream dependencies:**

```bash
./scripts/check-dependencies.sh

# Or check Infisical state:
source ~/Infrastructure/scripts/secrets.sh
{FOR_EACH_DEPENDENCY}
BREAKING=$(secret_get {DEPENDENCY_UPPER}_BREAKING_CHANGES)
[[ -n "$BREAKING" ]] && echo "⚠️  {DEPENDENCY} breaking changes: $BREAKING"
{END_FOR_EACH}
```

**When blocked by upstream, create tracking issue:**
```bash
gh issue create \
  --title "Blocked: Waiting for {DEPENDENCY} #{NUMBER}" \
  --label "blocked,depends-on:{DEPENDENCY}#{NUMBER}" \
  --body "Blocked by {DEPENDENCY}#{NUMBER} - [description]"
```

**Before submitting PR:**
```bash
# Verify compatibility with latest upstream
{FOR_EACH_DEPENDENCY}
{DEPENDENCY_UPPER}_VERSION=$(gh api repos/mgerasolo/{DEPENDENCY}/releases/latest --jq .tag_name)
echo "Testing against {DEPENDENCY} ${DEPENDENCY_UPPER}_VERSION"
{END_FOR_EACH}
```
```

### 4. Create GitHub Labels

Run for this project's repo:

```bash
gh label create "breaking:next-release" --color "d73a4a" --description "Breaking change coming in next release"
gh label create "breaking:deployed" --color "b60205" --description "Breaking change now deployed"
gh label create "provides" --color "0e8a16" --description "Provides new feature/capability"
gh label create "blocked" --color "fbca04" --description "Blocked by external dependency"
gh label create "upstream-breaking" --color "d93f0b" --description "Needs update for upstream breaking change"

# Add blocks: labels for each dependent (core projects only)
{FOR_EACH_DEPENDENT}
gh label create "blocks:{DEPENDENT}" --color "e99695" --description "Blocks {DEPENDENT} project"
{END_FOR_EACH}

# Add depends-on: labels for each dependency (plugin projects only)
{FOR_EACH_DEPENDENCY}
gh label create "depends-on:{DEPENDENCY}" --color "c5def5" --description "Depends on {DEPENDENCY} project"
{END_FOR_EACH}
```

### 5. Test Coordination

**For core projects:**
```bash
# Test dependency check
./scripts/check-dependencies.sh

# Create test breaking change issue
gh issue create --title "Test: Breaking change notification" --label "breaking:next-release"
```

**For plugin projects:**
```bash
# Test upstream check
./scripts/check-dependencies.sh

# Verify Claude reads upstream state at session start
# (Open new Claude Code session, verify it checks for breaking changes)
```

### 6. Update Projects Registry

In `/mnt/foundry_project/AppServices/ShepardProtocol/projects.json`:

```json
{
  "rollouts": {
    "CrossProjectCoordination": "completed"
  }
}
```

## Variables to Replace

- `{PROJECT_NAME}` - Display name
- `{PROJECT_PATH}` - Full filesystem path
- `{PROJECT_ID}` - GitHub repo name / project identifier
- `{PROJECT_TYPE}` - core/plugin/standalone
- `{DEPENDENCIES}` - Comma-separated list of upstream projects
- `{DEPENDENCIES_ARRAY}` - Space-separated for bash array
- `{DEPENDENTS}` - Comma-separated list of downstream projects
- `{DEPENDENTS_ARRAY}` - Space-separated for bash array
- `{PROJECT_ID_UPPER}` - PROJECT_ID in UPPER_CASE for env vars

## Success Criteria

- [ ] Script exists and is executable
- [ ] CLAUDE.md updated with correct section for project type
- [ ] GitHub labels created
- [ ] Test shows Claude automatically checks dependencies
- [ ] Projects registry updated

## Common Issues

**"gh: command not found"**
- Ensure GitHub CLI installed: `brew install gh` or `apt install gh`
- Authenticate: `gh auth login`

**"No dependent projects found"**
- Verify project type is correct
- Check if dependents have created `depends-on:` issues yet

**Claude doesn't auto-check dependencies**
- Verify CLAUDE.md section is present
- Check if instructions are contextually relevant
- Try explicit prompt: "Check for upstream breaking changes"
