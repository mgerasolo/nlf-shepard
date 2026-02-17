# ShepardProtocol - Standards Synchronization System

Systematic approach for running rollouts across all NLF development projects at scale.

## Overview

This system manages rollouts across 8+ (growing to 20-30+) projects by:

1. **Centralized project registry** (`projects.json`) - Single source of truth
2. **Per-rollout documentation** - Each rollout has its own folder with instructions
3. **Automated orchestration** (`shepard.sh`) - Run rollouts systematically
4. **Progress tracking** - JSON-based status tracking + GitHub Issues integration
5. **Flexible execution** - Interactive or autonomous modes

## Quick Start

```bash
cd /mnt/foundry_project/AppServices/ShepardProtocol

# See what rollouts are available
./shepard.sh list

# See what projects you have
./shepard.sh projects

# Check status of a rollout
./shepard.sh status rollouttostandards2

# Run rollout for all production projects
./shepard.sh run rollouttostandards2 --type production

# Run rollout for a specific project
./shepard.sh run rollouttostandards2 --project appbrain

# Mark a rollout complete after manual verification
./shepard.sh complete appbrain rollouttostandards2

# Create GitHub issue to track rollout progress
./shepard.sh issue rollouttostandards2
```

## Directory Structure

```
ShepardProtocol/
├── projects.json                      # Project registry (THE central source of truth)
├── shepard.sh                         # Migration orchestrator script
├── README.md                          # This file
│
├── audit-log.json                     # Machine-readable rollout execution history
├── AUDIT_LOG.md                       # Human-readable rollout execution history
├── log-rollout.sh                     # Helper script to create audit entries
│
├── schemas/                           # JSON schemas
│   ├── projects-schema.json
│   └── audit-log-schema.json
│
├── rollouts-active/                   # Active rollouts
│   ├── Baton&PromptResponseFormat/    # Migration: Baton system
│   │   ├── README.md
│   │   ├── INSTRUCTIONS.md
│   │   ├── PROMPT_FOR_AI.md           # Claude prompt for rollout
│   │   ├── CHECKLIST.md
│   │   ├── PROJECT_TRACKING.md
│   │   └── skeleton_files/
│   │
│   ├── migrationtostandards2/         # Migration: Standards v2
│   │   ├── README.md
│   │   ├── ROLLOUT_PROMPT.md          # Claude prompt for rollout
│   │   ├── QUICK_COMMANDS.md
│   │   └── verify-migration.sh
│   │
│   ├── InfisicalMigration/            # Migration: Phase -> Infisical
│   │   ├── README.md
│   │   ├── PROMPT_FOR_AI.md
│   │   └── ...
│   │
│   ├── Tasks&Issues/                  # Migration: GitHub Issues integration
│   │   ├── README.md
│   │   ├── PROMPT_FOR_AI.md
│   │   └── ...
│   │
│   └── CrossProjectCoordination/      # Migration: Cross-project task tracking
│       ├── README.md
│       └── ...
│
└── _ROLLOUT_TEMPLATE/                 # Template for creating new rollouts
    ├── README.md
    └── PROMPT_FOR_AI.md
```

## The Project Registry

[projects.json](projects.json) is the single source of truth for:

- All projects in your portfolio
- Project metadata (path, type, priority, tags)
- Migration status for each project

### Adding a New Project

Edit `projects.json` and add:

```json
{
  "id": "my-new-app",
  "name": "My New App",
  "path": "/mnt/foundry_project/AppServices/my-new-app",
  "type": "development",
  "priority": "medium",
  "status": "active",
  "tags": ["typescript", "api"],
  "contacts": ["mgerasolo"],
  "rollouts": {
    "Baton&PromptResponseFormat": "pending",
    "rollouttostandards2": "pending",
    "InfisicalMigration": "pending",
    "Tasks&Issues": "pending"
  }
}
```

### Project Fields

