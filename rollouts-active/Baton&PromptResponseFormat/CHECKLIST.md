# Project Standards Update Checklist

Use this checklist for each project you update.

## Pre-Update

- [ ] Note current project path: `_______________________________`
- [ ] Verify project has existing CLAUDE.md (or note that one needs to be created)
- [ ] Check if `.claude-code/skills/` directory exists
- [ ] Backup existing CLAUDE.md (if it exists): `cp CLAUDE.md CLAUDE.md.backup`

## Core Updates

### 1. CLAUDE.md Updates

- [ ] Read reference template: `/home/mgerasolo/Dev/self-improving-ai/skeleton_template/CLAUDE.md.template`
- [ ] Add or update "Standardized Response Format" section
  - [ ] Includes MANDATORY and CRITICAL rules
  - [ ] Template shows bullet format (dash prefix) for ALL sections
  - [ ] Example section uses bullet format throughout
  - [ ] Emoji legend included (Owner, Status, Details)
- [ ] Add or update "Context Management Protocol" section
  - [ ] Auto-Behavior (On Session Start, During Work, After Compaction)
  - [ ] File Structure diagram
  - [ ] SUMMARY.md format guidelines
  - [ ] Conversation ID tagging
  - [ ] Manual Control commands
  - [ ] Token Efficiency stats
- [ ] Preserve all project-specific content (Overview, Architecture, Deployment, etc.)
- [ ] Verify formatting: blank line before every bold header

### 2. Baton Skill Installation

- [ ] Create directory: `mkdir -p .claude-code/skills/baton/`
- [ ] Copy skill file: `cp /home/mgerasolo/Dev/self-improving-ai/skeleton_template/.claude-code/skills/baton/SKILL.md .claude-code/skills/baton/`
- [ ] Verify file exists: `ls -la .claude-code/skills/baton/SKILL.md`
- [ ] Verify baton v2.0 installed (check for 20+ commands in SKILL.md)
- [ ] Check skill includes core commands:
  - [ ] `/baton init`
  - [ ] `/baton save`
  - [ ] `/baton load`
  - [ ] `/baton history`
  - [ ] `/baton rename <title>`
- [ ] Verify v2.0 enhancements present:
  - [ ] `/baton auto-save` (automatic saves)
  - [ ] `/baton search` (search functionality)
  - [ ] `/baton switch` (conversation switching)
  - [ ] `/baton report` (work summaries)
  - [ ] `/baton metrics` (system metrics)
  - [ ] `/baton validate` (health check)
  - [ ] `/baton template` (custom templates)
  - [ ] `/baton git-link` (git integration)

### 3. Directory Structure

- [ ] Create base directory: `mkdir -p .claude/conversations/`
- [ ] Create shared files:
  - [ ] `touch .claude/CONVERSATION_HISTORY.md`
  - [ ] `touch .claude/BUGS.md`
  - [ ] `touch .claude/DECISIONS.md`
- [ ] Add initial content to CONVERSATION_HISTORY.md:
  ```markdown
  # Conversation History

  ## Active Conversations

  (Conversations will be listed here by baton system)

  ## Completed Conversations

  (Completed conversations archived here)
  ```
- [ ] Add initial content to BUGS.md:
  ```markdown
  # Bugs and Issues

  Track bugs discovered during conversations, tagged with conversation ID.

  Format:
  **Conv:** conv-YYYYMMDD-HHMMSS
  **Bug:** Description
  **Status:** Open/Fixed/Wont-Fix
  ```
- [ ] Add initial content to DECISIONS.md:
  ```markdown
  # Architecture Decisions

  Track architectural and technical decisions, tagged with conversation ID.

  Format:
  **Conv:** conv-YYYYMMDD-HHMMSS
  **Decision:** Description
  **Rationale:** Why this decision was made
  **Date:** YYYY-MM-DD
  ```

### 4. Optional Enhancements (v2.0)

- [ ] Create `.claude/ENHANCEMENTS.md` for future feature ideas
- [ ] Create `.claude/USER_FEEDBACK.md` for autonomous session questions
- [ ] Create `.claude/settings.json` for auto-save configuration
- [ ] Create `.claude/templates/` directory for custom templates
- [ ] Create `.claude/archive/` directory for archival system
- [ ] Add to .gitignore (if not already present):
  ```
  .claude/conversations/
  .claude/CURRENT_CONVERSATION_ID
  .claude/settings.json
  .claude/git_links.json
  ```

## Verification

### Format Testing

- [ ] Start new conversation or continue existing
- [ ] Ask Claude to respond using standardized format
- [ ] Verify response includes all 8 sections:
  - [ ] Title (with bullet)
  - [ ] Request (with bullet)
  - [ ] Tasks (with dash-prefix checkboxes)
  - [ ] Summary (with bullets)
  - [ ] Next (with bullet)
  - [ ] Required Tasks (with bullets)
  - [ ] USER ACTION NEEDED (with bullets)
  - [ ] Additional Notes (with bullets)
  - [ ] Context (with bullet)
