# ClaudeRules Rollout - AI Prompt

## Objective

Deploy shared `.claude/rules/` to this project for consistent development standards.

## Files to Deploy

Copy the following files from the skeleton_files/rules/ directory to this project's `.claude/rules/`:

```
.claude/rules/
├── git-conventions.md      # Commit format, branching
├── code-quality.md         # Error handling, logging, testing
├── api-patterns.md         # REST API design standards
├── security-practices.md   # Security guidelines
└── nlf-integration.md      # NLF service integration
```

## Steps

1. **Create directory** (if not exists):
   ```bash
   mkdir -p .claude/rules
   ```

2. **Copy rules**:
   ```bash
   cp /mnt/foundry_infrastructure/ShepardProtocol/rollouts-active/ClaudeRules/skeleton_files/rules/*.md .claude/rules/
   ```

3. **Verify**:
   ```bash
   ls -la .claude/rules/
   ```

4. **Commit**:
   ```bash
   git add .claude/rules/
   git commit -m "chore: add shared Claude rules via ShepardProtocol

   Adds standardized development rules for:
   - Git conventions
   - Code quality
   - API patterns
   - Security practices
   - NLF integration

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

## Verification

After deployment, verify:
- [ ] `.claude/rules/` directory exists
- [ ] All 5 rule files present
- [ ] Files committed to git

## Notes

- These rules complement project-specific CLAUDE.md
- Do not modify shared rules locally - update at source
- Project-specific rules can be added alongside these
