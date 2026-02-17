# Baton - Context Management Command

**Usage:** `/baton [subcommand] [args]`

Context management system for solving compaction problems. Provides TLDR summaries, conversation tracking, and efficient post-compaction recovery.

## Subcommands

| Command | Purpose |
|---------|---------|
| `/baton` or `/baton load` | Display current TLDR summary |
| `/baton init` | Initialize new conversation |
| `/baton save [note]` | Save current state with optional note |
| `/baton update [section]` | Auto-update SUMMARY.md from recent activity |
| `/baton rename <title>` | Set conversation title (max 60 chars) |
| `/baton rename --suggest` | Get AI-generated title suggestions |
| `/baton history` | Show all conversations with titles |
| `/baton status` | Check token usage, get save recommendations |
| `/baton archive` | Archive completed items to prevent bloat |
| `/baton switch <id-or-title>` | Switch to different conversation |
| `/baton switch --recent` | Show recent conversations to choose from |
| `/baton search <term>` | Search across all conversations, bugs, decisions |
| `/baton context <topic>` | Load relevant past context |
| `/baton report [timeframe]` | Generate work summary report |
| `/baton validate` | Check file structure integrity |

## Implementation

### `/baton init`

```bash
CONV_ID="conv-$(date +%Y%m%d-%H%M%S)"
mkdir -p .claude/conversations/$CONV_ID
echo $CONV_ID > .claude/CURRENT_CONVERSATION_ID
```

Then create SUMMARY.md from template:

```markdown
# Conversation {conv-id} - TLDR

**Title:** [Set via /baton rename]
**Status:** Active
**Started:** YYYY-MM-DD HH:MM
**Duration:** 0h
**Compactions:** 0

## Context in 3 Lines
[High-level overview]

## Task Checklist
- [ ] Initial task

## Decisions Made
- None yet

## Key Files Created/Modified
- None yet

## Failed Attempts (Don't Retry)
- None yet

## Next Actions
1. First priority

## State Snapshot
**Current Persona:** none
**Current file:** n/a
**Current line:** n/a
**Current task:** Getting started
**Blockers:** None
**Ready to:** Begin work
```

Initialize shared files if they don't exist:
- `.claude/BUGS.md`
- `.claude/DECISIONS.md`
- `.claude/CONVERSATION_HISTORY.md`
- `.claude/ENHANCEMENTS.md`
- `.claude/USER_FEEDBACK.md`

---

### `/baton load` (or just `/baton`)

1. Read `.claude/CURRENT_CONVERSATION_ID`
2. Display `.claude/conversations/{conv-id}/SUMMARY.md`
3. Display filtered entries from `.claude/BUGS.md` (matching conversation ID)
4. Display filtered entries from `.claude/DECISIONS.md` (matching conversation ID)
5. Show pending items from `.claude/USER_FEEDBACK.md`

---

### `/baton save [note]`

1. Read current TODO list and recent file modifications
2. Update `.claude/conversations/{conv-id}/SUMMARY.md` with:
   - Current task and progress
   - Decisions made
   - Bugs discovered
   - Failed attempts
   - Next actions
   - State snapshot
3. Add timestamp and optional note
4. Update `.claude/CONVERSATION_HISTORY.md` with milestone

---

### `/baton rename <title>`

1. Read `.claude/CURRENT_CONVERSATION_ID`
2. Validate title length (max 60 chars)
3. Update Title field in `.claude/conversations/{conv-id}/SUMMARY.md`
4. Update entry in `.claude/CONVERSATION_HISTORY.md`

---

### `/baton history`

Display `.claude/CONVERSATION_HISTORY.md` with all conversations:
- Conversation ID and title
- Duration and status
- Tasks completed
- Quick summary

---

### `/baton status`

1. Estimate current token usage
2. Calculate percentage toward compaction threshold
3. Show time since last SUMMARY.md update
4. Recommend save if > 70%
5. Check file sizes and recommend archival if thresholds exceeded:
   - CONVERSATION_HISTORY.md > 10 conversations
   - BUGS.md > 20 bugs
   - DECISIONS.md > 15 decisions

---

### `/baton archive`

1. Count items in each file by status
2. Move completed/fixed/implemented items to `.claude/archive/`:
   - `archive/conversations/YYYY-MM.md` (completed conversations)
   - `archive/bugs/fixed-YYYY-MM.md` (fixed bugs)
   - `archive/decisions/implemented-YYYY-MM.md` (implemented decisions)
3. Keep last 10 active conversations, all active bugs, all proposed/accepted decisions
4. Show summary of what was archived

---

### `/baton search <term>`

Search across all baton files:
- CONVERSATION_HISTORY.md
- All conversation SUMMARY.md files
- BUGS.md
- DECISIONS.md
- ENHANCEMENTS.md

Return matching entries with context.

---

### `/baton validate`

Check file structure integrity:
- Verify `.claude/` directory exists
- Check CURRENT_CONVERSATION_ID points to valid conversation
- Verify all required files exist
- Check for orphaned conversation directories
- Report any issues found

## File Structure

```
.claude/
├── CONVERSATION_HISTORY.md          # All conversations TLDR
├── BUGS.md                          # All bugs, tagged with conv-id
├── DECISIONS.md                     # All decisions, tagged with conv-id
├── ENHANCEMENTS.md                  # Future enhancement ideas
├── USER_FEEDBACK.md                 # Questions waiting for user input
├── CURRENT_CONVERSATION_ID          # Current conversation ID
├── archive/                         # Archived completed items
└── conversations/
    └── {conv-id}/
        └── SUMMARY.md               # This conversation TLDR
```

## Conversation ID Tagging

When adding to shared files (BUGS.md, DECISIONS.md, etc.):

```markdown
**Conv:** conv-20251223-225929
```

This enables multiple conversations to work simultaneously without conflicts.

## Token Efficiency

- Full conversation: 50,000+ tokens
- TLDR summary: 500-2,000 tokens
- Compression: 25-100x
- Post-compaction reads: ~1,000 tokens total
