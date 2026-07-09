---
description: Get an independent second opinion on a plan using the plan-reviewer subagent
argument-hint: "[plan-file-or-instructions]"
---
Use the `subagent` tool to run the `plan-reviewer` agent. Ask it to review the current implementation plan for completeness, correctness, risk, and simplicity.

If a plan file or extra instructions were provided, pass them to the subagent:
$ARGUMENTS

Return the plan-reviewer findings and recommend whether to proceed, refine, or ask follow-up questions.
