---
allowed-tools: Read, Glob, Grep, Bash(./generate-index.sh:*), Write, Edit, Task
description: Wrap up a design/architecture meeting - summarizes decisions, validates consistency, updates index
argument-hint: [folder-path]
---

# Meeting Wrap

You are wrapping up a design/architecture team meeting session.

**Session folder**: $ARGUMENTS

## Your Tasks

### 1. Locate the Session

If no folder path was provided:
- Look for today's dated folders (YYYY-MM-DD-*)
- If multiple exist, ask which session to wrap up
- If none exist, ask for the folder path

### 2. Read Session Documents

Read all documents in the session folder:
- session-notes.md
- decisions.md
- open-questions.md
- Any other documents created during the session

### 3. Generate Summary

Create or update a `summary.md` in the session folder:

```markdown
---
summary: |
  Summary of <topic> design session: [1-2 line overview of outcomes]
---

# Session Summary: <Topic>

**Date**: YYYY-MM-DD
**Attendees**: [list]

## Decisions Made

[Bullet list of all decisions from decisions.md with brief rationale]

## Open Questions

[Bullet list of unresolved questions with owners if assigned]

## Next Steps

[Action items that emerged, with owners if identified]

## Key Discussion Points

[3-5 bullet summary of the main themes discussed]
```

### 4. Verification Check

Analyze the session documents for:

- **Contradictions**: Do any decisions conflict with each other?
- **Missing context**: Are there decisions without clear rationale?
- **Ambiguity**: Are there statements that could be interpreted multiple ways?
- **Dependencies**: Are there implicit dependencies that should be explicit?
- **Prior conflicts**: Do any decisions conflict with previous decisions in this repo?

Report any issues found and ask the team to clarify or confirm.

### 5. Update Frontmatter Summaries

Ensure all documents in the session folder have accurate frontmatter summaries reflecting their final content.

### 6. Regenerate Index

Run the index generator:
```bash
./generate-index.sh
```

### 7. Final Report

Present to the team:

```
## Session Complete: <Topic>

### Decisions (X total)
- [list each decision briefly]

### Open Questions (X total)
- [list each question briefly]

### Next Steps
- [list action items]

### Issues Found
- [any contradictions, ambiguities, or concerns]
  OR
- None identified

### Documents Updated
- [list of files created/modified]

Index regenerated ✓
```

### 8. Offer Follow-ups

Ask if the team wants to:
- Create follow-up tasks or issues from open questions
- Schedule a continuation session
- Link this session to other documents
- Make any corrections to what was captured