| Field | Values | Description |
|-------|--------|-------------|
| `id` | slug | Unique identifier (used in commands) |
| `name` | string | Display name |
| `path` | absolute path | Full path to project directory |
| `type` | production, development, personal, experimental, infrastructure, archived | Project category |
| `priority` | critical, high, medium, low | Importance level |
| `status` | active, archived | Current status |
| `tags` | array | Freeform tags for filtering |
| `contacts` | array | Who owns/maintains this |
| `rollouts` | object | Status for each rollout |

### Migration Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Not started yet |
| `in_progress` | Currently being worked on |
| `complete` | Finished and verified |
| `skip` | Not applicable or intentionally skipped |
| `blocked` | Blocked by dependency or issue |
| `failed` | Attempted but failed, needs attention |

## Creating a New Migration

When you have a new rollout to run across projects:

### 1. Create Migration Folder

```bash
cd /mnt/foundry_project/AppServices/ShepardProtocol
mkdir MyNewMigration
cd MyNewMigration
```

### 2. Create Required Files

**README.md** - Overview of what the rollout does:
```markdown
# MyNewMigration

Brief description of what this rollout accomplishes and why.

## What Changes

- Change 1
- Change 2
- Change 3

## Prerequisites

- Requirement 1
- Requirement 2
```

**PROMPT_FOR_AI.md** (or ROLLOUT_PROMPT.md or QUICK_PROMPT.txt) - Instructions for Claude:
```markdown
# MyNewMigration - AI Prompt

Please perform the following rollout on this project:

1. [Step 1 with specific instructions]
2. [Step 2 with specific instructions]
3. [Step 3 with specific instructions]

Verification:
- [ ] Check 1
- [ ] Check 2
- [ ] Check 3

When complete, report summary of changes made.
```

**verify-rollout.sh** (optional) - Automated verification:
```bash
#!/bin/bash
# Verify MyNewMigration was applied correctly

set -e

# Check for expected changes
if [ ! -f "expected-file.txt" ]; then
    echo "❌ Missing expected-file.txt"
    exit 1
fi

echo "✅ Migration verified"
```

### 3. Add Migration to projects.json

Edit each project's rollouts object:

```json
"rollouts": {
  "Baton&PromptResponseFormat": "complete",
  "rollouttostandards2": "pending",
  "MyNewMigration": "pending"
}
```

Or use this command to add to all projects:

```bash
jq '(.projects[].rollouts.MyNewMigration) = "pending"' projects.json > tmp.json
mv tmp.json projects.json
```

### 4. Run the Migration

```bash
# Create tracking issue
./shepard.sh issue MyNewMigration

# Run for all projects
./shepard.sh run MyNewMigration

# Or filter by type/priority
./shepard.sh run MyNewMigration --type production --priority high
```

## Migration Execution Modes

### Interactive Mode (Default)

Best for complex rollouts that need human oversight.

```bash
./shepard.sh run rollouttostandards2 --project appbrain
```

The script will:
1. Show you which project and rollout
2. Tell you where the prompt file is
3. Pause for you to manually run Claude Code
4. You mark it complete when done: `./shepard.sh complete appbrain rollouttostandards2`

### Autonomous Mode

For well-defined rollouts that can run unattended.

```bash
./shepard.sh run rollouttostandards2 --autonomous
```

The script will:
1. Automatically invoke Claude Code CLI
2. Feed it the rollout prompt
3. Monitor progress
4. Mark complete when done
5. Run verification if available

**Note:** Requires `claude` CLI to be installed and configured.

## Filtering Projects

Run rollouts only on specific project subsets:

```bash
# Only production projects
./shepard.sh run rollouttostandards2 --type production

# Only critical priority
./shepard.sh run rollouttostandards2 --priority critical

# Combine filters
./shepard.sh run rollouttostandards2 --type production --priority high

# Single project
./shepard.sh run rollouttostandards2 --project appbrain
```

## Tracking Progress

### Check Migration Status

```bash
# All rollouts across all projects
./shepard.sh status

# Specific rollout
./shepard.sh status rollouttostandards2
```

Output:
```
AppBrain (appbrain): pending
DoughFlow (doughflow): complete
Finance Ingest (finance-ingest): in_progress
...
```

### GitHub Issue Tracking

Create a tracking issue for rollout progress:

