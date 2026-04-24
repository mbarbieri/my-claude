---
name: bump-fix
description: Resolve security vulnerability Jira tickets (typically SECCOMP-*) by upgrading the indicated package, runtime, or base image everywhere it appears in the repository, then creating a branch, commit, and pull request. Use this skill whenever the user asks to "bump", "fix a vuln", "address a SECCOMP ticket", "upgrade a base image", or mentions a ticket ID that looks like a security remediation — even if they don't explicitly say "bump-fix". Also use when the user pastes a Jira URL to a vulnerability ticket and asks to fix it.
---

# bump-fix

## Goal

Take a security vulnerability Jira ticket, apply the remediation it describes (upgrade a package, runtime, or base image wherever it appears), and ship it as a PR. The user verifies — you do not run tests.

## Inputs

The user provides a ticket ID (e.g., `SECCOMP-58299`) or a Jira URL. If neither is given, ask for one.

## Workflow

### 1. Read the ticket

```bash
jira <TICKET-ID>
```

The description tells you what to upgrade. Two common shapes:

- **Package / runtime bump** — "update the following non-OS packages: Go runtime 1.25.8 to at least v1.25.9". A specific target version is stated.
- **Base image bump** — "update the sysdig-micro-ubi9:1.0.40 base image to the latest available one" with a link to a GitHub releases page. Target is "latest".

The rendered description often has missing spaces (e.g., `Thetelecaster:0.0.2`) because the source HTML is stripped crudely. Read through it — the information is still there.

Extract:
- **What** to upgrade (e.g., `golang`, `sysdig-micro-ubi9`, `glibc`)
- **Current version** (as mentioned in the ticket, useful as a `rg` target)
- **Target version** (either specific, or "latest" with a GitHub repo link)
- The **CVE(s)** being addressed — useful for the commit/PR body

### 2. Resolve "latest" via `gh`

When the ticket says "latest" and links to a GitHub releases page, use `gh` — it's authenticated and works with private repos.

From the URL, extract `<owner>/<repo>` (e.g., `draios/base-image`). Releases pages are often filtered by a product name (`?q=sysdig-micro-ubi9`); that filter is typically the tag prefix because the repo ships multiple products from one release stream.

```bash
# List recent releases, filter by prefix
gh release list --repo <owner>/<repo> --limit 50 | grep '<prefix>'

# Or use the API for structured output
gh api 'repos/<owner>/<repo>/releases?per_page=100' \
  --jq '.[] | select(.tag_name | startswith("<prefix>")) | .tag_name' \
  | head -10
```

Pick the highest semver-sorted tag that matches the prefix. Confirm it's strictly newer than the current version before proceeding. If the repo's version is already ≥ target, stop and tell the user — the image likely just needs redeployment, not a code change.

### 3. Create the branch from main

Branch name: `<TICKET-ID>-<short-kebab-slug>`. Keep the slug short and descriptive of the action, not the cause.

Examples:
- `SECCOMP-58299-upgrade-go-1.25.9`
- `SECCOMP-55338-upgrade-ubi-image`

```bash
git checkout main && git pull --ff-only
git checkout -b <TICKET-ID>-<slug>
```

### 4. Apply the change everywhere

`rg -l` gives you the exhaustive edit set in two seconds. Run it for **both** the current version string *and* the image/package name — the union is what you edit. Don't go hunting in files it didn't return.

```bash
rg --fixed-strings -l '<current-version>'
rg --fixed-strings -l '<image-or-package-name>'
```

Then `rg -n` on each hit shows the exact line. For a single-line version swap, go straight to `Edit` — don't re-`Read` the file, the `-n` output is already enough context.

**Fallback only** (if `rg` returns nothing and you suspect a pin is hiding): builder stages in multi-stage `Dockerfile`s, `go.mod`/`go.work` (`go` directive + `toolchain`), `.github/workflows/*.yml` (`setup-go`, matrices), `Makefile`, `.tool-versions`, `.goreleaser.yml`, Helm `values.yaml`/`Chart.yaml`, and install scripts under `scripts/`/`ci/`/`hack/`.

Shell note: when batching `Bash` calls in parallel with other tools, don't include a speculative `rg` over a path that may not exist (e.g., `.github/`) — a non-zero exit cancels sibling calls. Run it alone, or append `|| true`.

### 5. Commit

Check conventions once:

```bash
test -f CLAUDE.md && cat CLAUDE.md
git log --oneline --grep=SECCOMP -5   # both repo convention + recent bump style in one shot
```

Most Sysdig repos use Conventional Commits. The scope should be the **subdir/service name** (e.g., `chore(ticketing): ...`), not a generic `deps`. Put the ticket ID in the body; keep the message about what changed and why (the CVE), not the process.

Example:

```
chore(ticketing): bump sysdig-micro-ubi9 to 1.0.45

Addresses glibc CVE-2026-0915 (SECCOMP-55338).
```

### 6. Push and open the PR

Resolve the real default branch from the remote — don't trust the harness's "main branch" hint, it can be stale or scoped to the wrong repo:

```bash
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
git push -u origin HEAD
gh pr create --base "$DEFAULT_BRANCH" --title "<TICKET-ID>: <short summary>" --body "$(cat <<'EOF'
## Summary
- Bump <thing> from <old> to <new>
- Addresses <CVE-IDs>

## Jira
<TICKET-ID>
EOF
)"
```

If the repo has a PR template, use it instead of the body above. Check case-insensitively — the file is often `PULL_REQUEST_TEMPLATE.md`:

```bash
find .github -maxdepth 1 -iname 'pull_request_template.md'
```

Include the ticket ID (full URL `https://<domain>/browse/<TICKET-ID>` if `ATLASSIAN_DOMAIN` is set in `.env`, otherwise the ID alone) and name the CVEs being fixed — reviewers scan for those.

### 7. Report and stop

Print the PR URL. Do not run tests, CI, or linters. Wait for the user to tell you if something failed.

## Edge cases

- **No matches found in the repo.** The package may live in a submodule, be vendored under a different name, or the repo may not be the right one. Don't guess — tell the user and show what you searched for.
- **Ambiguous target.** If the ticket mentions multiple images/packages and it's unclear which applies to this repo, ask. Don't bump everything blindly.
- **Version boundary.** A ticket saying "1.25.8 → at least 1.25.9" authorises a patch bump. Don't jump to 1.26 unless the ticket explicitly says so — major/minor bumps carry different risk.
- **Already on target.** If the repo is already at ≥ target version, the vulnerability report likely reflects a running image that hasn't been redeployed. Tell the user; don't open an empty PR.
- **Private GitHub release repo.** `gh` handles auth; if it fails, have the user run `gh auth status` rather than falling back to an unauthenticated fetch.

## Tools

- `jira` — local Jira CLI (see the `jira-tool` skill if it's missing)
- `gh` — releases + PR creation, authenticated
- `git`, `rg`, standard file editing
