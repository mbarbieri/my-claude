---
name: reflect
description: Reflect on the current conversation session to extract reusable learnings for CLAUDE.md files and to propose improvements to skills that were actually used or invoked during the session. Use when the user asks to reflect on the session, extract learnings, capture lessons, update CLAUDE.md, improve a skill based on this conversation, or invokes /reflect. Optionally focus on a specific area mentioned by the user.
---

Reflect on everything that happened in this conversation session. Your goal is two-fold:

1. Identify patterns that should be captured in CLAUDE.md files so Claude's performance compounds over time and mistakes don't repeat.
2. Identify concrete improvements to the **skills that were loaded and actually exercised** during this session, so they trigger more reliably and behave better next time.

If the user provided a focus area along with the trigger, weight the analysis toward that area.

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

### Skill Improvements
For each skill that was **invoked or relevant** during the session (whether it triggered correctly, triggered late, failed to trigger, or behaved off when it did), propose targeted edits to its `SKILL.md`. Only include skills that were actually exercised or that should have been but weren't — do not review the full skill catalog.

For each skill, output:

- **Skill name** and the path to its `SKILL.md` (e.g. `~/.claude/skills/<name>/SKILL.md` or the repo path if known).
- **Observation:** what happened in this session — did it trigger when it should have? Was its guidance followed cleanly? Did its instructions cause friction or ambiguity?
- **Proposed change:** a concrete edit. Prefer one of:
  - **Description tweak** — adjust trigger phrases, add missing keywords, or sharpen SKIP conditions so future invocations are more accurate. Quote the current description and the proposed replacement.
  - **Body edit** — add, remove, or rewrite a specific instruction inside the skill body. Quote the before/after.
- **Why:** the evidence from this session that motivates the change (a specific moment, correction, or near-miss).

Skip a skill entirely if it performed well and there is no concrete improvement to suggest. Do not invent issues. If no skills need changes, say so in one line.

## Guidelines

- Be specific and actionable, not vague
- Include concrete examples from the conversation
- Keep each snippet self-contained and copy-paste ready
- Focus on patterns, not one-off incidents
- Prioritize high-impact learnings over minor details
- **Skip learnings that only apply to the current task**—if it won't help in a completely different context, it's not worth documenting
- If the session went smoothly with no significant corrections, say so briefly
