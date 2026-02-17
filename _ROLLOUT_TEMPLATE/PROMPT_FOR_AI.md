# [Migration Name] - AI Migration Prompt

This prompt is used by Claude Code to perform the migration automatically.

## Context

[Brief context about what this migration does and why]

## Prerequisites Check

Before starting, verify:
- [ ] [Prerequisite 1]
- [ ] [Prerequisite 2]

If any prerequisite is not met, report the issue and do not proceed.

## Migration Steps

Perform the following steps in order:

### 1. [Step 1 Name]

[Detailed instructions for step 1]

**Files to modify:**
- `path/to/file1.ts`
- `path/to/file2.ts`

**Changes:**
- Change description

### 2. [Step 2 Name]

[Detailed instructions for step 2]

**Files to create:**
- `new/file/path.ts`

**Content:**
```typescript
// Example content
```

### 3. [Step 3 Name]

[Detailed instructions for step 3]

## Verification

After completing all steps, verify:
- [ ] Verification item 1
- [ ] Verification item 2
- [ ] Verification item 3

## Reporting

When complete, provide a summary using this format:

```markdown
**Migration: [Migration Name]**

**Tasks:**
• ✓ [Completed task 1]
• ✓ [Completed task 2]
• ○ [Skipped task - reason]

**Files Modified:**
• [file1.ts](path/to/file1.ts) - [what changed]
• [file2.ts](path/to/file2.ts) - [what changed]

**Files Created:**
• [new/file/path.ts](new/file/path.ts)

**Verification:**
✓ All verification checks passed

**Next:**
• Run tests to ensure nothing broke
• Update documentation if needed
```

## Special Cases

### If [Condition A] is true:
[Alternative instructions]

### If [Condition B] is true:
[Alternative instructions]

## Error Handling

If you encounter errors:
1. Report the error clearly
2. Mark migration status as "failed"
3. Do not proceed to subsequent steps
4. Suggest resolution steps if known

---

**Note to AI:** This is a standardized migration being run across multiple projects. Follow these instructions exactly as written to ensure consistency.
