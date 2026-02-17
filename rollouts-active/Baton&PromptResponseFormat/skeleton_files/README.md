# Skeleton Files - Copy These to Your Projects

This directory contains all the files you need to copy to your projects.

## Directory Structure

```
skeleton_files/
├── CLAUDE.md.template              # Main project configuration (rename to CLAUDE.md)
├── .claude-code/
│   └── skills/
│       └── baton/
│           └── SKILL.md            # Baton commands (/baton init, save, load, etc.)
└── .claude/
    ├── CONVERSATION_HISTORY.md     # All conversations TLDR
    ├── BUGS.md                     # Bug tracking with conversation tags
    ├── DECISIONS.md                # Architecture decisions with tags
    ├── ENHANCEMENTS.md             # Future enhancement ideas (optional)
    ├── USER_FEEDBACK.md            # Questions queue for autonomous sessions (optional)
    └── conversations/              # Directory for conversation-specific SUMMARY.md files
```

## Files to Copy

### Required Files

**1. CLAUDE.md.template**
- **Copy to:** `{project-root}/CLAUDE.md`
- **Purpose:** Main project configuration with standardized format and baton documentation
- **Action:** Rename to CLAUDE.md, merge with existing CLAUDE.md if present

**2. .claude-code/skills/baton/SKILL.md**
- **Copy to:** `{project-root}/.claude-code/skills/baton/SKILL.md`
- **Purpose:** Baton commands for context management
- **Action:** Create directory structure if needed, copy file

**3. .claude/CONVERSATION_HISTORY.md**
- **Copy to:** `{project-root}/.claude/CONVERSATION_HISTORY.md`
- **Purpose:** Track all conversations in project
- **Action:** Copy as-is

**4. .claude/BUGS.md**
- **Copy to:** `{project-root}/.claude/BUGS.md`
- **Purpose:** Track bugs with conversation tagging
- **Action:** Copy as-is

**5. .claude/DECISIONS.md**
- **Copy to:** `{project-root}/.claude/DECISIONS.md`
- **Purpose:** Track architecture decisions with conversation tagging
- **Action:** Copy as-is

