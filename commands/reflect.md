---
description: Reflect on session to extract learnings for CLAUDE.md files
argument-hint: [optional focus area]
---

Reflect on everything that happened in this conversation session. Your goal is to identify patterns that should be captured in CLAUDE.md files so Claude's performance compounds over time and mistakes don't repeat.

Additional focus: $ARGUMENTS

## Analysis Framework

Analyze the conversation for:

### 1. Mistakes & Corrections
- What did Claude get wrong initially?
- What assumptions were incorrect?
- Where did Claude need multiple attempts?

### 2. User Steering
- Where did the user redirect or correct Claude?
- What preferences did the user express (explicitly or implicitly)?
- What approaches did the user reject or modify?

### 3. Misunderstandings
- What did Claude misinterpret about the request?
- What context was missing that caused confusion?
- What domain knowledge gaps appeared?

### 4. Successful Patterns
- What worked well that should be reinforced?
- What approaches did the user approve of?

## Output Format

For each finding, produce a **copy-paste ready snippet** for CLAUDE.md files:

```markdown
## [Category]

### [Specific Learning]

[Concise instruction that future Claude sessions should follow]

Example:
- Good: [what to do]
- Bad: [what to avoid]
```

## Output Structure

Organize your output into these sections:

### Project-Specific (for project CLAUDE.md)
Learnings specific to this codebase, its patterns, or conventions.

### Personal Preferences (for ~/.claude/CLAUDE.md)
User preferences that apply across all projects.

### General Improvements (for any CLAUDE.md)
Broadly applicable learnings about working with this user. These must be generalizable beyond the current task—if a learning only applies to this specific task, skip it entirely. Good general improvements describe patterns in how the user prefers to work, communicate, or make decisions that will apply to future unrelated tasks.

## Guidelines

- Be specific and actionable, not vague
- Include concrete examples from the conversation
- Keep each snippet self-contained and copy-paste ready
- Focus on patterns, not one-off incidents
- Prioritize high-impact learnings over minor details
- **Skip learnings that only apply to the current task**—if it won't help in a completely different context, it's not worth documenting
- If the session went smoothly with no significant corrections, say so briefly
