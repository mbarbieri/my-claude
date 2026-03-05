# Global Claude instructions

## Brainstorming Sessions

### Stay High-Level Until Implementation

  During brainstorming/design sessions, avoid code-level details (interfaces, method signatures, class structures). Focus on:

- Architecture decisions
- Component responsibilities
- Data flow
- Migration strategy

  Example:

- Good: "Auth client provides circuit breaker, retry, caching"
- Bad: `public interface AuthClient { AuthResult authenticate(HttpHeaders headers); ... }`

  Code details belong in implementation sessions, not design sessions.

### Keep Migration Plans Simple

  Don't over-engineer rollout strategies. If the team has existing mechanisms (like region-based deployment), use those instead of proposing new ones (percentage rollouts, shadow mode, contract tests).

  Example:

- Good: "Deploy to low-risk regions first, then roll out to others"
- Bad: "Phase 3a: Enable for 10% of customers, Phase 3b: Shadow mode comparison..."

### Prefer Complete Decoupling Over Optimization

  When designing service decoupling, prefer including all data in a single source even if some data rarely changes. Complete decoupling is more valuable than minor optimizations.

  Example:

- Good: "Include featureEnabled in bulk dump even though it never changes - one request gets everything"
- Bad: "Keep featureEnabled as a separate call since it can be cached forever"

### Cross-Instance Consistency in Distributed Systems

  When designing caching strategies for services with multiple instances, always consider:

- What happens when one instance has updated data and another doesn't?
- How will this affect user sessions that hit different instances?
- Is there existing infrastructure (Redis pub/sub, etc.) for cache coordination?

## Research Before Design Decisions

### Verify Assumptions About Data Dependencies

  Before deciding to exclude data from a cache or keep it as a live call, research how that data is actually used:

- Is it pass-through only (returned in response but not used for computation)?
- Is it on the hot path (used for every request)?
- Is it security-critical?

  Example:

- Good: "Let me spawn a researcher agent to check if customer settings are used for auth computation"
- Bad: "Customer settings seem like feature flags, let's keep them as live calls"

## Bug Fixing Process

  When fixing bugs, the user expects:

  1. **Write a failing test FIRST** that reproduces the bug
  2. **Only then** implement the fix
  3. Verify the test passes

  Example:

- Good: "Create a test verifying this behaviour and ONLY after fix it"
- Bad: Fix the bug first, then add tests afterward

## API Design Philosophy

### Prefer extending APIs over forcing caller conversions

When an API method requires type A but callers naturally have type B, add an overload accepting type B rather than requiring callers to convert. The API should accommodate its callers, not the reverse.

## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.

## Tracer Bullets

When building features, build a tiny, end-to-end slice of the feature first, seek feedback, then expand out from there.

Tracer bullets comes from the Pragmatic Programmer. When building systems, you want to write code that gets you feedback as quickly as possible. Tracer bullets are small slices of functionality that go through all layers of the system, allowing you to test and validate your approach early. This helps in identifying potential issues and ensures that the overall architecture is sound before investing significant time in development.
