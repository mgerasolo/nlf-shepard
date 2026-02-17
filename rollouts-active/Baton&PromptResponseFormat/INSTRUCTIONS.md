# Project Standards Update - Standardized Response Format & Baton System

## Quick Prompt (Copy-Paste to Other Projects)

```
I need to update this project with the latest standardized response format and baton context management system. Please:

1. Read the template files from /home/mgerasolo/Dev/self-improving-ai/skeleton_template/
2. Update or create CLAUDE.md with the standardized response format section
3. Ensure .claude-code/skills/baton/ skill is present and up-to-date
4. Verify all sections use bullet list format (dash prefix) for proper markdown rendering

The key changes are:
- Standardized response format for all Claude Code outputs (Title, Request, Tasks, Summary, Next, Required Tasks, USER ACTION NEEDED, Additional Notes, Context)
- Baton context management system for surviving auto-compactions
- Bullet list format requirement (dash prefix) for all sections to force proper line breaks in CommonMark

Reference project: /home/mgerasolo/Dev/self-improving-ai/
```

## Detailed Instructions

### Overview

This update rolls out two critical systems across all development projects:

1. **Standardized Response Format**: Consistent output structure for managing 20-30 conversation tabs
2. **Baton Context Management System**: TLDR-based system for surviving Claude Code auto-compactions (25-100x token compression)

### Why This Matters

**Problem Solved:**
- **Tab Management**: With 20-30 active conversation tabs, impossible to quickly orient when switching contexts
- **Compaction Survival**: Auto-compactions lose 50K+ tokens of context every ~2 hours
- **Consistency**: No standard format means every conversation looks different

**Solution:**
- **Instant Orientation**: Title + Request + Tasks gives immediate context when switching tabs
- **Context Preservation**: Baton system compresses 50K tokens → 1K TLDR, survives compaction
- **Multi-Conversation**: Tagged bugs/decisions allow multiple conversations to work simultaneously

### Core Components

#### 1. Standardized Response Format

**MANDATORY:** All Claude Code responses use this structure:

```markdown
**Title:**
- [Conversation title from baton rename, max 60 chars]

**Request:**
- [Up to 120 char summary of last message, or 2 if last was clarification]

**Tasks:**
- ✅ [Owner] [Details...] Completed task description
- ⬜ [Owner] [Status] [Details...] Incomplete task description

**Summary:**
- Portfolio manager perspective: features, branding, cost, big picture
- Avoid deep technical specifics (function names, implementation details)
- Focus on what was accomplished and why it matters

**Next:**
- [Next immediate action or "None"]

**Required Tasks:**
- Tasks needed to complete objective (if not in task list above)

**USER ACTION NEEDED:**
- Actions requiring human decision or input

**Additional Notes:**
- [Flexible content: code blocks, technical details, extended explanations]

**Context:**
- XX% used, YY% remaining
```

**Critical Rules:**
- Every bold header starts on its own line with blank line before it
- ALL sections use bullet list format (dash prefix) to force proper markdown line breaks
- This is a CommonMark rendering requirement - without bullets, line breaks don't render

**Emoji System:**

**Owner** (one):
- 🤖 Claude Code
- 👨‍🔧 Human Portfolio Manager
- 👤 Other Assignee

**Status** (one, for incomplete tasks):
- ⏳ Need to wait
- 🛑 Blocked
- 🤚 On Hold
- 🏳️ Ready to Start
- 💤 Long term hold, may be dropped
- 💬 Need to discuss first

**Details** (multiple allowed):
- 🔸 Required
- 🔹 Optional Step, User discretion
- ⚠️ May cause issues, concern noted
- ∥ Parallel - can run via sub-agents
- ⚙️ Settings change in web interface
- 🔬 Testing Task
- 📚 Documentation Task

#### 2. Baton Context Management System (v2.0)

**Purpose:** Survive auto-compactions with 25-100x token compression (50K→1K tokens)

