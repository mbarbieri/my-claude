## Commits and PRs

- Omit attribution/co-author lines in commits and PRs.
- After implementing a fix: run tests, commit, push, open the PR, then assess and respond to Copilot review comments.

## Brainstorming / Design Sessions

**Stay high-level.** Focus on architecture decisions, component responsibilities, data flow, migration strategy. No code-level details (interfaces, signatures, class structures) — those belong in implementation sessions.

- Good: "Auth client provides circuit breaker, retry, caching"
- Bad: `public interface AuthClient { AuthResult authenticate(HttpHeaders headers); ... }`

**Keep migration plans simple.** Reuse existing mechanisms (e.g. region-based deployment) rather than inventing new rollout strategies (percentage rollouts, shadow mode, contract tests).

**Prefer complete decoupling over optimization.** Include all data in a single source even if some rarely changes — one request gets everything. Don't keep rarely-changing data as a separate live call just because it's cacheable.

**Consider cross-instance consistency** when caching in multi-instance services: what if one instance has stale data? How does it affect sessions hitting different instances? Is there existing infra (Redis pub/sub) for cache coordination?

## Research Before Design Decisions

Before excluding data from a cache or keeping it as a live call, research how it's actually used: pass-through only, on the hot path, or security-critical? Spawn a researcher agent to verify rather than assuming.

- State assumptions explicitly and ask the user to confirm premises before building findings on them.

## Bug Fixing Process

- Use TDD (write failing tests first) for bug fixes and new features; simplify/parameterize tests (e.g., Spock parameterization) before committing
- Run the tests and report the exact exit code. If they can't run locally (e.g. Docker TestMain), say so explicitly and validate with go vet + LSP instead.

## API Design Philosophy

**Extend APIs rather than force caller conversions.** If a method needs type A but callers have type B, add a type-B overload. The API accommodates callers, not the reverse.

**No boolean flag parameters on public methods** — intent is invisible at the call site. Use explicitly-named methods (`saveAndIssueActivationToken(user)`, not `save(user, true)`). A boolean on a private helper is fine. Splitting variants often lets the shared method get purer.

## Code Comments

Don't restate what the code does — make it self-explanatory (good names, small methods). Comment only for a non-obvious *why*, contract, or cross-component coupling. Public-interface javadoc is fine for a non-obvious contract, trimmed to just that.

## Plan Mode

- Make plans extremely concise. Sacrifice grammar for concision.
- End each plan with a list of unresolved questions, if any.

## Tracer Bullets

Build a tiny, end-to-end slice through all layers first, seek feedback, then expand. Gets you validation of the architecture early, before investing significant time. (From *The Pragmatic Programmer*.)

## Writing Style

- Never use em-dashes (— or --). Use a comma, colon, parentheses, or restructure the sentence instead.

## Pure Computation vs Side Effects

Separate pure computation from side effects:

- Pure methods take inputs, return outputs, touch nothing external → easy to test.
- Orchestrator methods call services, call pure methods, persist results → tested with mocks.
- If a method both computes AND saves, split it.

Example: instead of `processOrder(orderId)` that calculates discount, applies tax, AND saves — use `calculateTotal(items, discount, taxRate)` (pure) and let the caller persist.
