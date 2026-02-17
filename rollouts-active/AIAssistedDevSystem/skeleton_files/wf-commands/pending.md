# /wf:pending - Show Items Needing Human Action

## Action

Display all issues that require human input, verification, or review.

## Implementation

```bash
# Get issues needing human attention
gh issue list --state open --json number,title,labels \
  --jq '.[] | select(.labels[].name | test("next:human|phase:7|phase:0"))'
```

## Output Format

```
=== Items Needing Your Attention ===

NEEDS INPUT (next:human-input):
  #45 Add user preferences
      Question: What format should preferences export as?

NEEDS REVIEW (phase:7-human-review):
  #38 Dashboard redesign
      URL: https://staging.app.com/dashboard
  #41 API rate limiting
      Test: Try hitting /api/users 100 times

NEEDS TRIAGE (phase:0-backlog):
  #51 Update footer links
  #52 Mobile responsive issues

Total: 5 items need attention
```

## Sections

1. **NEEDS INPUT** - Issues blocked waiting for human decision
2. **NEEDS REVIEW** - Deployed features awaiting human testing
3. **NEEDS TRIAGE** - New issues in backlog

## Quick Actions

From this view, use:
- `/wf:approve #N` - Approve a reviewed item
- `/wf:deny #N [reason]` - Reject with feedback
- Add `workflow:full` or `workflow:quick` to triage items
