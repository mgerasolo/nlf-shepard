# /wf:deny #N [reason] - Reject with Feedback

## Action

Reject an issue during human review and return it to an earlier phase with feedback.

## Parameters

- `#N` - Issue number to reject
- `[reason]` - Reason for rejection (required)

## Implementation Steps

1. **Verify state**
   - Confirm issue #N exists and is open
   - Confirm issue is in `phase:7-human-review`

2. **Determine return phase**
   - Default: Return to `phase:4-developing`
   - If design issue: Return to `phase:2-designing`
   - If requirements unclear: Return to `phase:1-refining`

3. **Update labels**
   ```bash
   # Remove current phase
   gh issue edit N --remove-label "phase:7-human-review"

   # Add return phase
   gh issue edit N --add-label "phase:4-developing"

   # Mark as AI-ready
   gh issue edit N --add-label "next:ai-ready"

   # Remove verification request
   gh issue edit N --remove-label "next:human-verification"
   ```

4. **Add feedback comment**
   ```bash
   gh issue comment N --body "Rejected via /wf:deny

**Reason:** [reason provided]

**Return to phase:** 4-developing

Please address the feedback and re-submit for review."
   ```

## Example Usage

```
/wf:deny #42 Button color doesn't match design spec
/wf:deny #38 API returns 500 error on edge case
```

## Notes

- Always provide specific, actionable feedback
- Reference design docs or screenshots if helpful
- Consider if issue needs to be split
