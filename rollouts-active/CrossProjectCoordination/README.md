# Cross-Project Coordination Rollout

## Purpose

Enable automated dependency tracking between interdependent projects (core frameworks and their plugins) using GitHub CLI commands invoked by Claude Code - avoiding MCP context overhead.

## What This Rollout Does

Adds to each project:
1. **CLAUDE.md section** - Instructions for Claude to check dependencies at appropriate times
2. **GitHub labels** - Standardized cross-project labels (breaking:*, blocks:*, depends-on:*, provides:*)
3. **Helper script** - `scripts/check-dependencies.sh` for quick cross-project status
4. **Infisical integration** - Use existing secrets system for dependency state sharing

## Problem Solved

**Before:** Multiple Claude Code sessions across interdependent projects have no awareness of each other. Breaking changes in core framework surprise plugin developers.

**After:** Claude automatically checks for upstream breaking changes, downstream blockers, and cross-project dependencies based on project type.

## When Claude Invokes Checks

### Core/Framework Projects
- **Before creating PR with breaking changes** - Check which projects depend on affected code
- **After merging breaking change** - Update Infisical state so dependent projects are notified

### Plugin/Dependent Projects
- **At session start** - Check for breaking changes in upstream dependencies
- **Before starting feature work** - Verify required upstream features are available
- **When blocked** - Create tracking issue with proper labels

## Token Efficiency

✓ Zero context overhead until checks are needed
✓ Claude invokes `gh` commands only when CLAUDE.md context triggers it
✓ No always-on MCP server consuming tokens
✓ Results cached in Infisical for fast access

## Files Added/Modified Per Project

### Added
- `scripts/check-dependencies.sh` - Quick cross-project status check
- `.github/labels.json` - Standard cross-project labels (if using label sync)

### Modified
- `CLAUDE.md` - Add "Cross-Project Coordination" section (project type determines content)

## Project Types

### Type: Core Framework
Projects that other projects depend on (e.g., shared libraries, API backends, core services)

**CLAUDE.md additions:**
- Check for dependent projects before breaking changes
- Update Infisical state after releases
- Create issues with `breaking:*` labels

### Type: Plugin/Consumer
Projects that depend on other projects (e.g., plugins, frontend apps, integrations)

**CLAUDE.md additions:**
- Check upstream for breaking changes at session start
- Verify upstream features before development
- Create `depends-on:*` tracking issues when blocked

### Type: Standalone
Projects with no cross-project dependencies

**CLAUDE.md additions:**
- None (skip this rollout)

## GitHub Label Taxonomy

| Label | Usage | Applied By |
|-------|-------|------------|
| `breaking:next-release` | Breaking change merging soon | Core project |
| `breaking:deployed` | Breaking change now live | Core project |
| `provides:feature-name` | New feature available | Core project |
| `blocks:project-name` | Known blocker for specific project | Core project |
| `depends-on:project#123` | Blocked by issue in another project | Any project |
| `upstream-breaking` | Needs update for upstream change | Plugin project |

## Infisical State Keys

Projects can share state via Infisical (already in use):

```bash
# Core project sets after breaking change
secret_set CORE_BREAKING_CHANGES "auth-api:issue-123,data-layer:issue-145"
secret_set CORE_STABLE_VERSION "2.3.1"

# Plugin project reads at session start
BREAKING=$(secret_get CORE_BREAKING_CHANGES)
```

## Rollout Checklist

Per project:

- [ ] Determine project type (core/plugin/standalone)
- [ ] Add `scripts/check-dependencies.sh` (customized for project)
- [ ] Update `CLAUDE.md` with coordination section
- [ ] Create GitHub labels (via web UI or `gh label create`)
- [ ] Test: Ask Claude to check dependencies, verify correct commands run
- [ ] Update `projects.json` with rollout status

## Example Workflows

### Core Framework: Before Breaking Change
```bash
# Claude reads CLAUDE.md, sees instruction, runs:
gh issue list --repo user/plugin-a --search "depends-on:core" --json number,title
gh issue list --repo user/plugin-b --search "depends-on:core" --json number,title

# Reports to user: "Found 3 plugins that may be affected. Create notification issue?"
```

### Plugin: Session Start
```bash
# Claude reads CLAUDE.md, runs automatically:
gh issue list --repo user/core --label "breaking:next-release" --json number,title,body

# Reports: "⚠️  Core has breaking change #123 (auth refactor). Review before proceeding?"
```

## Success Criteria

- Claude automatically checks dependencies without manual prompting
- Breaking changes are discovered before conflicts occur
- Cross-project labels are consistently applied
- Coordination state is visible in GitHub Issues
- Zero context overhead from unused MCP servers

## Related

- **ShepardProtocol** - This is a ShepardProtocol rollout
- **GitHub CLI** - Requires `gh` installed and authenticated
- **Infisical** - Uses existing `~/Infrastructure/scripts/secrets.sh` integration
