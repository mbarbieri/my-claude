---
name: using-jira-tool
description: Use when user provides Jira issue URLs or mentions Jira tickets - fetches issue details and comments from Jira Cloud using local jira tool, outputs AI-optimized markdown for context gathering
---

# Using the Jira Tool

## Overview

**Core principle:** When users mention Jira issues or provide Jira URLs, immediately run `jira <url-or-key>`. Don't explore code, don't explain internals, just use the tool.

The jira tool is a Python CLI that fetches Jira Cloud issues (description, comments, metadata) and outputs AI-optimized markdown to stdout.

**IMMEDIATE ACTION REQUIRED:**
1. Check tool exists: `which jira`
2. Run tool: `jira "<url or key>"`
3. Display output

That's it. No analysis, no explanation, no code reading.

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
# 1. Tool exists
which jira

# 2. Dependencies installed
python -m pip list | grep -E "requests|python-dotenv"

# 3. Configuration exists
ls .env
```

**If missing:**
- `.env` not found → Tell user to create it with `ATLASSIAN_EMAIL`, `ATLASSIAN_TOKEN`, `ATLASSIAN_DOMAIN`
- Dependencies missing → Run `pip install -r requirements.txt`
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

### ❌ Not checking prerequisites
```bash
# DON'T: Run without checking
jira PROJ-123
# FileNotFoundError: .env

# DO: Verify setup first
ls .env && jira PROJ-123
```

### ❌ Using absolute paths
```bash
# DON'T: Use absolute path
/Users/matteo.barbieri/dev/matteo/toolbox/jira_client/jira PROJ-123

# DO: Use python command with relative path
jira PROJ-123
```

## Recognition Workflow

**When user mentions Jira:**
1. Look for `jira` in path: `which jira`
2. If found → Use the tool directly (see Quick Reference table)
3. If not found → Tell user the jira command is not available

## Red Flags - STOP and Use Tool

If you catch yourself doing ANY of these, STOP immediately:
- Reading jira.py source code
- Mentioning function names like `extract_issue_key()` or `format_issue_markdown()`
- Explaining how the tool works internally
- Analyzing the API implementation
- "Let me understand the codebase first"
- "I'll explore how this works"

**All of these mean: Just run `jira <issue>` and move on.**

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Let me explore the codebase first" | Tool is already built. Just use it. |
| "I should understand how it works" | You don't need to. It's a black box tool. |
| "Let me check the implementation" | Wastes time. Run the tool instead. |
| "I'll analyze the API calls" | Tool handles that. Focus on user's request. |
| "Need to verify the code quality" | Not your job here. Use the tool as-is. |

## Real-World Impact

**Without skill:**
- Agents explore jira.py source code (wasting time)
- Use WebFetch to scrape HTML (loses structure)
- Don't discover tool exists

**With skill:**
- Immediate tool discovery: `jira KEY-123`
- Structured markdown output ready for AI consumption
- Clear error messages guide prerequisite setup