**Version 2.0 Enhancements:** Auto-save triggers, conversation switching, smart search, work reports, git integration, custom templates, validation tools, and metrics tracking (20+ commands total)

**File Structure:**
```
.claude/
├── CONVERSATION_HISTORY.md          # All conversations TLDR (~200 tokens)
├── BUGS.md                          # All bugs, tagged with conv-id
├── DECISIONS.md                     # All decisions, tagged with conv-id
├── CURRENT_CONVERSATION_ID          # Current conversation ID
└── conversations/
    └── {conv-id}/
        └── SUMMARY.md               # This conversation's TLDR (~300 tokens)
```

**Auto-Behavior:**

**On Session Start:**
1. Check `.claude/CURRENT_CONVERSATION_ID` for conversation ID
2. Read `.claude/CONVERSATION_HISTORY.md` for overview of all conversations
3. Read `.claude/conversations/{conv-id}/SUMMARY.md` for this conversation's TLDR
4. Read `.claude/BUGS.md` and `.claude/DECISIONS.md` (filter to your conv-id)
5. Total: ~1,000 tokens for full context restoration

**During Work:**
- Update `.claude/conversations/{conv-id}/SUMMARY.md` after significant actions
- Append to `.claude/BUGS.md` when discovering bugs (tag with conv-id)
- Append to `.claude/DECISIONS.md` when making architecture decisions (tag with conv-id)
- Update `.claude/CONVERSATION_HISTORY.md` when completing major milestones

**After Compaction:**
- IMMEDIATELY read `.claude/CONVERSATION_HISTORY.md`
- IMMEDIATELY read your conversation's `SUMMARY.md`
- Resume work with full context
- DO NOT re-read full conversation logs (too expensive)

**Core Commands (5 essential + 15+ advanced):**
- `/baton init` - Initialize new conversation
- `/baton save` - Manual save current state
- `/baton load` - Display current TLDR
- `/baton history` - Show all conversations
- `/baton rename <title>` - Set meaningful conversation title (max 60 chars)

**New in v2.0:**
- `/baton auto-save on|off` - Configure automatic saves at 70%, 85%, 95% thresholds
- `/baton switch <conv-id>` - Switch between conversations
- `/baton search <term>` - Search across conversations, bugs, decisions
- `/baton report [timeframe]` - Generate work summary reports
- `/baton metrics` - Show system effectiveness and token savings
- `/baton validate` - Check file structure integrity
- `/baton template create <name>` - Create custom SUMMARY.md templates
- `/baton git-link` - Associate conversation with git branch
- Plus: context loading, status monitoring, archival tools, and more

**See SKILL.md for complete command reference**

