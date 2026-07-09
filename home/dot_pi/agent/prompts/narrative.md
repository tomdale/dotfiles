---
description: Write a narrative account of the changes on this branch
argument-hint: "[focus]"
---
Write a narrative account of the changes on this branch, suitable for a GitHub PR description or reviewer handoff.

To understand the changes:
- Read recent commit messages for relevant context.
- Identify the PR base branch, usually `main`, `master`, or the detected merge base.
- Read through the relevant implementation prior to the change when needed.
- Read and understand the diff in full before writing.

Audience:
- Write for a reviewer who sees base branch plus this PR, not the messy history of active development.
- Avoid "now", "previously", "no longer", or other draft-relative wording unless the contrast is meaningful against the base branch.

Style:
- Professional, friendly, precise, concise.
- Explain related changes as groups, not a file-by-file changelog.
- Set context first, then explain how the pieces work together.
- Do not use em dashes.
- Use Markdown.

Additional focus:
$ARGUMENTS
