---
name: jira-tool
description: Use when user provides Jira issue URLs or mentions Jira tickets - fetches issue details and comments from Jira Cloud using local jira tool, outputs AI-optimized markdown for context gathering
---

# Using the Jira Tool

## Overview

**Core principle:** When users mention Jira issues or provide Jira URLs, immediately run `jira <url-or-key>`. Don't explore code, don't explain internals, just use the tool.

The jira tool is a Python CLI that fetches Jira Cloud issues (description, comments, metadata) and outputs AI-optimized markdown to stdout.

**IMMEDIATE ACTION REQUIRED:**

1. Run tool: `jira "<url or key>"`
2. Display output

That's it. No analysis, no explanation, no code reading.
If jira tool doesn't exists, just tell the user to install it and make use it's in the PATH.

## When to Use

**Use jira tool when:**

- User provides Jira URL: `https://*.atlassian.net/browse/KEY-123`
- User mentions issue key: "check PLATFORM-5678"
- User asks for issue context: "what does SP-1234 say?"
- User asks to implement from a Jira ticket

**Don't use when:**

- Jira URLs are just reference links (not requesting data)
- User wants to CREATE Jira issues (tool is read-only)

## Quick Reference

| Task | Command |
|------|---------|
| Fetch by issue key | `jira PROJ-123` |
| Fetch by URL | `jira "https://company.atlassian.net/browse/PROJ-123"` |
| Save to file | `jira PROJ-123 > context.md` |

## Prerequisites Check

Before using the tool, verify:

```bash
# 1. Configuration exists
ls .env
```

**If missing:**

- `.env` not found → Tell user to create it with `ATLASSIAN_EMAIL`, `ATLASSIAN_TOKEN`, `ATLASSIAN_DOMAIN`
- Tool not found → Not a jira-enabled repository

## Usage Pattern

### Basic Flow

```bash
# Direct issue key
jira SP-1234

# Full URL (with or without query params)
jira "https://company.atlassian.net/browse/TICKET-123"
jira "https://company.atlassian.net/browse/TICKET-123?filter=all"
```

### Integration Workflows

**Gather context before implementation:**

```bash
# Fetch requirements
jira "https://company.atlassian.net/browse/FEATURE-456" > requirements.md

# Read and implement
cat requirements.md
# [implement based on requirements]
```

**Read issue during debugging:**

```bash
# Fetch bug report
jira BUG-789

# Use output to understand the issue
# [debug based on description and comments]
```

## Output Format

The tool outputs markdown with:

- **Metadata:** Issue key, status, priority, assignee, reporter, labels, timestamps
- **Description:** Original issue description (Jira markup → Markdown)
- **Comments:** All comments with author and timestamp

**Structure:**

```markdown
# [KEY-123] Issue Title

**Issue Key:** KEY-123
**Status:** In Progress
**Priority:** High
...

---

## Original Description

[Description content in markdown]

---

## Comments (N total)

### Comment by Author on YYYY-MM-DD HH:MM UTC
[Comment content]
```

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `ATLASSIAN_EMAIL not found` | Missing .env | Create .env with required vars |
| `Invalid credentials` | Wrong API token | Check ATLASSIAN_TOKEN in .env |
| `Issue KEY-123 not found` | No access or doesn't exist | Verify key and permissions |
| `Failed to connect to Jira` | Network or domain issue | Check ATLASSIAN_DOMAIN in .env |
| `Invalid issue key` | Wrong format | Use format: `PROJ-123` |

**All errors go to stderr** - stdout remains clean for piping.

## Common Mistakes

### ❌ Exploring code instead of using tool

```bash
# DON'T: Spend time reading jira.py source
Read jira to understand API calls...

# DO: Just use it
jira PROJ-123
```

### ❌ Using WebFetch for Jira URLs

```bash
# DON'T: Fetch HTML page
WebFetch https://company.atlassian.net/browse/PROJ-123

# DO: Use jira tool for structured data
jira PROJ-123
```

### ❌ Forgetting to quote URLs

```bash
# DON'T: Breaks on query params
jira https://site.atlassian.net/browse/KEY-123?filter=all

# DO: Quote URLs
jira "https://site.atlassian.net/browse/KEY-123?filter=all"
```
