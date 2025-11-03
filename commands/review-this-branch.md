## Step 1: Get the full diff
Retrieve all code changes from main to the current branch:

```bash
# Get the full diff from main
git diff main...HEAD
```

## Step 2: Invoke the java-reviewer agent
Invoke the java-reviewer agent to review all changes on the current branch compared to main.
Use the Task tool with subagent_type=java-reviewer and the following prompt:
"Please review all the changes on the current branch compared to main. Follow your instructions to perform a comprehensive code review."