**6. .claude/conversations/**
- **Copy to:** `{project-root}/.claude/conversations/`
- **Purpose:** Directory for conversation-specific SUMMARY.md files
- **Action:** Create empty directory

### Optional Files

**7. .claude/ENHANCEMENTS.md**
- **Copy to:** `{project-root}/.claude/ENHANCEMENTS.md`
- **Purpose:** Track future enhancement ideas
- **Action:** Copy if you want to track enhancement ideas

**8. .claude/USER_FEEDBACK.md**
- **Copy to:** `{project-root}/.claude/USER_FEEDBACK.md`
- **Purpose:** Queue questions for user during autonomous sessions
- **Action:** Copy if you run long autonomous sessions

## Quick Copy Commands

### For New Projects (No existing CLAUDE.md)

```bash
# Navigate to your project
cd /path/to/your/project

# Copy CLAUDE.md
cp /home/mgerasolo/Dev/self-improving-ai/AppServices/UpdateAllDevProjects/Baton\&PromptResponseFormat/skeleton_files/CLAUDE.md.template CLAUDE.md

# Copy baton skill
mkdir -p .claude-code/skills/baton
cp /home/mgerasolo/Dev/self-improving-ai/AppServices/UpdateAllDevProjects/Baton\&PromptResponseFormat/skeleton_files/.claude-code/skills/baton/SKILL.md .claude-code/skills/baton/

# Copy .claude directory structure
cp -r /home/mgerasolo/Dev/self-improving-ai/AppServices/UpdateAllDevProjects/Baton\&PromptResponseFormat/skeleton_files/.claude .
```

### For Existing Projects (Have CLAUDE.md)

```bash
# Navigate to your project
cd /path/to/your/project

# Backup existing CLAUDE.md
cp CLAUDE.md CLAUDE.md.backup

# Use Claude Code to merge:
# 1. Read skeleton_files/CLAUDE.md.template
# 2. Read your existing CLAUDE.md
# 3. Merge: Keep project-specific content, add new sections
# 4. Verify format uses bullet lists throughout

# Copy baton skill
mkdir -p .claude-code/skills/baton
cp /home/mgerasolo/Dev/self-improving-ai/AppServices/UpdateAllDevProjects/Baton\&PromptResponseFormat/skeleton_files/.claude-code/skills/baton/SKILL.md .claude-code/skills/baton/

# Copy .claude directory structure (won't overwrite if exists)
cp -r -n /home/mgerasolo/Dev/self-improving-ai/AppServices/UpdateAllDevProjects/Baton\&PromptResponseFormat/skeleton_files/.claude .
```

## File Descriptions

### CLAUDE.md.template

Contains:
- Project overview template
- Standardized Response Format section (MANDATORY for all responses)
- Context Management Protocol (baton system)
- Emoji legend (Owner, Status, Details)
- Examples showing proper bullet list format

**Key Features:**
- All sections use bullet list format (dash prefix) for proper line break rendering
- Portfolio manager perspective guidelines
- 8-section response structure
- Token efficiency documentation

### .claude-code/skills/baton/SKILL.md

Contains:
- `/baton init` - Initialize new conversation with SUMMARY.md
- `/baton save` - Manually save current state to SUMMARY.md
- `/baton load` - Display current conversation TLDR
- `/baton history` - Show all conversations
- `/baton rename <title>` - Set meaningful conversation title

**Key Features:**
- Auto-behavior triggers (on session start, during work, after compaction)
- SUMMARY.md template and format
- Conversation ID tagging system
- 25-100x token compression

### .claude/CONVERSATION_HISTORY.md

**Purpose:** Master list of all conversations in project
**Format:** Conversation ID, title, date, status, key outcomes
**Updated:** When conversation completes major milestone

### .claude/BUGS.md

**Purpose:** Shared bug tracking across all conversations
**Format:** Tagged with conversation ID for multi-conversation awareness
**Updated:** When bugs discovered during any conversation

### .claude/DECISIONS.md

**Purpose:** Shared architecture decisions across all conversations
**Format:** Tagged with conversation ID, includes rationale and date
**Updated:** When architectural decisions made in any conversation

### .claude/ENHANCEMENTS.md (Optional)

**Purpose:** Capture future enhancement ideas
**Format:** Priority and complexity categorization
**Updated:** When great ideas emerge during conversations

### .claude/USER_FEEDBACK.md (Optional)

**Purpose:** Queue questions for user during autonomous work
**Format:** Risk-based categorization (auto-decide vs. ask user)
**Updated:** During autonomous sessions when decisions needed

## Verification

After copying, verify:

```bash
# Check files exist
ls CLAUDE.md
ls .claude-code/skills/baton/SKILL.md
ls .claude/CONVERSATION_HISTORY.md
ls .claude/BUGS.md
ls .claude/DECISIONS.md

# Check CLAUDE.md has new sections
grep "Standardized Response Format" CLAUDE.md
grep "Context Management Protocol" CLAUDE.md

# Test baton commands in Claude Code conversation
# Run: /baton init
# Verify: Creates .claude/CURRENT_CONVERSATION_ID and conversation folder
```

## Next Steps

1. Copy files using commands above
2. Test `/baton init` in conversation
3. Verify standardized format works
4. Check line breaks render properly
5. Commit to git (if applicable)

## Questions?

See parent directory documentation:
- [QUICK_PROMPT.txt](../QUICK_PROMPT.txt) - Copy-paste prompt
- [INSTRUCTIONS.md](../INSTRUCTIONS.md) - Comprehensive guide
- [CHECKLIST.md](../CHECKLIST.md) - Verification checklist
- [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) - One-page cheat sheet