- [ ] Check line breaks render properly (no text concatenation)
- [ ] Verify bold headers have blank lines before them

### Baton Testing

**Core Commands:**
- [ ] Run `/baton init` in conversation
- [ ] Verify creates conversation directory: `ls .claude/conversations/`
- [ ] Check CURRENT_CONVERSATION_ID file created: `cat .claude/CURRENT_CONVERSATION_ID`
- [ ] Verify SUMMARY.md created in conversation folder
- [ ] Test `/baton rename "Test Title"` command
- [ ] Verify title appears in SUMMARY.md
- [ ] Test `/baton load` shows current TLDR
- [ ] Test `/baton history` shows conversation list

**v2.0 Features (Optional but Recommended):**
- [ ] Test `/baton auto-save status` shows configuration
- [ ] Test `/baton search test` finds results
- [ ] Test `/baton metrics` shows system stats
- [ ] Test `/baton validate` checks file structure
- [ ] Test `/baton status` shows token usage
- [ ] Verify settings.json created by `/baton init`

### Emoji System Testing

- [ ] Verify Claude uses Owner emojis (🤖👨‍🔧👤)
- [ ] Check Status emojis on incomplete tasks (⏳🛑🤚🏳️💤💬)
- [ ] Verify Details emojis on tasks (🔸🔹⚠️∥⚙️🔬📚)
- [ ] Confirm emoji legend documented in CLAUDE.md

### Integration Testing

- [ ] Create test task with multiple steps
- [ ] Verify task tracking works in Tasks section
- [ ] Check Summary focuses on portfolio manager perspective (features, big picture)
- [ ] Confirm no deep technical details in Summary (those go in Additional Notes)
- [ ] Test "None" one-line format for empty sections
- [ ] Verify context percentage appears at end

## Post-Update

### Documentation

- [ ] Note completion date: `_______________________________`
- [ ] Document any project-specific customizations made
- [ ] Update project inventory/tracking system
- [ ] Note any issues encountered for future projects

### Git

- [ ] Review changes: `git diff CLAUDE.md`
- [ ] Stage changes: `git add CLAUDE.md .claude-code/ .claude/`
- [ ] Commit: `git commit -m "Add standardized response format and baton context management system"`
- [ ] Push (if applicable): `git push`

### Cleanup

- [ ] Remove backup file: `rm CLAUDE.md.backup` (if update successful)
- [ ] Test format one more time in fresh conversation
- [ ] Mark project as "Updated" in project tracking

## Troubleshooting

### Issue: Line Breaks Not Rendering

**Symptoms:** Text runs together like "Title: Project Name Request: Do the thing Tasks: ✅..."

**Fix:**
1. Check template in CLAUDE.md shows bullet format: `- [Conversation title]`
2. Verify example section uses bullet format throughout
3. Ensure ALL sections use dash prefix, not just multi-item sections
4. Test again - line breaks should now work

### Issue: Baton Commands Not Found

**Symptoms:** `/baton` commands not recognized

**Fix:**
1. Verify skill file exists: `ls .claude-code/skills/baton/SKILL.md`
2. Check file has content: `wc -l .claude-code/skills/baton/SKILL.md` (should be ~200+ lines)
3. Restart Claude Code conversation (skills loaded at start)
4. Try command again

### Issue: Format Inconsistent

**Symptoms:** Some responses follow format, others don't

**Fix:**
1. Check CRITICAL rule in CLAUDE.md: "Every bold header must start on its own line with blank line before it"
2. Verify MANDATORY rule: "All responses must use this format"
3. Remind Claude of format requirements
4. Ask Claude to re-read CLAUDE.md

### Issue: Context Not Restoring After Compaction

**Symptoms:** Claude loses context after auto-compaction

**Fix:**
1. Verify `.claude/` directory structure exists
2. Check CURRENT_CONVERSATION_ID has conversation ID
3. Verify SUMMARY.md exists for that conversation
4. Update SUMMARY.md with current state before next compaction
5. Test compaction recovery manually

## Success Criteria

Project update is complete when:

✅ CLAUDE.md includes both new sections (Standardized Response Format + Context Management Protocol)
✅ Baton v2.0 skill installed with 20+ commands available
✅ `.claude/` directory structure created with initial files
✅ Format verification shows all 8 sections with proper line breaks
✅ Core baton commands execute successfully (init, save, load, history, rename)
✅ v2.0 features available (auto-save, search, metrics, validate)
✅ Emoji system documented and in use
✅ Changes committed to git (if applicable)
✅ Project marked as updated in tracking system

## Notes

Project-specific considerations:

```
[Add any notes about this specific project's quirks, customizations, or special requirements]
```

---

**Updated by:** ________________
**Date:** ________________
**Time spent:** ________________
**Issues encountered:** ________________
