---
allowed-tools: Read, Glob, Grep, Bash(mkdir:*), Bash(ls:*), Write, Edit, AskUserQuestion, Task
description: Start a design/architecture meeting session - creates folder structure and initial documents
argument-hint: <topic-name>
---

# Meeting Start

You are starting a design/architecture team meeting session.

**Topic provided**: $ARGUMENTS

## Your Tasks

### 1. Gather Meeting Information

If the topic was not provided in arguments, ask for it. Then ask:

- Who are the attendees?
- What is the context/background for this discussion?
- Are there any existing documents or prior decisions we should reference?
- What is the primary goal for this session?

### 2. Create Session Folder and Documents

Create a dated folder with this structure:

```
YYYY-MM-DD-<topic-name>/
├── session-notes.md      # Main document for capturing discussion
├── decisions.md          # Decision log for this session
└── open-questions.md     # Questions to resolve later
```

### 3. Set Up session-notes.md

Include frontmatter with summary, then:

```markdown
# <Topic> Design Session

**Date**: YYYY-MM-DD
**Attendees**: [list]
**Goal**: [from user input]

## Context

[Background information provided]

## Related Documents

[Links to relevant existing docs in this repo]

## Discussion

[This section will be filled during the meeting]

## Key Points

[Summarize main points as they emerge]
```

### 4. Set Up decisions.md

```markdown
---
summary: |
  Decision log for <topic> design session on YYYY-MM-DD.
---

# Decisions Log

| # | Decision | Rationale | Dissent |
|---|----------|-----------|---------|
| 1 | | | |
```

### 5. Set Up open-questions.md

```markdown
---
summary: |
  Open questions from <topic> design session on YYYY-MM-DD.
---

# Open Questions

| # | Question | Context | Owner | Status |
|---|----------|---------|-------|--------|
| 1 | | | | Open |
```

### 6. Find Related Context

Search this repository for related documents:
- Previous sessions on this topic
- Related architectural decisions
- Relevant PRDs or feature plans

Link them in the session-notes.md "Related Documents" section.

### 7. Announce Readiness

Once setup is complete, inform the team:
- What folder was created
- What documents are ready
- Any relevant prior context found
- That you're ready to capture discussion

## During the Meeting

- Actively listen and capture key points in session-notes.md
- When a decision is made, immediately log it in decisions.md
- When an unresolved question emerges, add it to open-questions.md
- Ask clarifying questions to ensure accurate capture
- Challenge assumptions when appropriate (but don't derail the flow)
