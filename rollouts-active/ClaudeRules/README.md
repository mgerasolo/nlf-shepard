# ClaudeRules Rollout

Deploy shared `.claude/rules/` to all NLF projects.

## What This Deploys

Shared rules that apply to all dev projects:
- `git-conventions.md` - Commit format, branching
- `code-quality.md` - Error handling, logging, testing
- `api-patterns.md` - API design standards
- `security-practices.md` - Security guidelines
- `nlf-integration.md` - How to integrate with NLF services

## Target Projects

All projects in ShepardProtocol `projects.json` with:
- `type: "dev"` or `type: "app"`

## Usage

```bash
# Deploy to all dev projects
./shepard.sh run ClaudeRules --type dev

# Deploy to specific project
./shepard.sh run ClaudeRules --project appbrain

# Check status
./shepard.sh status ClaudeRules
```

## Manual Deployment

```bash
cd /path/to/project
mkdir -p .claude/rules
cp /mnt/foundry_infrastructure/ShepardProtocol/rollouts-active/ClaudeRules/skeleton_files/rules/*.md .claude/rules/
```

## Files Deployed

```
.claude/rules/
├── git-conventions.md
├── code-quality.md
├── api-patterns.md
├── security-practices.md
└── nlf-integration.md
```

## Relationship to Global Rules

- **Global rules** (`~/.claude/rules/`): User preferences (response format, domains)
- **Shared project rules** (this rollout): Dev standards across all projects
- **Project-specific rules** (`.claude/rules/`): Project-specific standards
