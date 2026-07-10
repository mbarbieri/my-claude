---
name: my-review
description: Review a pull request applying the user's Java, Spock, and architecture preferences on top of standard code review. Use when the user asks to review a PR, review code changes, or mentions "my-review". Also use when the user pastes a GitHub PR URL and asks for feedback.
---

# My Review

Review a PR through the lens of my coding preferences — not just general best practices.

## Setup

Before reviewing, load project context:

1. Read `CLAUDE.md` files in the project root and any parent directories
2. Read `CLAUDE.local.md` if it exists in the project root
3. Read `.claude/CLAUDE.md` if it exists
4. Get the diff: `git diff main...HEAD` (or the appropriate base branch)
5. For PR URLs, use `gh pr diff <number>`

## Review process

### 1. Understand the change

Read the full diff. Identify what the PR is trying to accomplish before critiquing.

### 2. Check against my preferences

Flag violations of these — they are the primary value of this review over a generic one.

**Java style:**
- No Javadoc on private methods/constructors (zero tolerance)
- No documenting obvious getters/setters
- Constants extracted only when used in multiple places; single-use values stay inline
- No utility methods that return a constant — use `static final` instead
- Clean overloads for optional params, never force callers to pass `null`
- No premature abstractions — no interfaces/abstract classes without multiple implementations
- Composition over inheritance
- APIs accommodate callers, not the reverse

**Spock tests:**
- 3+ similar tests MUST use `where:` block (iron rule)
- Stubs (`>>`) in `given:`, mock verifications (`*`) in `then:` — never swapped
- Test names are full sentences with `#variable` interpolation for parameterized tests
- No hardcoded timestamps, no magic numbers
- Integration tests: happy path only. Unit tests: edge cases + `where:` blocks

**Architecture:**
- Pure computation separated from side effects — flag any method that both computes AND persists
- No "Peeping Tom" tests (testing private methods or internal state)
- Tests assert behavior, not implementation details
- No hard-coded `sleep()`/timeout values in tests

**Process (flag if violated):**
- No TDD references in code, comments, or PR description
- No `plan.md` files committed
- No anticipatory code (features, error handling, abstractions beyond what tests require)

### 3. Check CLAUDE.md rules

Flag any violations of the project's CLAUDE.md and CLAUDE.local.md conventions discovered in Setup. These are project-specific and vary — read them carefully.

### 4. Standard review

Also check for:
- Correctness bugs (logic errors, off-by-ones, null safety, concurrency)
- Security (injection, auth bypass, secrets in code)
- Missing test coverage for new behavior
- Dead code or unnecessary changes

## Output format

Group findings by severity:

- **Must fix** — correctness bugs, security issues, preference violations marked "zero tolerance" or "iron rule"
- **Should fix** — other preference violations, missing tests, design issues
- **Nit** — style, naming, minor improvements

For each finding: file:line, what's wrong, why (reference the specific preference), and a suggested fix. Keep it terse — one or two sentences per finding.

If the PR looks good, say so briefly. Don't manufacture findings.
