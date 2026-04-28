---
name: implement
description: Use when the user asks to implement a feature, add a class or method, fix a bug, refactor code, add test coverage, or run autonomously to drive work forward. Supports explicit phase selection via the first argument (red | green | refactor | forever) and infers the phase from conversation and test state when no phase is given. With no arguments at all, defaults to forever (autonomous loop). Do NOT use for code review, CI/CD setup, testing questions, infrastructure, or documentation tasks.
---

# Implement

Enforces the Red-Green-Refactor cycle and the autonomous `forever` driver from a single entry point. Apply the **Shared Rules** section plus **exactly one** Phase section per invocation — do not read the other phase sections.

## Phase Dispatch

Read `$ARGUMENTS` (the user's input after the skill name).

1. **No arguments at all** → `PHASE = forever`. The user invoked `/implement` bare; they want the autonomous driver to find and execute work. This matches the intent of the old `/forever`.

2. **First token matches `{red, green, refactor, forever}`** (case-insensitive) → `PHASE = that token`. The remainder of `$ARGUMENTS` is `CONTEXT` (test name, implementation description, refactoring goal, or loop seed).

3. **Arguments present but the first token is not a phase word** → infer `PHASE` from the conversation and current test state:
   - No tests, or all tests passing, and the user describes new behavior → `red`
   - Exactly one relevant failing test → `green`
   - All relevant tests green and the user asks to clean up / rename / extract / simplify → `refactor`
   - User says "continue", "keep going", "drive", "go" → `forever`
   - Otherwise → `red` (safest default; starts a fresh cycle)

Before acting, **state the chosen phase in one short line** so the user can correct it:

```
Entering <PHASE> phase.
```

Then apply **Shared Rules** plus the matching **Phase: <PHASE>** section below. Do NOT apply rules from other phase sections — each phase has its own strictness contract and mixing them weakens enforcement.

## Shared Rules (all phases)

### Output Style

- **Never explicitly mention TDD** in code, comments, commits, PRs, or issues
- Write natural, descriptive code without meta-commentary about the development process
- The code should speak for itself — TDD is the process, not the product


### Plan File Restriction

**NEVER create, read, or update plan.md files.** Claude Code's internal planning files are disabled for this project. Use other methods to track implementation progress (e.g., comments, todo lists, or external tools).

### Fallback when no context

If no `CONTEXT` was given and you need something to work on:

1. Look at the conversation for an immediate thing
2. Run `bd ready` to see what to work on next

### TDD Fundamentals — The Cycle

The foundation is the Red-Green-Refactor cycle:

1. **Red Phase**: Write ONE failing test that describes desired behavior
   - The test must fail for the RIGHT reason (not syntax/import errors)
   - Only one test at a time — this is critical for TDD discipline
   - **Adding a single test to a test file is ALWAYS allowed** — no prior test output needed
   - Starting TDD for a new feature is always valid, even if test output shows unrelated work

2. **Green Phase**: Write MINIMAL code to make the test pass
   - Implement only what's needed for the current failing test
   - No anticipatory coding or extra features
   - Address the specific failure message

3. **Refactor Phase**: Improve code structure while keeping tests green
   - Only allowed when relevant tests are passing
   - Requires proof that tests have been run and are green
   - Applies to BOTH implementation and test code
   - No refactoring with failing tests — fix them first

### Core Violations

1. **Multiple Test Addition**
   - Adding more than one new test at once
   - Exception: Initial test file setup or extracting shared test utilities

2. **Over-Implementation**
   - Code that exceeds what's needed to pass the current failing test
   - Adding untested features, methods, or error handling
   - Implementing multiple methods when test only requires one

3. **Premature Implementation**
   - Adding implementation before a test exists and fails properly
   - Adding implementation without running the test first
   - Refactoring when tests haven't been run or are failing

### Critical Principle: Incremental Development

Each step should address ONE specific issue:

- Test fails "not defined" → Create empty stub/class only
- Test fails "not a function" → Add method stub only
- Test fails with assertion → Implement minimal logic only

### Optional Pre-Phase: Spike Phase

In rare cases where the problem space, interface, or expected behavior is unclear, a **Spike Phase** may be used **before the Red Phase**. This is **not part of the regular TDD workflow** and must only be applied under exceptional circumstances.

- The goal of a Spike is **exploration and learning**, not implementation
- Spike code is **disposable** and **must not** be merged or reused directly
- Once sufficient understanding is achieved, all spike code is discarded, and normal TDD resumes from the Red Phase
- A Spike is justified only when it is impossible to define a meaningful failing test due to technical uncertainty or unknown system behavior

### General Information

- Sometimes the test output shows as no tests have been run when a new test is failing due to a missing import or constructor. In such cases, allow simple stubs to make imports and test infrastructure work. If stuck, check whether a stub was forgotten.
- It is never allowed to introduce new logic without evidence of relevant failing tests. However, stubs and simple implementation to make imports and test infrastructure work is fine.
- In the refactor phase, it is perfectly fine to refactor both test and implementation code. Completely new functionality is not allowed. Types, cleanup, abstractions, and helpers are allowed as long as they do not introduce new behavior.
- Adding types, interfaces, or a constant to replace magic values is fine during refactoring.
- Provide helpful directions so progress does not stall.

---

## Phase: RED

**Apply this section only if PHASE == red.** If PHASE is anything else, skip this section entirely.

### Rules

- Add exactly **ONE** new test. No more.
  - Exception: For browser-level tests or expensive setup (e.g., Storybook `*.stories.tsx`), group multiple assertions within a single test block to avoid redundant setup — but only when adding assertions to an existing interaction flow. If new user interactions are required, still create a new test. Split files by category if they exceed ~1000 lines.
- The test must fail for the RIGHT reason (not syntax/import errors).
- **Adding a single test to a test file is ALWAYS allowed** — no prior test output needed.
- Starting TDD for a new feature is always valid, even if test output shows unrelated work.
- For DOM-based tests, use `data-testid` attributes to select elements rather than CSS classes, tag names, or text content.
- Avoid hard-coded timeouts in the form of `sleep()` or `timeout: 5000`. Use proper async patterns (`waitFor`, `findBy*`, event-based sync) instead and rely on global test configs for timeout settings.

### Test Structure (AAA Pattern)

Structure each test with clear phases:

- **Arrange**: Set up test data and preconditions (keep minimal)
- **Act**: Execute the single action being tested
- **Assert**: Verify the expected outcome with specific assertions

---

## Phase: GREEN

**Apply this section only if PHASE == green.** If PHASE is anything else, skip this section entirely.

### Rules

- Write the **minimal** code to make the one failing test pass.
- Implement only what's needed for the current failing test.
- No anticipatory coding or extra features.
- Address the specific failure message — match it one step at a time:
  - "not defined" → create the empty stub/class only
  - "not a function" → add the method stub only
  - Assertion failure → implement the minimal logic only
- Do NOT add a second test in this phase. If you find yourself wanting to, finish the current green first, then switch to `red` for the next test.
- Do NOT refactor untested or still-red code here. If the test passes but the code is ugly, switch to `refactor` afterwards.

---

## Phase: REFACTOR

**Apply this section only if PHASE == refactor.** If PHASE is anything else, skip this section entirely.

### Preconditions

- All relevant tests must be GREEN and must have been run recently. If not, stop and go back to the phase that addresses the failing tests (usually `green`).
- Do not introduce new behavior. Types, cleanup, abstractions, helpers, and renaming magic values are fine as long as they do not add functionality.
- Applies to BOTH implementation and test code.

### Code Complexity Signals

Look for these refactoring opportunities:

- [ ] Nesting > 3 levels deep
- [ ] Functions > 20 lines
- [ ] Duplicate code blocks
- [ ] Abstractions with single implementation
- [ ] "Just in case" parameters or config
- [ ] Magic values without names
- [ ] Dead/unused code

### Watch for Brittle Tests

When refactoring implementation, watch for **Peeping Tom** tests that:

- Test private methods or internal state directly
- Assert on implementation details rather than behavior
- Break on any refactoring even when behavior is preserved

If tests fail after a pure refactoring (no behavior change), consider whether the tests are testing implementation rather than behavior.

### Consistency Check

Look for inconsistent patterns, naming conventions, or structure across the codebase and align them while tests stay green.

---

## Phase: FOREVER

**Apply this section only if PHASE == forever.** If PHASE is anything else, skip this section entirely.

Run autonomously, finding and completing work until interrupted or truly stuck.

### Operating Loop

Execute this cycle continuously:

#### 1. Find Work

Check in order until something is found:

1. **CONTEXT provided** — if the invocation supplied a seed ("focus on X"), start there
2. **Conversation context** — any unfinished discussion
3. **Gaps** — incomplete implementations or missing tests
4. **Git status** — uncommitted changes to address
5. **Task tracker** — `bd ready` for the next issue
6. **Think** — if nothing else, consider: what would improve this codebase?

#### 2. Execute Work

- Make atomic, committable progress.
- Leave a clear trail via commits.
- When writing code, **announce the current sub-phase** (red / green / refactor) before each code action, and apply that Phase section's rules (jump up to the matching section, read it, then apply). Do not skip or interleave phases.

#### 3. Continue or Pivot

After completing a unit of work:

- If more related work exists → continue
- If blocked → note the blocker, find different work
- If genuinely nothing to do → report status and wait

**Do not stop unless:**

- User interrupts (Escape)
- Genuinely no work can be identified
- A decision requires human judgment (ambiguous requirements, architectural choices)

### Anti-Stuck Tactics

| Situation | Action |
|-----------|--------|
| Test failures | Switch to GREEN sub-phase; make the failing tests pass |
| Unclear requirements | Make a reasonable assumption, document it, proceed |
| Build errors | Fix incrementally, commit fixes |
| Context confusion | Re-read recent commits and task tracker to reorient |
| Repeated failures | Try a different approach, or move to a different task |

### Work Discovery Heuristics

When thinking about what to do:

- Tests that could be added (coverage gaps)
- Code that could be simplified
- Documentation that's missing or stale
- TODOs or FIXMEs in code
- Dependencies that could be updated
- Performance improvements
- Refactoring opportunities

### Session Continuity

Every few completed tasks:

- Update the task tracker with progress notes
- Commit work in progress
- Brief self-summary of what's been done

This ensures work survives context limits.

### Communication Style

- Work silently — don't narrate every step
- Report meaningful completions (commits, closed issues)
- Surface decisions that need human input
- Keep responses concise to preserve context