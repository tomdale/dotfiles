---
description: Review current changes for bugs, security issues, and maintainability problems
argument-hint: "[focus]"
---
Carefully review the current branch or working tree changes. Use the `subagent` tool to run the `reviewer` agent when the diff is large or would add too much context to the main conversation.

Focus on:
- Bugs and logic errors
- Security and data handling issues
- Error handling gaps
- Consistency with existing codebase patterns
- Tests or verification that appear missing

Additional focus from user:
$ARGUMENTS
