# /wf:status - Show Workflow Status

## Action

Display all open issues grouped by workflow phase with counts.

## Implementation

```bash
# Get all issues with phase labels
gh issue list --state open --json number,title,labels,assignees \
  --jq 'group_by(.labels[] | select(.name | startswith("phase:")).name) |
        map({phase: .[0].labels[] | select(.name | startswith("phase:")).name,
             count: length,
             issues: map({number, title})})'
```

## Output Format

```
=== Workflow Status ===

Phase 0 - Backlog (3)
  #45 Add user preferences
  #48 Fix login timeout
  #51 Update footer links

Phase 4 - Developing (1)
  #42 Implement dark mode

Phase 7 - Human Review (2)
  #38 Dashboard redesign
  #41 API rate limiting

Total: 6 open issues
```

## Notes

- Issues without phase labels are shown as "Unphased"
- Highlight issues with `next:human-input` or `next:human-verification`
- Show blocker count if any issues are blocked
