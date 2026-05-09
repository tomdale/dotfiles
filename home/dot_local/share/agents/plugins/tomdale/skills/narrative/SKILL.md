---
name: narrative
description: Generate a narrative account of the changes on the current branch, written as prose suitable for a GitHub PR description or comment. Use when the user asks to describe, summarize, or narrate branch changes, write a PR description, or explain what changed on a branch.
---

# Narrative

Write a narrative account of the changes on this branch, using prose to walk a
reader with no familiarity with the codebase through the changes, providing
enough additional context to allow them to understand the intent and impact.

## Preparation

Before writing anything:

1. Read the full text of recent git commit messages for additional context.
2. Read through the relevant parts of the implementation *prior* to the change,
   to ensure you have a well-formed and holistic understanding of the existing
   system.
3. Read through the diff and understand the changes in full.

## Audience And Baseline

- Anchor the narrative against the PR base branch, usually `main`, `master`, or
  the detected merge base. Describe the world as the intended reviewer will see
  it: base branch plus this PR.
- Never write a PR description relative to an earlier draft, abandoned approach,
  force-pushed commit, review iteration, or any other ephemeral work unless the
  user explicitly asks for a progress report.
- Do not say that the PR "now" does something, "replaces" a previous iteration,
  "no longer" uses an approach, or "moves from" one temporary design to another
  unless that contrast is meaningful against the base branch.
- Before including any contrast or historical reference, ask: is the thing being
  referred to likely to be relevant to the intended audience reading this, who
  was not following every twist and turn of active development? If not, omit it
  or move it to a private note instead of the PR narrative.

## Structure

- Always set context first.
- Begin with a summary:
  - Relevant context prior to the change
  - The goal of the changes
  - Concise, broad overview of the changes
  - Briefly describe how these changes work together to accomplish the goal
- Break changes down into smaller groups of related changes.
  - Explaining groups of changes across many files is usually more effective
    than going file by file.
- Elide small changes that are not meaningful to understanding the essence of
  the change.
- Find the right order for presenting changes so the reader starts with minimal
  context, building on what they just learned with each step.
- Build up to a clear, understandable conclusion that feels inevitable from
  each logical step.

## Style

- Professional but friendly.
- Never condescend to the reader or act all-knowing.
- Be precise and accurate without resorting to jargon.
- Be extremely concise. Avoid fluff.
  - No meta-commentary about the document itself or the argument you will make.
  - No "the key insight" or similar phrases.
  - Stick to the facts.
- Limit value judgments to cases where there are indisputable problems or
  improvements.
- Do not sound pleased with yourself or present ideas with inflated ego.
- Do not use emdashes.
- Use emoji very, very sparingly (only if it is the best option for conveying
  meaning concisely).

## Format

- Use Markdown, appropriate for pasting into a GitHub PR description or comment.
- Include a title.
