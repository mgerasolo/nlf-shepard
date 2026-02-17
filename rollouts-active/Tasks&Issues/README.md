# Tasks & Issues Rollout

Deploy GitHub Issues and Tasks integration to all development projects.

## What This Does

Sets up each project with:
- GitHub Issues integration for bug tracking, features, enhancements
- Automated issue submission from applications
- Issue templates (bug reports, feature requests, enhancements)
- Label taxonomy for organization
- Integration with GitHub Projects board

## Standards Reference

This rollout implements:
- `/mnt/foundry_project/Forge/Standards-v2/infrastructure/project-management/issue-management.md`
- `/mnt/foundry_project/Forge/Standards-v2/infrastructure/project-management/issue-automation.md`
- `/mnt/foundry_project/Forge/Standards-v2/infrastructure/project-management/task-management.md`
- `/mnt/foundry_project/Forge/Standards-v2/infrastructure/project-management/project-management.md`

## Changes Per Project

### Files Created
```
.github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   ├── feature_request.md
│   ├── enhancement.md
│   ├── automated_issue.md
│   └── config.yml
└── workflows/
    └── issue_labeler.yml (optional)
```

### Configuration
- GitHub repository must exist
- Issues must be enabled
- Labels must be configured (automated or manual)

## Prerequisites

- Project must have GitHub repository
- Repository must have Issues enabled
- User must have admin access to configure labels

## Verification

After rollout:
- [ ] .github/ISSUE_TEMPLATE/ exists with 4+ templates
- [ ] Templates have proper frontmatter (labels, title prefix)
- [ ] Can create issues using templates
- [ ] Labels are configured in repository
- [ ] Project board exists and is linked

## Estimated Time

- Per project: 10-15 minutes
- Total (12 projects): 2-3 hours

## Notes

- Infrastructure projects may skip this (already configured)
- Test with one issue submission after setup
- Verify webhook integration if using automated submissions
