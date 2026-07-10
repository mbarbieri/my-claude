---
name: address-pr-comments
description: Read and address review comments on a GitHub pull request. Use when the user asks to address PR comments, handle review feedback, respond to PR reviewers, or mentions "address comments" or "pr comments". Also use when the user has just opened a PR and wants to process incoming review feedback. Works with a PR number/URL argument or auto-detects the PR for the current branch.
---

# Address PR Comments

Read review comments on a PR, evaluate each one, apply the worthwhile fixes, and reply to the rest explaining why they were skipped.

## Resolve the PR

Determine the target PR in this order:

1. If the user provided a PR number or URL as an argument, use that.
2. If a PR was created earlier in this conversation, use that.
3. Otherwise, run `gh pr view --json number,url` to find the PR for the current branch.

If none of these yield a PR, ask the user which PR to address.

## Fetch comments

Fetch all review comments (not top-level PR comments):

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews --jq '.[] | select(.state != "APPROVED" and .state != "DISMISSED")'
gh api repos/{owner}/{repo}/pulls/{number}/comments
```

Also fetch any top-level issue comments that look like review feedback:

```bash
gh pr view {number} --comments --json comments
```

Deduplicate and group comments by reviewer. Ignore bot comments (Copilot, dependabot, codecov, etc.) unless they contain actionable findings, in which case treat them like human comments.

## Evaluate each comment

For each comment, classify it into one of these categories:

### Auto-address (apply without asking)

- **Correctness bugs**: logic errors, null safety, off-by-one, concurrency issues
- **Security issues**: injection, auth bypass, secrets exposure
- **Clear style violations**: naming, formatting, import order that matches project conventions
- **Trivial fixes**: typos, dead code removal, missing imports
- **Test gaps**: missing test coverage for new behavior (add the test)

### Ask the user

- **Design disagreements**: the reviewer suggests a different approach or architecture
- **Preference conflicts**: the comment contradicts the user's known preferences (from CLAUDE.md)
- **Ambiguous scope**: the suggestion is valid but may be out of scope for this PR
- **Trade-off calls**: performance vs readability, DRY vs clarity, etc.

For these, present the comment, your assessment, and ask whether to address it or skip it. Use `AskUserQuestion` to batch up to 4 ambiguous comments at a time.

### Auto-skip (reply without fixing)

- **Already handled**: the code already does what the reviewer suggests, just differently
- **Out of scope**: the suggestion is valid but belongs in a separate PR
- **Disagree on convention**: the reviewer's preference contradicts project CLAUDE.md or established patterns

## Apply fixes

For comments you're addressing:

1. Read the relevant file(s) and understand the surrounding context.
2. Make the fix. Follow the project's conventions (read CLAUDE.md files).
3. Run tests if available to make sure the fix doesn't break anything.
4. Keep track of all files changed.

## Reply to skipped comments

For each comment you're NOT addressing, post a reply explaining why. Keep it respectful and concise. Use `gh api` to reply:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  -f body="<your reply>"
```

Good reply patterns:
- "This is already handled by X (see file:line) which covers this case via Y."
- "Good point, but I think this belongs in a follow-up PR to keep this one focused on Z."
- "The project convention here is X (per CLAUDE.md), so I'll keep it as-is."
- "Intentional: <brief rationale>."

Bad reply patterns:
- "I disagree." (no reasoning)
- Defensive or dismissive tone
- Walls of text

## Resolve comment threads

After addressing or replying to a comment, resolve its review thread so the PR conversation stays clean:

```bash
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "<thread_node_id>"}) {
      thread { isResolved }
    }
  }'
```

Get the thread node ID from the `node_id` field on the review comment (`gh api` returns it as `node_id` in REST or `id` in GraphQL). Resolve threads for both addressed and skipped comments.

## Commit and push

After all fixes are applied:

1. Run tests one final time.
2. Stage only the files you changed.
3. Commit with a message like: `Address PR review comments`
4. Push to the PR branch.

## Report

End with a summary:
- How many comments were addressed (and what changed)
- How many were skipped (and the gist of each reply)
- How many the user decided on (and what they chose)
- Any comments you replied to that the user might want to double-check