```bash
./shepard.sh issue rollouttostandards2
```

This creates a GitHub issue with:
- Migration overview
- Count of pending projects
- Commands to run
- Labels: `type:maintenance`, `admin:cleanup`, `status:active`

## Audit Logging

ShepardProtocol maintains comprehensive audit logs of all rollout executions.

### Audit Log Files

| File | Purpose |
|------|---------|
| [audit-log.json](audit-log.json) | Machine-readable execution history |
| [AUDIT_LOG.md](AUDIT_LOG.md) | Human-readable execution history |
| [log-rollout.sh](log-rollout.sh) | Helper script to create audit entries |

### Logging a Completed Rollout

After completing a rollout, create an audit log entry:

```bash
./log-rollout.sh migrationtostandards2
```

The script will:
1. Analyze projects.json for rollout status
2. Show statistics (complete, pending, failed, skipped)
3. Prompt for execution details (executor, mode, objective)
4. Generate template for AUDIT_LOG.md
5. Remind you to add project-specific changes

### Manual Audit Entry

You can also manually add entries to both files:

**audit-log.json** - Add to `entries` array:
```json
{
  "rollout": "MyMigration",
  "timestamp": "2025-12-26T00:00:00Z",
  "executor": "claude-code-agent",
  "execution_mode": "automated-parallel",
  "projects_affected": [...],
  "summary": {
    "total_projects": 9,
    "successful": 9,
    "failed": 0
  },
  "notes": "Additional context",
  "errors": []
}
```

**AUDIT_LOG.md** - Append using template in the file.

### What to Log

For each rollout execution, record:
- **Rollout name** and timestamp
- **Executor** (user, agent, automation)
- **Execution mode** (manual, sequential, parallel)
- **Projects affected** with individual results
- **Summary statistics** (success rate, completion time)
- **Key changes** for each project
- **Errors encountered** (if any)
- **Additional notes** (observations, lessons learned)

### Audit Log Schema

See [schemas/audit-log-schema.json](schemas/audit-log-schema.json) for the complete JSON schema.

## Best Practices

### 1. Start with High-Priority Projects

```bash
# Run on critical/production first to catch issues early
./shepard.sh run MyMigration --priority critical
./shepard.sh status MyMigration

# Then expand to high priority
./shepard.sh run MyMigration --priority high
./shepard.sh status MyMigration

# Finally do medium and low
./shepard.sh run MyMigration --priority medium
./shepard.sh run MyMigration --priority low
```

### 2. Test on Reference Implementation First

Always test new rollouts on `self-improving-ai` (your reference implementation) first:

```bash
./shepard.sh run MyMigration --project self-improving-ai
# Verify it worked correctly
./shepard.sh complete self-improving-ai MyMigration
```

### 3. Use Verification Scripts

Always create a `verify-rollout.sh` when possible. Automated verification catches issues early.

### 4. Document Issues in Migrations

If you encounter issues during rollout, document them:

```bash
# In rollout folder
echo "## Known Issues" >> README.md
echo "" >> README.md
echo "### AppBrain: Special handling needed" >> README.md
echo "The AppBrain project has custom config that requires..." >> README.md
```

### 5. Keep projects.json Updated

The registry should always reflect reality:

- Add new projects when created
- Archive old projects instead of deleting
- Update priorities as projects evolve
- Keep rollout status current

### 6. Integrate with GitHub Issues

For large rollouts affecting many projects:

1. Create tracking issue: `./shepard.sh issue MyMigration`
2. Comment on issue with progress updates
3. Link specific project issues if problems arise
4. Close issue when all projects complete

### 7. Maintain Audit Logs

Always log completed rollouts for historical tracking:

```bash
# After completing a rollout
./log-rollout.sh MyMigration

# Or manually append to audit-log.json and AUDIT_LOG.md
```

Benefits:
- Track what changes were made when
- Identify patterns in migration challenges
- Document lessons learned for future rollouts
- Provide audit trail for compliance/review

## Troubleshooting

### Migration Failed for a Project

