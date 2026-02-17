# Migration Orchestrator - Quick Start

5-minute guide to running rollouts across all your projects.

## Prerequisites

```bash
# Install required tools (if not already installed)
sudo apt install jq gh

# Verify they work
jq --version
gh --version
```

## Your First Migration

### 1. See What You Have

```bash
cd /mnt/foundry_project/AppServices/ShepardProtocol

# List available rollouts
./shepard.sh list

# List your projects
./shepard.sh projects
```

### 2. Check Status

```bash
# See status of a specific rollout across all projects
./shepard.sh status rollouttostandards2
```

Output will show which projects have completed, which are pending, etc.

### 3. Run on One Project (Test)

```bash
# Test on your reference implementation first
./shepard.sh run rollouttostandards2 --project self-improving-ai
```

This will:
- Show you the project and rollout details
- Tell you where the prompt file is
- Pause for you to run the rollout
- Wait for you to mark it complete

### 4. Actually Do the Migration

In another terminal:

```bash
cd /home/mgerasolo/Dev/self-improving-ai
claude  # Or however you invoke Claude Code
```

Paste the contents of the prompt file shown by shepard.sh.

### 5. Mark Complete

After Claude finishes and you verify it worked:

```bash
./shepard.sh complete self-improving-ai rollouttostandards2
```

### 6. Run on All Projects

Once you're confident it works:

```bash
# Run on all production projects
./shepard.sh run rollouttostandards2 --type production

# Or all high-priority projects
./shepard.sh run rollouttostandards2 --priority high

# Or just all projects
./shepard.sh run rollouttostandards2
```

The script will iterate through each matching project, pausing for you to run the rollout manually.

### 7. Track Progress

```bash
# See overall status
./shepard.sh status rollouttostandards2

# Create GitHub issue for tracking
./shepard.sh issue rollouttostandards2
```

## Creating a New Migration

### 1. Copy Template

```bash
cd /mnt/foundry_project/AppServices/ShepardProtocol

# Copy template folder
cp -r _MIGRATION_TEMPLATE MyNewMigration
cd MyNewMigration
```

### 2. Fill in the Files

Edit these files with your rollout details:
- `README.md` - What the rollout does
- `PROMPT_FOR_AI.md` - Instructions for Claude
- `verify-rollout.sh` - Automated checks (optional)

### 3. Add to Registry

Add the rollout to all projects in `projects.json`:

```bash
cd ..
jq '(.projects[].rollouts.MyNewMigration) = "pending"' projects.json > tmp.json
mv tmp.json projects.json
```

### 4. Run It

```bash
# Test on one project first
./shepard.sh run MyNewMigration --project self-improving-ai

# Then run on all
./shepard.sh run MyNewMigration
```

## Common Workflows

### Run Migration on Production Projects Only

```bash
./shepard.sh run MyMigration --type production
```

### Run on High-Priority Projects First

```bash
# Critical first
./shepard.sh run MyMigration --priority critical
./shepard.sh status MyMigration

# Then high
./shepard.sh run MyMigration --priority high
./shepard.sh status MyMigration

# Then medium and low
./shepard.sh run MyMigration --priority medium
./shepard.sh run MyMigration --priority low
```

### Re-run a Migration (Force)

```bash
./shepard.sh run MyMigration --project appbrain --force
```

### Skip a Migration for Specific Project

```bash
# Manually edit projects.json or use jq
jq '(.projects[] | select(.id == "test-app") | .rollouts.MyMigration) = "skip"' \
  projects.json > tmp.json && mv tmp.json projects.json
```

### Mark as Blocked

```bash
jq '(.projects[] | select(.id == "problem-project") | .rollouts.MyMigration) = "blocked"' \
  projects.json > tmp.json && mv tmp.json projects.json
```

## Autonomous Mode (Advanced)

If you have the `claude` CLI installed and configured:

```bash
# Run rollout autonomously (no manual intervention)
./shepard.sh run MyMigration --autonomous
```

This will automatically:
1. Invoke Claude Code in each project
2. Feed it the rollout prompt
3. Monitor progress
4. Mark complete when done
5. Run verification scripts

**Note:** Only use autonomous mode for well-tested rollouts with clear instructions.

## Troubleshooting

### Script says "jq: command not found"

```bash
sudo apt install jq
```

### Script says "gh: command not found"

```bash
# Install GitHub CLI
sudo apt install gh

# Authenticate
gh auth login
```

### Migration failed for a project

```bash
# Check what went wrong
./shepard.sh status MyMigration

# Fix manually
cd /path/to/problem/project
claude

# Mark as complete after fixing
./shepard.sh complete problem-project MyMigration
```

### Want to see what would happen without running

```bash
# Use dry-run (not implemented yet, but you can check status first)
./shepard.sh status MyMigration

# See which projects would be affected
jq -r '.projects[] | select(.rollouts.MyMigration == "pending") | .name' projects.json
```

## Tips

1. **Always test on one project first** before running on all projects
2. **Use `self-improving-ai` as your test project** (it's your reference implementation)
3. **Check status frequently** to track progress
4. **Create GitHub issues** for large rollouts to track overall progress
5. **Keep projects.json updated** as you add/remove projects
6. **Document special cases** in rollout README files
7. **Use verification scripts** when possible to catch issues early

## Next Steps

- Read [README.md](README.md) for comprehensive documentation
- Look at existing rollouts for examples:
  - [Baton&PromptResponseFormat/](Baton&PromptResponseFormat/)
  - [rollouttostandards2/](rollouttostandards2/)
- Add your projects to [projects.json](projects.json)
- Create your first custom rollout

---

**Questions?** See [README.md](README.md) or ask Claude Code for help.
