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

### Prefer Existing Patterns Over New Designs

  When designing extractions/migrations, default to copying existing API contracts rather than inventing new ones. If the codebase already has `/api/identity/context`, propose using the same endpoint in the new service.

### Keep Migration Plans Simple

  Don't over-engineer rollout strategies. If the team has existing mechanisms (like region-based deployment), use those instead of proposing new ones (percentage rollouts, shadow mode, contract tests).

  Example:

- Good: "Deploy to low-risk regions first, then roll out to others"
- Bad: "Phase 3a: Enable for 10% of customers, Phase 3b: Shadow mode comparison..."

### Prefer Complete Decoupling Over Optimization

  When designing service decoupling, prefer including all data in a single source even if some data rarely changes. Complete decoupling is more valuable than minor optimizations.

  Example:

- Good: "Include apiTokenAuthDisabled in bulk dump even though it never changes - one request gets everything"
- Bad: "Keep apiTokenAuthDisabled as a separate call since it can be cached forever"

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