```bash
# Check what went wrong
./shepard.sh status MyMigration

# Fix the issue manually
cd /path/to/problem-project
claude  # Fix manually

# Mark as complete
./shepard.sh complete problem-project MyMigration

# Or mark as blocked if can't proceed
jq '(.projects[] | select(.id == "problem-project") | .rollouts.MyMigration) = "blocked"' \
  projects.json > tmp.json && mv tmp.json projects.json
```

### Project Path Changed

Update the path in projects.json:

```bash
jq '(.projects[] | select(.id == "myproject") | .path) = "/new/path"' \
  projects.json > tmp.json && mv tmp.json projects.json
```

### Migration Not Applicable to Some Projects

Mark as skip:

```bash
jq '(.projects[] | select(.id == "test-app") | .rollouts.MyMigration) = "skip"' \
  projects.json > tmp.json && mv tmp.json projects.json
```

### Need to Re-run Migration

Use `--force`:

```bash
./shepard.sh run MyMigration --project appbrain --force
```

## Advanced Usage

### Custom Filtering with jq

```bash
# List all TypeScript projects
jq -r '.projects[] | select(.tags[] == "typescript") | .id' projects.json

# List projects with pending rollouttostandards2
jq -r '.projects[] | select(.rollouts.rollouttostandards2 == "pending") | .id' projects.json

# Count projects by status
jq -r '[.projects[].status] | group_by(.) | map({status: .[0], count: length})' projects.json
```

### Bulk Status Updates

```bash
# Mark all projects as pending for a new rollout
jq '(.projects[].rollouts.NewMigration) = "pending"' projects.json > tmp.json
mv tmp.json projects.json

# Mark all archived projects as skip
jq '(.projects[] | select(.status == "archived") | .rollouts.NewMigration) = "skip"' \
  projects.json > tmp.json && mv tmp.json projects.json
```

### Integration with CI/CD

Run rollouts in CI/CD pipelines:

```bash
#!/bin/bash
# .github/workflows/migrate.yml equivalent

cd /mnt/foundry_project/AppServices/ShepardProtocol

# Run autonomous rollout
./shepard.sh run MyMigration --autonomous

# Check for failures
if ./shepard.sh status MyMigration | grep -q "failed"; then
    echo "Migration failed for some projects"
    exit 1
fi
```

## Migration Examples

See the existing rollout folders for examples:

- **[Baton&PromptResponseFormat/](Baton&PromptResponseFormat/)** - Complex rollout with extensive docs, templates, tracking
- **[rollouttostandards2/](rollouttostandards2/)** - Simpler rollout with automated verification

## FAQ

### Q: How do I add a project that's not in AppServices?

A: Just add it to projects.json with the full path. Projects can be anywhere:

```json
{
  "id": "external-project",
  "path": "/home/user/some-other-location/project",
  ...
}
```

### Q: Can I run multiple rollouts at once?

A: Yes, but run them sequentially:

```bash
./shepard.sh run Migration1 --autonomous
./shepard.sh run Migration2 --autonomous
```

### Q: What if a rollout depends on another rollout?

A: Document the dependency in the rollout's README and check in the prompt:

```markdown
# MyMigration - PROMPT_FOR_AI.md

**Prerequisites:**
- rollouttostandards2 must be complete

First, check if prerequisite is met:
[instructions to verify]

If not met, report error and exit.

Otherwise, proceed with rollout:
[rollout steps]
```

### Q: How do I handle projects with special cases?

A: Create project-specific documentation in the rollout folder:

```
MyMigration/
├── README.md
├── PROMPT_FOR_AI.md
└── special-cases/
    ├── appbrain.md       # Special instructions for AppBrain
    └── doughflow.md      # Special instructions for DoughFlow
```

And reference in the main prompt:

```markdown
If working on AppBrain, see special-cases/appbrain.md for additional steps.
```

## See Also

- [projects.json](projects.json) - Project registry
- [shepard.sh](shepard.sh) - Orchestrator script
- [Baton&PromptResponseFormat/](Baton&PromptResponseFormat/) - Example rollout
- [rollouttostandards2/](rollouttostandards2/) - Example rollout
- [~/Infrastructure/CLAUDE.md](~/Infrastructure/CLAUDE.md) - Infrastructure standards

