# Tasks & Issues Rollout - AI Prompt

Set up GitHub Issues integration for this project.

## Context

You are setting up GitHub Issues and Tasks integration for a development project. This provides standardized bug tracking, feature requests, and automated issue submission.

## Prerequisites Check

Before starting, verify:
- [ ] This project has a GitHub repository
- [ ] GitHub Issues are enabled
- [ ] You have the repository name from package.json or README

If no GitHub repo exists, skip this rollout and note it.

## Steps

### 1. Create Issue Template Directory

```bash
mkdir -p .github/ISSUE_TEMPLATE
```

### 2. Create Bug Report Template

Create `.github/ISSUE_TEMPLATE/bug_report.md`:

```yaml
---
name: Bug Report
about: Report a bug or issue
title: '[BUG]: '
labels: 'type:bug'
assignees: ''
---

## Summary
Brief description of the bug.

## Steps to Reproduce
1. Step one
2. Step two
3. Expected vs actual result

## Expected Behavior
What should happen.

## Actual Behavior
What actually happens.

## Environment
- Browser/OS:
- Version:
- Deployment:

## Error Messages
\`\`\`
Paste error messages or logs here
\`\`\`

## Screenshots
If applicable, add screenshots.

## Additional Context
Any other relevant information.
```

### 3. Create Feature Request Template

Create `.github/ISSUE_TEMPLATE/feature_request.md`:

```yaml
---
name: Feature Request
about: Suggest a new feature
title: '[FEATURE]: '
labels: 'type:feature'
assignees: ''
---

## Problem Statement
What problem does this solve? Who is affected?

## Proposed Solution
Describe the feature you'd like to see.

## User Stories
- As a [user type], I want to [action] so that [benefit]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Tests added
- [ ] Documentation updated

## Alternative Solutions
What other approaches did you consider?

## Additional Context
Mockups, examples, related features, etc.
```

### 4. Create Enhancement Template

Create `.github/ISSUE_TEMPLATE/enhancement.md`:

```yaml
---
name: Enhancement
about: Improve existing functionality
title: '[ENHANCEMENT]: '
labels: 'type:enhancement'
assignees: ''
---

## Current Behavior
How does it work now?

## Proposed Improvement
How should it work instead?

## Benefits
Why is this better?

## Impact
- Performance:
- User experience:
- Code quality:

## Implementation Notes
Any technical considerations.
```

### 5. Create Automated Issue Template

Create `.github/ISSUE_TEMPLATE/automated_issue.md`:

```yaml
---
name: Automated Issue
about: Auto-generated issue from application or service
title: '[AUTO]: '
labels: 'submission:automated'
assignees: ''
---

## Metadata
- **Submitted by:** [app/service name]
- **Project/Instance:** [specific cursor project or deployment]
- **Submission type:** [automated | explicit]
- **Callback webhook:** [URL for status updates]
- **Source version:** [app version or commit]

## Issue Description
[Auto-generated description]

## Impact
[What's blocked or affected]

## Additional Context
[Logs, stack traces, etc.]
```

### 6. Create Template Config

Create `.github/ISSUE_TEMPLATE/config.yml`:

```yaml
blank_issues_enabled: true
contact_links:
  - name: Documentation
    url: https://github.com/mgerasolo/REPO_NAME/wiki
    about: Check the docs first
  - name: Discussions
    url: https://github.com/mgerasolo/REPO_NAME/discussions
    about: For questions and general discussion
```

**Replace `REPO_NAME` with actual repository name.**

### 7. Configure Labels (Manual Step)

**Note to user:** After this runs, configure these labels in the GitHub repository:

**Type Labels:**
- `type:bug` - Red (#d73a4a)
- `type:feature` - Blue (#0075ca)
- `type:enhancement` - Green (#0e8a16)
- `type:docs` - Yellow (#fef2c0)
- `type:maintenance` - Gray (#d4c5f9)
- `type:security` - Red (#b60205)

**Priority Labels:**
- `priority:critical` - Red (#b60205)
- `priority:high` - Orange (#d93f0b)
- `priority:medium` - Yellow (#fbca04)
- `priority:low` - Green (#0e8a16)

**Status Labels:**
- `status:active` - Green (#0e8a16)
- `status:pending-approval` - Yellow (#fbca04)
- `status:blocked` - Red (#b60205)

**Submission Labels:**
- `submission:automated` - Gray (#d4c5f9)
- `submission:explicit` - Blue (#0075ca)

**Cross-Project Labels (for project coordination):**
- `breaking:api` - Red (#b60205) - Breaking API change
- `breaking:config` - Red (#b60205) - Breaking config change
- `breaking:behavior` - Orange (#d93f0b) - Breaking behavior change
- `blocks:*` - Red (#d73a4a) - Blocks another project (use `blocks:project-name`)
- `depends-on:*` - Yellow (#fbca04) - Depends on another project (use `depends-on:project-name`)
- `provides:*` - Green (#0e8a16) - Provides feature (use `provides:feature-name`)

You can configure these via GitHub CLI:
```bash
# Example (if gh is installed and authenticated)
gh label create "type:bug" --color d73a4a --description "Bug or defect"
# ... repeat for all labels
```

Or manually via GitHub web interface: Settings → Labels

### 8. Update README (Optional)

Add to project README.md:

```markdown
## Reporting Issues

Use GitHub Issues for:
- 🐛 Bug reports
- ✨ Feature requests
- 🚀 Enhancement suggestions

[Report an issue](https://github.com/mgerasolo/REPO_NAME/issues/new/choose)
```

### 9. Verification

After setup:
- [ ] .github/ISSUE_TEMPLATE/ directory exists
- [ ] 4 templates created (bug_report, feature_request, enhancement, automated_issue)
- [ ] config.yml created
- [ ] Templates have proper YAML frontmatter
- [ ] README updated (if applicable)

Test by creating a test issue:
```bash
# Via GitHub CLI
gh issue create --title "[BUG]: Test issue" --label "type:bug"
```

Or visit: `https://github.com/mgerasolo/REPO_NAME/issues/new/choose`

## Reporting

When complete, provide summary:

```markdown
**Rollout: Tasks & Issues**

**Tasks:**
• ✓ Created .github/ISSUE_TEMPLATE/ directory
• ✓ Created bug_report.md template
• ✓ Created feature_request.md template
• ✓ Created enhancement.md template
• ✓ Created automated_issue.md template
• ✓ Created config.yml
• ✓ Updated README (if applicable)

**Repository:** [repository name]

**Next:**
• Configure labels in GitHub repository
• Create test issue to verify
• Link to GitHub Projects board

**Verification:**
✓ All template files created
○ Labels need manual configuration (see list above)
```

## Special Cases

### No GitHub Repository

If project doesn't have a GitHub repository yet:
```markdown
**Rollout: Tasks & Issues - SKIPPED**

**Reason:** No GitHub repository configured for this project.

**Recommendation:** Create GitHub repository first, then run this rollout.
```

### Repository Already Has Templates

If .github/ISSUE_TEMPLATE/ already exists:
```markdown
**Rollout: Tasks & Issues - PARTIAL**

**Found:** Existing issue templates

**Action:** Reviewed existing templates, merged with standard templates where appropriate.

**Files Updated:** [list which files were updated/added]
```

## Error Handling

If you encounter errors:
1. Check that .github/ directory is created
2. Verify YAML frontmatter syntax
3. Check file permissions
4. Report error and skip if unable to proceed

---

**Note to AI:** Follow these instructions exactly. Create all template files as specified. Report completion with verification checklist.
