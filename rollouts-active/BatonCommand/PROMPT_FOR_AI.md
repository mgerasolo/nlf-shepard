# BatonCommand Rollout - AI Prompt

## Objective

Add `/baton` as a Claude Code command (in addition to the existing skill) for better accessibility.

## Steps

1. **Check for .claude directory**
   ```bash
   ls -la .claude/
   ```
   If it doesn't exist, create it:
   ```bash
   mkdir -p .claude/commands
   ```

2. **Create commands directory if needed**
   ```bash
   mkdir -p .claude/commands
   ```

3. **Copy baton command file**

   Copy the following content to `.claude/commands/baton.md`:

   ```markdown
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

   Then create SUMMARY.md from template with standard fields.

   ### `/baton load` (or just `/baton`)

   1. Read `.claude/CURRENT_CONVERSATION_ID`
   2. Display `.claude/conversations/{conv-id}/SUMMARY.md`
   3. Display filtered entries from `.claude/BUGS.md` (matching conversation ID)
   4. Display filtered entries from `.claude/DECISIONS.md` (matching conversation ID)
   5. Show pending items from `.claude/USER_FEEDBACK.md`

   ### `/baton save [note]`

   1. Read current TODO list and recent file modifications
   2. Update `.claude/conversations/{conv-id}/SUMMARY.md`
   3. Add timestamp and optional note
   4. Update `.claude/CONVERSATION_HISTORY.md` with milestone

   ### `/baton rename <title>`

   1. Read `.claude/CURRENT_CONVERSATION_ID`
   2. Validate title length (max 60 chars)
   3. Update Title field in `.claude/conversations/{conv-id}/SUMMARY.md`
   4. Update entry in `.claude/CONVERSATION_HISTORY.md`

   ### `/baton history`

   Display `.claude/CONVERSATION_HISTORY.md` with all conversations.

   ### `/baton status`

   1. Estimate current token usage
   2. Calculate percentage toward compaction threshold
   3. Show time since last SUMMARY.md update
   4. Recommend save if > 70%

   ### `/baton archive`

   Move completed/fixed/implemented items to `.claude/archive/`.

   ### `/baton search <term>`

   Search across all baton files and return matching entries.

   ### `/baton validate`

   Check file structure integrity and report issues.

   ## File Structure

   ```
   .claude/
   ├── CONVERSATION_HISTORY.md
   ├── BUGS.md
   ├── DECISIONS.md
   ├── ENHANCEMENTS.md
   ├── USER_FEEDBACK.md
   ├── CURRENT_CONVERSATION_ID
   ├── commands/
   │   └── baton.md
   ├── archive/
   └── conversations/
       └── {conv-id}/
           └── SUMMARY.md
   ```

   ## Token Efficiency

   - Full conversation: 50,000+ tokens
   - TLDR summary: 500-2,000 tokens
   - Compression: 25-100x
   - Post-compaction reads: ~1,000 tokens total
   ```

4. **Verify the file was created**
   ```bash
   ls -la .claude/commands/baton.md
   ```

## Verification Checklist

- [ ] `.claude/commands/` directory exists
- [ ] `.claude/commands/baton.md` file exists
- [ ] File contains baton command documentation (check first 10 lines)

## Report

When complete, report:
- Files created/modified
- Any issues encountered
- Verification status
