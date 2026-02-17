# Quick Reference Card - Standardized Format & Baton System

## Standard Response Format (All 8 Sections)

```markdown
**Title:**
- [Max 60 chars]

**Request:**
- [Max 120 chars, summarize last 1-2 messages]

**Tasks:**
- ✅ [Owner] [Details] Completed task
- ⬜ [Owner] [Status] [Details] Pending task

**Summary:**
- Portfolio perspective: features, cost, big picture
- No deep technical details

**Next:**
- [Next action or "None"]

**Required Tasks:**
- [Tasks needed beyond above list]

**USER ACTION NEEDED:**
- [User decisions required]

**Additional Notes:**
- [Code blocks, technical details]

**Context:**
- XX% used, YY% remaining
```

## Emoji Quick Reference

### Owner (Pick One)
- 🤖 Claude Code
- 👨‍🔧 Human PM
- 👤 Other

### Status (Pick One, Incomplete Tasks Only)
- ⏳ Wait
- 🛑 Blocked
- 🤚 Hold
- 🏳️ Ready
- 💤 Long-term
- 💬 Discuss

### Details (Multiple OK)
- 🔸 Required
- 🔹 Optional
- ⚠️ Concern
- ∥ Parallel
- ⚙️ Settings
- 🔬 Test
- 📚 Docs

## Baton Commands (v2.0 - 20+ Available)

**Core Commands:**
```bash
/baton init              # Start new conversation
/baton save              # Save current state
/baton load              # Show TLDR
/baton history           # List conversations
/baton rename <title>    # Set conversation title
```

**v2.0 Key Features:**
```bash
/baton auto-save on      # Enable auto-save at 70%, 85%, 95%
/baton search <term>     # Search all conversations/bugs/decisions
/baton switch <conv-id>  # Switch between conversations
/baton report --week     # Generate weekly work summary
/baton metrics           # Show token savings & effectiveness
/baton validate          # Check file structure health
/baton template create   # Create custom SUMMARY.md template
/baton git-link          # Link conversation to git branch
```

**See `.claude-code/skills/baton/SKILL.md` for all 20+ commands**

## File Structure

```
.claude/
├── CONVERSATION_HISTORY.md
├── BUGS.md
├── DECISIONS.md
├── CURRENT_CONVERSATION_ID
└── conversations/
    └── {conv-id}/
        └── SUMMARY.md
```

## Critical Rules

1. **Every bold header** on own line with blank line before
2. **All sections** use bullet list format (dash prefix)
3. **MANDATORY** format for all responses
4. **Portfolio manager** perspective in Summary
5. **Technical details** go in Additional Notes, not Summary

## Update Process (5 Steps)

1. **Copy** QUICK_PROMPT.txt
2. **Paste** into target project conversation
3. **Verify** using CHECKLIST.md
4. **Test** format in response
5. **Commit** changes to git

## Verification Checklist

- [ ] All 8 sections present
- [ ] Bullets on ALL sections (dash prefix)
- [ ] Line breaks render properly
- [ ] `/baton` core commands work (init, save, load, history, rename)
- [ ] `/baton` v2.0 features available (auto-save, search, metrics, validate)
- [ ] `.claude/` structure exists
- [ ] settings.json configured (v2.0)
- [ ] Emoji system documented

## Common Issues

| Issue | Fix |
|-------|-----|
| Line breaks missing | Add bullets: `- [content]` |
| `/baton` not found | Copy skill to `.claude-code/skills/baton/` |
| Format inconsistent | Re-read CLAUDE.md, verify MANDATORY rule |
| Context lost | Update SUMMARY.md before compaction |

## Token Efficiency (v2.0 Enhanced)

| Before | After (v2.0) |
|--------|--------------|
| 50K tokens | 1K tokens |
| Start from scratch | Full context restore |
| Total context loss | 25-100x compression |
| Manual saves only | Auto-save at 70%, 85%, 95% |
| No metrics | Track savings with `/baton metrics` |

## Files to Reference

- **Template:** `/home/mgerasolo/Dev/self-improving-ai/skeleton_template/CLAUDE.md.template`
- **Baton Skill:** `/home/mgerasolo/Dev/self-improving-ai/skeleton_template/.claude-code/skills/baton/SKILL.md`
- **Reference:** `/home/mgerasolo/Dev/self-improving-ai/CLAUDE.md`

## Time Estimates

- **Per project:** 8-12 minutes
- **20 projects:** 2.5-4 hours
- **Reading docs:** 15-30 minutes (one time)

## Quick Command Blocks

### Setup Baton
```bash
mkdir -p .claude/conversations/
touch .claude/{CONVERSATION_HISTORY,BUGS,DECISIONS}.md
mkdir -p .claude-code/skills/baton/
cp ~/Dev/self-improving-ai/skeleton_template/.claude-code/skills/baton/SKILL.md .claude-code/skills/baton/
```

### Verify Update
```bash
# Check files exist
ls .claude-code/skills/baton/SKILL.md
ls .claude/CONVERSATION_HISTORY.md

# Check CLAUDE.md has new sections
grep "Standardized Response Format" CLAUDE.md
grep "Context Management Protocol" CLAUDE.md
```

### Commit Changes
```bash
git add CLAUDE.md .claude-code/ .claude/
git commit -m "Add standardized response format and baton context management"
git push
```

---

**Print this page for desk reference**
**Version:** 1.0 | **Date:** 2025-12-25
