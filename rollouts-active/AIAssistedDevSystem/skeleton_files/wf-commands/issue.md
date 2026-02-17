# /wf:issue - Create New Issue

## Action

Interactively create a new issue with proper workflow labels.

## Interactive Wizard

### Step 1: Title
```
What is the issue title?
> [User input]
```

### Step 2: Type
```
What type of issue is this?
1. Bug - Something is broken
2. Feature - New functionality
3. Enhancement - Improve existing
4. Docs - Documentation only
5. Config - Configuration change
```

### Step 3: Priority
```
What is the priority?
1. Critical - Drop everything
2. High - Do soon
3. Medium - Normal priority
4. Low - When time permits
```

### Step 4: Workflow Type
```
What workflow should this follow?
1. Full - All 10 phases (features, complex bugs)
2. Quick - Skip phases 1-3 (typos, one-line fixes)
```

### Step 5: Description
```
Describe the issue (optional, press Enter to skip):
> [User input]
```

## Implementation

```bash
gh issue create \
  --title "$TITLE" \
  --body "$DESCRIPTION" \
  --label "phase:0-backlog,type:$TYPE,priority:$PRIORITY,workflow:$WORKFLOW"
```

## Output

```
Created issue #53: Add user preferences

Labels:
- phase:0-backlog
- type:feature
- priority:medium
- workflow:full

Next: Triage this issue and add `next:ai-ready` when ready to start.
```

## Quick Mode

For quick issue creation without wizard:

```
/wf:issue "Fix typo in footer" --type bug --priority low --quick
```