**SUMMARY.md Format:**
- Context in 3 Lines (high-level overview)
- Task Checklist (what's done, what's pending)
- Decisions Made (in this conversation)
- Key Files Created/Modified
- Failed Attempts (don't retry these)
- Next Actions (prioritized list)
- State Snapshot (exact current state)

**Conversation ID Tagging:**
```markdown
**Conv:** conv-20251223-225929
```

### Files to Copy

**From:** `/home/mgerasolo/Dev/self-improving-ai/skeleton_template/`

**Essential Files:**
1. `CLAUDE.md.template` → Rename to `CLAUDE.md` in target project
2. `.claude-code/skills/baton/SKILL.md` → Copy to target project
3. `.claude/` directory structure → Create in target project

**Optional Enhancements:**
- `.claude/ENHANCEMENTS.md` - Track future enhancement ideas
- `.claude/USER_FEEDBACK.md` - Queue questions for user during autonomous sessions

### Update Process

1. **Read Reference Files:**
   ```bash
   # Read the standardized format from reference project
   cat /home/mgerasolo/Dev/self-improving-ai/skeleton_template/CLAUDE.md.template
   cat /home/mgerasolo/Dev/self-improving-ai/skeleton_template/.claude-code/skills/baton/SKILL.md
   ```

2. **Update Target Project CLAUDE.md:**
   - Add "Standardized Response Format" section (if missing)
   - Add "Context Management Protocol" section (if missing)
   - Ensure bullet format throughout
   - Keep project-specific content (overview, architecture, etc.)

3. **Install Baton Skill:**
   ```bash
   # Copy baton skill to target project
   mkdir -p .claude-code/skills/baton/
   cp /home/mgerasolo/Dev/self-improving-ai/skeleton_template/.claude-code/skills/baton/SKILL.md .claude-code/skills/baton/
   ```

4. **Initialize Baton Structure:**
   ```bash
   # Create .claude/ directory structure
   mkdir -p .claude/conversations/
   touch .claude/CONVERSATION_HISTORY.md
   touch .claude/BUGS.md
   touch .claude/DECISIONS.md
   ```

5. **Verify Format:**
   - Test response format in conversation
   - Run `/baton init` to create first conversation
   - Check that line breaks render properly (bullet format critical)

### Validation Checklist

- [ ] CLAUDE.md contains "Standardized Response Format" section
- [ ] CLAUDE.md contains "Context Management Protocol" section
- [ ] All format examples use bullet list format (dash prefix)
- [ ] Baton skill exists in `.claude-code/skills/baton/SKILL.md`
- [ ] `.claude/` directory structure created
- [ ] Emoji legend documented
- [ ] `/baton rename` command available
- [ ] Test response follows standardized format
- [ ] Line breaks render properly (no text concatenation)

### Common Issues

**Issue: Line Breaks Not Rendering**
- **Cause:** CommonMark markdown treats single newlines as spaces
- **Fix:** Use bullet list format (dash prefix) for ALL sections
- **Example:** Change `[Conversation title]` to `- [Conversation title]`

**Issue: Format Inconsistency Across Conversations**
- **Cause:** Template not explicit about bullet requirement
- **Fix:** Ensure template shows `- [content]` format, not `[content]`

**Issue: Baton Commands Not Found**
- **Cause:** Skill not copied to project
- **Fix:** Copy `.claude-code/skills/baton/SKILL.md` from skeleton_template

### Advanced Features

**Risk-Based Decision Framework (USER_FEEDBACK.md):**
- **Auto-Decide:** Low-risk, easily reversible changes (UI tweaks, wording changes)
- **Queue for User:** High-risk, costly, or architectural decisions
- **Document:** All auto-decisions with rationale in SUMMARY.md

**Enhancement Tracking (ENHANCEMENTS.md):**
- Capture great ideas during conversation
- Prevent loss of valuable insights
- Categorize by priority/complexity

### Token Efficiency

**Before Baton:**
- Full conversation: 50,000+ tokens
- Post-compaction: Start from scratch
- Context loss: Total

**After Baton:**
- TLDR summary: 500-2,000 tokens
- Post-compaction read: ~1,000 tokens total
- Compression ratio: 25-100x
- Context loss: Minimal

### Portfolio Manager Perspective

**What This Means for Projects:**
- **Consistency**: All projects use same response format
- **Efficiency**: Quick tab switching, instant orientation
- **Reliability**: Survive auto-compactions without losing work
- **Scalability**: Manage 20-30 concurrent conversations
- **Cost Reduction**: Dramatically lower token usage post-compaction

### Reference Implementation

**Live Example:** `/home/mgerasolo/Dev/self-improving-ai/`
- See `CLAUDE.md` for complete implementation
- See `.claude-code/skills/baton/SKILL.md` for baton commands
- See `.claude/` directory for file structure

### Questions?

**For clarification or issues:**
1. Check reference project: `/home/mgerasolo/Dev/self-improving-ai/`
2. Read skeleton template: `/home/mgerasolo/Dev/self-improving-ai/skeleton_template/`
3. Test format in conversation to verify rendering
4. Ask user if uncertain about project-specific considerations
