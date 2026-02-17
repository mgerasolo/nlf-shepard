# Cross-Project Coordination - Quick Start

## What This Is

A ShepardProtocol rollout that adds automated dependency tracking to your projects using GitHub CLI commands invoked by Claude Code.

**Problem:** Multiple Claude Code sessions across interdependent projects (core + plugins) have no awareness of each other.

**Solution:** CLAUDE.md instructions trigger automatic `gh` commands to check dependencies. Zero MCP overhead.

## Usage

### Option 1: Use ShepardProtocol Orchestrator

```bash
cd /mnt/foundry_project/AppServices/ShepardProtocol

# See rollout status
./shepard.sh status CrossProjectCoordination

# Run for all projects
./shepard.sh run CrossProjectCoordination --type all

# Run for specific project
./shepard.sh run CrossProjectCoordination --project my-core-api
```

### Option 2: Manual Per-Project Rollout

1. **Read the overview:** [README.md](README.md)
2. **Follow the checklist:** [CHECKLIST.md](CHECKLIST.md)
3. **Use AI prompt:** [PROMPT_FOR_AI.md](PROMPT_FOR_AI.md)

## Quick Manual Rollout

For a **core/framework project**:

```bash
cd /path/to/your/core-project

# 1. Copy script
cp /mnt/foundry_project/AppServices/ShepardProtocol/CrossProjectCoordination/skeleton_files/check-dependencies-core.sh scripts/check-dependencies.sh

# 2. Customize script
sed -i 's/{PROJECT_ID}/my-core-api/g' scripts/check-dependencies.sh
sed -i 's/{DEPENDENTS_ARRAY}/plugin-a plugin-b/g' scripts/check-dependencies.sh
chmod +x scripts/check-dependencies.sh

# 3. Add to CLAUDE.md
cat /mnt/foundry_project/AppServices/ShepardProtocol/CrossProjectCoordination/skeleton_files/CLAUDE.md.core-snippet >> CLAUDE.md

# Edit CLAUDE.md to replace variables

# 4. Create labels
gh label create "breaking:next-release" --color "d73a4a" --description "Breaking change coming soon"
gh label create "provides" --color "0e8a16" --description "New feature available"

# 5. Test
./scripts/check-dependencies.sh
```

For a **plugin/consumer project**:

```bash
cd /path/to/your/plugin-project

# 1. Copy script
cp /mnt/foundry_project/AppServices/ShepardProtocol/CrossProjectCoordination/skeleton_files/check-dependencies-plugin.sh scripts/check-dependencies.sh

# 2. Customize script
sed -i 's/{PROJECT_ID}/my-plugin/g' scripts/check-dependencies.sh
sed -i 's/{DEPENDENCIES_ARRAY}/core-api shared-lib/g' scripts/check-dependencies.sh
chmod +x scripts/check-dependencies.sh

# 3. Add to CLAUDE.md
cat /mnt/foundry_project/AppServices/ShepardProtocol/CrossProjectCoordination/skeleton_files/CLAUDE.md.plugin-snippet >> CLAUDE.md

# Edit CLAUDE.md to replace variables

# 4. Create labels
gh label create "blocked" --color "fbca04" --description "Blocked by external dependency"
gh label create "upstream-breaking" --color "d93f0b" --description "Needs upstream update"

# 5. Test
./scripts/check-dependencies.sh
```

## How It Works

### Core Project Session
```
User: "Refactor the auth API"
  ↓
Claude reads CLAUDE.md: "Before breaking changes, check dependents"
  ↓
Claude runs: gh issue list --repo user/plugin-a --search "depends-on:core"
  ↓
Claude: "Found 2 plugins using auth API. Create notification issue?"
```

### Plugin Project Session
```
User: "Update to latest core version"
  ↓
Claude reads CLAUDE.md: "At session start, check upstream"
  ↓
Claude runs: gh issue list --repo user/core --label "breaking:next-release"
  ↓
Claude: "⚠️ Core has breaking change #123 (auth refactor). Review first?"
```

## Files Created Per Project

- `scripts/check-dependencies.sh` - Manual check command
- Updated `CLAUDE.md` - Instructions for Claude
- GitHub labels - Standardized coordination labels

## Workflow Examples

### Scenario: Core Makes Breaking Change

1. Core project:
   ```bash
   # Claude automatically checks dependents
   gh issue create --title "Breaking: Auth API refactor" --label "breaking:next-release"
   ```

2. Plugin projects (next session start):
   ```bash
   # Claude automatically discovers breaking change
   "⚠️ Upstream breaking change detected: Auth API refactor (#123)"
   ```

3. Plugin creates tracking issue:
   ```bash
   gh issue create --title "Blocked: Update for core #123" --label "blocked,depends-on:core#123"
   ```

4. After migration complete:
   ```bash
   gh issue close {ISSUE_NUM} --comment "Migrated to new auth API"
   ```

### Scenario: Plugin Needs New Feature

1. Plugin creates issue:
   ```bash
   gh issue create --repo user/core --title "Feature: Add OAuth support" --label "enhancement"
   gh issue create --repo user/plugin --title "Blocked: Waiting for core OAuth" --label "blocked,depends-on:core#456"
   ```

2. Core implements and tags:
   ```bash
   gh issue close 456 --label "provides:oauth"
   ```

3. Plugin session:
   ```bash
   # Claude detects new feature
   "./scripts/check-dependencies.sh shows OAuth now available"
   ```

## Benefits

✓ **Automatic coordination** - Claude checks dependencies without prompting
✓ **Zero MCP overhead** - Only uses tokens when checks run
✓ **Token efficient** - You control when checks happen via CLAUDE.md
✓ **Visible to team** - GitHub issues = everyone sees coordination state
✓ **Flexible** - Works across any number of interdependent projects

## Next Steps

1. Identify your core/plugin relationships
2. Run rollout on core projects first
3. Then roll out to plugins
4. Test with a breaking change workflow
5. Adjust CLAUDE.md instructions based on your workflow

## Support

- **Rollout docs:** [README.md](README.md)
- **Checklist:** [CHECKLIST.md](CHECKLIST.md)
- **AI prompt:** [PROMPT_FOR_AI.md](PROMPT_FOR_AI.md)
- **ShepardProtocol:** [../README.md](../README.md)
