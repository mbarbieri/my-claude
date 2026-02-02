---
description: Create implementation plan from feature/requirement with PRD-style discovery and TDD acceptance criteria
---

# Create Tasks: PRD-Informed Task Planning for TDD

Create structured implementation plan that bridges product thinking (PRD) with test-driven development.

## General Guidelines

### Output Style

- **Never explicitly mention TDD** in code, comments, commits, PRs, or issues
- Write natural, descriptive code without meta-commentary about the development process
- The code should speak for itself - TDD is the process, not the product

## Plan File Restriction

**NEVER create, read, or update plan.md files.** Claude Code's internal planning files are disabled for this project. Use other methods to track implementation progress.

## Input

$ARGUMENTS

(If no input provided, check conversation context to see existing work)

## Process

## Discovery Phase

Understand the requirement by asking (use AskUserQuestion if needed):

**Problem Statement**

- What problem does this solve?
- Who experiences this problem?
- What's the current pain point?

**Desired Outcome**

- What should happen after this is built?
- How will users interact with it?
- What does success look like?

**Scope & Constraints**

- What's in scope vs. out of scope?
- Any technical constraints?
- Dependencies on other systems/features?

**Context Check**

- Search codebase for related features/modules
- Check for existing test files that might be relevant

### Create Tasks

For each task, use the TaskCreate tool with:

- **subject**: Action-oriented, specific title in imperative form (e.g., "Add JWT token validation middleware")
- **description**: Include context, technical approach, and acceptance criteria
- **activeForm**: Present continuous form for spinner display (e.g., "Adding JWT token validation")

**Task Description Structure:**

```
## Context
Why this task exists and how it fits into the larger feature.

## Technical Approach
- Key interfaces/types needed
- Algorithm or approach
- Libraries or patterns to use
- Known gotchas or considerations

## Acceptance Criteria
- Given-When-Then format
- Concrete, verifiable conditions
- Cover main case + edge cases
- Map 1:1 to future tests
```

**Title Best Practices:**

- Good: "Add JWT token validation middleware"
- Bad: "Authentication stuff"

### Set Up Dependencies

After creating tasks, use TaskUpdate to establish dependencies:

- **addBlockedBy**: Tasks that must complete before this one can start
- **addBlocks**: Tasks that cannot start until this one completes

### Validation

After creating tasks, verify:

- Each task has clear acceptance criteria in description
- Dependencies are mapped correctly
- Tasks are ordered by implementation sequence
- Each task is small enough for TDD (if too big, break down more)

Use TaskList to review the created tasks.

## Key Principles

**From PRD World:**

- Start with user problems, not solutions
- Define success criteria upfront
- Understand constraints and scope

**From TDD World:**

- Make acceptance criteria test-ready
- Break work into small, testable pieces
- Each task should map to test(s)

## Integration with Other Commands

- **Before /create-tasks**: Use `/spike` if you need technical exploration first
- **After /create-tasks**: Use `/red` to start TDD on first task
- **During work**: Use TaskUpdate to add notes/findings back to tasks
- **When stuck**: Use TaskGet to review acceptance criteria
