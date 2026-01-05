---
description: Evaluate this design and challenge it, see if there are flaws or things that could/should be improved
argument-hint: <path/to/design.md> [additional-files...]
---

# Challenge Design

Critically evaluate design documentation to identify flaws, gaps, and improvements.

## Input

$ARGUMENTS

If no files provided, ask the user for the design document path(s).

## Phase 1: Understand the Design

Read all provided markdown files and extract:

- **Goal**: What is the design trying to achieve?
- **Scope**: What's in scope vs. out of scope?
- **Key decisions**: What architectural/technical choices were made?
- **Assumptions**: What is taken for granted?

Output a brief summary (3-5 sentences) to confirm understanding before proceeding.

## Phase 2: Challenge the Design

Evaluate the design against these dimensions:

### Completeness

- Are there missing components or scenarios?
- What edge cases are not addressed?
- Are error handling and failure modes defined?
- Are rollback/recovery strategies specified?

### Consistency

- Are there contradictions between sections?
- Do component responsibilities overlap or conflict?
- Is terminology used consistently throughout?

### Feasibility

- Are there technical assumptions that may not hold?
- Are there dependencies on external systems that aren't addressed?
- Is the proposed timeline realistic given the scope?
- Are there scaling concerns not addressed?

### Simplicity

- Is the design over-engineered for the problem?
- Are there simpler alternatives that achieve the same goal?
- Can any components be eliminated or combined?

### Risks & Trade-offs

- What are the implicit trade-offs being made?
- What could go wrong during implementation?
- What are the security implications?
- What are the performance implications?

### Missing Perspectives

- How does this affect existing users/systems?
- Are there operational concerns (monitoring, debugging, maintenance)?
- Is backward compatibility addressed?
- Are there migration concerns?

## Phase 3: Interactive Review

**Present issues and questions ONE AT A TIME.** This allows the user to think through each point and respond before moving on.

### Flow

1. Start with a brief summary of strengths (what the design does well)
2. Then present the **most critical concern first**
3. Wait for the user's response
4. Based on their response, either:
   - Move to the next concern, OR
   - Discuss further if they want to explore the point
5. After all concerns are addressed, present clarifying questions one by one
6. End with alternative approaches (if any)

### Format for Each Concern

```
### [critical|important|minor] - Title

**Issue**: What's wrong or missing

**Impact**: Why this matters

**Suggestion**: How to address it (if applicable)

What are your thoughts on this?
```

### Severity Levels

- **critical**: Fundamental flaw that blocks implementation or causes failure
- **important**: Significant gap that should be addressed before implementation
- **minor**: Improvement that would strengthen the design but isn't blocking

### Order of Presentation

1. Critical concerns (in order of impact)
2. Important concerns
3. Minor concerns
4. Clarifying questions
5. Alternative approaches to consider

## Phase 4: Update the Design Document

After all concerns and questions have been discussed, **edit the original design document** to incorporate:

1. **Clarifications**: Add details that were clarified during discussion
2. **Resolved concerns**: Update sections where issues were identified and resolved
3. **New decisions**: Document any new decisions made during the review
4. **Acknowledged trade-offs**: Add explicit notes about trade-offs that were discussed and accepted
5. **Out of scope items**: If concerns were deferred, add them to an "Out of Scope" or "Future Considerations" section

### Update Guidelines

- Preserve the original structure of the document where possible
- Add inline clarifications rather than creating separate sections
- Mark significant additions with context (e.g., "Note: ..." or a dedicated section)
- If the user rejected a suggestion, do not add it - only incorporate agreed changes
- After editing, briefly summarize what was changed

## Guidelines

- Be constructively critical - the goal is to improve the design, not tear it down
- Prioritize concerns by impact
- Provide specific suggestions, not vague criticism
- Ask clarifying questions when something is ambiguous
- If the design is solid, say so - don't manufacture issues
- **Do not dump all issues at once** - give the user time to process each point
- If there are no concerns at a severity level, skip it and move to the next
- **Track discussion outcomes** to update the document accurately at the end