---

## ShepardProtocol v2 Features

Version 2 introduces protocol versioning, methodology tracking, canary testing, and improved feedback loops.

### Protocol Versioning

Protocols are now stored in versioned releases at `/mnt/foundry_resources/protocols/releases/`:

```
protocols/
├── releases/
│   └── v1.0.0/
│       ├── ai-workflow/
│       ├── baton/
│       ├── deployment/
│       └── ...
├── CHANGELOG.md
└── VERSION_TEMPLATE.md
```

Each deployed protocol includes `_version.md` tracking:
- Protocol name and version
- Deployment date
- Source (ShepardProtocol)
- Checksum for drift detection

### Methodology Tracking

Projects can use different development methodologies:

| Type | Description | Commands |
|------|-------------|----------|
| `bmad` | BMAD methodology | /wf, build phases |
| `design-os` | Design OS workflow | /wf, /marathon |
| `agent-os` | Agent OS workflow | Varies |
| `custom` | Custom methodology | Project-specific |
| `none` | Ad-hoc development | Standard commands |

Check methodology with:
```bash
./shepard.sh methodology list
./shepard.sh methodology detect <project>
```

### Protocol Pinning

Pin specific protocol versions with reasons and review dates:

```bash
# List all pins
./shepard.sh pins

# Add a pin (in projects.json)
"protocol_pins": {
  "ai-workflow": {
    "version": "1.0.0",
    "pinned_date": "2026-02-17",
    "reason": "Custom modifications in Phase 7",
    "review_date": "2026-05-17",
    "status": "active"
  }
}
```

Pins expire and are flagged for review.

### Canary Testing

Test protocol changes on one project before rolling out to all:

```bash
# Start canary
./shepard.sh canary start <protocol> <version> <project>

# Check status
./shepard.sh canary status <protocol>

# Promote to all (after testing)
./shepard.sh canary promote <protocol>

# Abort if issues found
./shepard.sh canary abort <protocol>
```

Canaries track:
- Protocol and version being tested
- Canary project name
- Start date and expected rollout
- Pending projects for later rollout

### Drift Detection

Detect when deployed protocols differ from source:

```bash
# Check a specific project
./shepard.sh drift <project> <protocol>

# Check all projects for specific protocol
./shepard.sh drift --protocol ai-workflow
```

Drift is detected via checksum comparison in `_version.md`.

### Core/Custom Pattern

Protocols now support a core/custom split:

```
.claude/protocols/ai-workflow/
├── core/           # Read-only, managed by ShepardProtocol
│   ├── _version.md
│   ├── PROTOCOL.md
│   └── phases/
└── custom/         # Project-owned customizations
    ├── overrides.md
    └── extensions/
```

**Rules:**
- Never modify `core/` directly - changes get overwritten
- All customizations go in `custom/`
- Infrastructure audits customs via herding and promotes good ones to core

### Herding Feedback Loop

Projects submit feedback via herding when protocols have gaps:

1. Project encounters issue with protocol
2. Project documents in custom layer + submits feedback
3. Infrastructure audits submission
4. Good patterns promoted to core
5. Core updated, custom cleaned up on next rollout

See `/mnt/foundry_resources/herding/` for templates.

### v2 Schema Changes

`projects.json` now supports:

```json
{
  "methodology": {
    "type": "bmad",
    "version": "1.0",
    "commands": ["wf"],
    "phases": ["ideation", "design", "build"]
  },
  "protocol_pins": {
    "ai-workflow": {
      "version": "1.0.0",
      "reason": "Custom Phase 7",
      "review_date": "2026-05-17"
    }
  }
}
```

`canaries` array at root level tracks active canary tests.

### Migration to v2

Existing projects work unchanged. To adopt v2 features:

1. Add `methodology` field to project entry
2. Add `protocol_pins` if using custom versions
3. Deploy protocols with `_version.md` tracking
4. Use canary testing for major changes

---

**Last Updated:** 2026-02-17
