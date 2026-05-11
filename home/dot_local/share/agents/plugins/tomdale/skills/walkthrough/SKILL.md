---
name: walkthrough
description: Guide a reviewer through someone else's checked-out GitHub PR by explaining the change narrative, grouping the diff into conceptual units, presenting annotated code snippets, pausing for questions after each unit, and ending with whole-PR review questions. Use when the user has a PR branch checked out and asks for a walkthrough, review walkthrough, guided PR review, or help understanding someone else's PR.
---

# Walkthrough

## Overview

Guide the user through a checked-out PR in review order. Build understanding in
small conceptual steps, pause after each step, and help the user form useful
review questions before they judge the PR.

## Preparation

Before presenting the walkthrough:

1. Use the `narrative` skill as the baseline style and process. If needed, read
   `../narrative/SKILL.md`.
2. Identify the PR base, usually the merge base with `origin/main`,
   `origin/master`, or the branch configured for the PR.
3. Read recent commit messages, the full diff from base to `HEAD`, and the
   relevant pre-change implementation using `git show <base>:<path>`.
4. Read enough current implementation to understand how the changed code fits
   into the surrounding system.
5. If base detection is ambiguous, choose the most likely base, state the
   assumption, and continue.

## Opening Overview

Start with a concise narrative overview of the whole PR:

- How the relevant code worked before the PR.
- What changed in the PR.
- Why each major change appears to exist.
- How the changes work together.

Keep this overview explanatory, not evaluative. Save detailed concerns for the
later grouped walkthrough unless there is an immediate blocker in understanding.

## Group The Changes

Break the diff into logical units of conceptual change, not file-based sections.
Multiple groups may include snippets from the same file, and one group may span
many files.

Choose an order that teaches the PR:

- Prefer substantive changes before mechanical or follow-on changes.
- Prefer groups with few dependencies first when that makes later groups easier
  to understand.
- Put foundations before features that rely on them.
- Put API or data-shape changes before call-site changes when readers need that
  context.
- Put tests near the behavior they validate, unless the test strategy itself is
  a distinct conceptual change.

Before presenting the first group, list the planned sequence in one compact
numbered list. Name each group by concept, not by file.

## Present Each Group

For each group:

1. Apply the `narrative` skill again, scoped only to this group.
2. Explain how this part worked before, what changed, and why the change matters
   inside the broader system.
3. Include only the relevant code snippets. Use fenced code blocks with syntax
   highlighting and file references. Annotate outside the snippet unless an
   inline comment is necessary to explain the code.
4. Connect the group to prior groups when useful. Avoid previewing later groups
   in a way that answers the user's likely questions before they reach them.
5. End with a pause and do not continue until the user asks to continue, move
   on, skip, or finish.

Use this handoff format:

```markdown
Before we move on, useful questions to ask about this group:

1. ...
2. ...
3. ...
```

Suggest 3-4 clarifying questions a diligent reviewer might reasonably ask about
the current group. Do not suggest questions that will be answered by later
groups.

## Handle Questions

When the user asks a clarifying question:

- Answer from the code and diff, with snippets if they help.
- Keep the answer scoped to the current group unless broader context is needed.
- If the answer depends on a later group, say so briefly and offer either to
  answer now or cover it when that group arrives.
- After answering, ask whether to continue with the next group.

## Finish

After all groups are covered and the user has no more follow-up questions,
provide:

- A short recap of the sequence of conceptual changes reviewed.
- Five key whole-PR review questions a diligent reviewer should ask.

Keep the closing recap brief. The walkthrough's value comes from the grouped
explanations, not a second full summary.
