# /wf:approve #N - Approve and Advance Issue

## Action

Approve a human-reviewed issue and advance it to the next phase.

## Parameters

- `#N` - Issue number to approve

## Implementation Steps

1. **Verify state**
   - Confirm issue #N exists and is open
   - Confirm issue is in `phase:7-human-review` or `phase:6-deployment`

2. **Update labels**
   ```bash
   # Remove current phase
   gh issue edit N --remove-label "phase:7-human-review"

   # Add next phase
   gh issue edit N --add-label "phase:8-docs-update"

   # Remove verification request
   gh issue edit N --remove-label "next:human-verification"
   ```

3. **Add comment**
   ```bash
   gh issue comment N --body "Approved via /wf:approve"
   ```

4. **Check if docs needed**
   - If no docs changes required, advance directly to `phase:9-done`
   - Close issue if complete

## Skip to Done

If docs not needed:

```bash
gh issue edit N --remove-label "phase:8-docs-update" --add-label "phase:9-done,resolution:fixed"
gh issue close N
```

## Natural Language Triggers

These phrases also trigger approval:
- "approve #42"
- "looks good on #42"
- "LGTM #42"
- "#42 is approved"
