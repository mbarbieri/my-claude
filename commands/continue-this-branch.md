You are helping the user continue working on the current branch. Your goal is to understand what changes have been made so far and provide context for further development.

## Step 1: Read the changes.md file

First, try to read the `changes.md` file in the project root directory to understand the documented changes:

```bash
cat changes.md
```

If the file doesn't exist, ask the user:
- "I couldn't find a changes.md file. Where can I find a description of the changes made on this branch?"
- Wait for the user to provide a file path or description before proceeding

## Step 2: Get git context

Check the current branch and get the diff from main:

```bash
# Check current branch
git branch --show-current

# Get commit history from main
git log main..HEAD --oneline

# Get statistics of changes
git diff main...HEAD --stat
```

## Step 3: Decide on code review depth

Before reading all the code changes, ask the user:

"I can see there are [X] commits with changes to [Y] files. Would you like me to:
1. Review all code changes in detail (may use significant context)
2. Just use the changes.md summary without reading the actual code
3. Review only specific files or areas"

Based on their choice:

- **Option 1 (Full review)**: Get the full diff
  ```bash
  git diff main...HEAD
  ```

- **Option 2 (Summary only)**: Skip reading code and rely only on changes.md and commit messages

- **Option 3 (Selective review)**: Ask which files/areas to focus on and read only those

## Step 4: Provide summary

After gathering context, provide a concise summary:
- Key changes made so far
- Current state of the work
- Potential next steps or areas to focus on

## Important Notes

- Always check if changes.md exists before proceeding
- Be mindful of context limits when there are many commits
- Default to asking the user's preference when changes are extensive
- Focus on understanding the intent and progress, not just listing files changed
