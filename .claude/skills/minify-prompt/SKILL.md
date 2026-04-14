---
name: minify-prompt
description: >-
  Optimize token usage in AI agent memory and instruction files (CLAUDE.md,
  MEMORY.md, SKILL.md, system prompts). Use when the user mentions "minify",
  "reduce tokens", "optimize prompt", "too long", "compress instructions",
  "token budget", or wants to shrink agent configuration files. Strips all
  markdown formatting and rewrites content for maximum information density.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - Bash(wc:*)
---

# Minify Prompt

Core insight: markdown is a visual rendering format. Headings, bold, italic,
code fences, bullets, tables — these exist to make documents scannable by human
eyes. Agents consume tokens, not pixels. Every formatting token that doesn't
carry semantic information is waste.

## Workflow

1. Run `wc -w` on the target file
2. Read the full file
3. Apply all techniques from [techniques.md](techniques.md)
4. Rewrite the file as dense plain text
5. Run `wc -w` again and report the reduction percentage

## Output Format Rules (mandatory)

The rewritten file MUST NOT contain any of the following:
- Headings (no # at any level)
- Bold or italic markers (no ** or _ or *)
- Code fences (no ``` or indented code blocks)
- Bullet points or numbered lists (no - or * or 1.)
- Table markup (no | pipes or alignment dashes)
- Horizontal rules (no --- or ***)
- HTML tags
- Blank lines used purely for visual spacing

INSTEAD use:
- Plain sentences and short paragraphs
- Newlines to separate distinct topics (one blank line max)
- Parenthetical annotations for metadata: path/to/file (template, macOS-only)
- Comma-separated inline lists instead of bullet lists
- Colon-delimited key-value pairs: concept: explanation
- Indentation only where it encodes hierarchy (e.g. nested paths)

## Core Principles

Never lose meaning. Every instruction, constraint, and piece of information in
the original must survive. When uncertain whether something is low-signal, keep
it.

Factor out repetition. If N items share a common prefix, parent path, or
structural pattern, state the common element once and make the varying parts
clearly relative to it.

Every token must earn its place. Before writing a token, ask: does this carry
information the agent needs, or is it visual/structural chrome?

Show your work. Report before/after word counts and briefly list what was
removed so the user can verify nothing meaningful was lost.

## Techniques

See [techniques.md](techniques.md) for the full catalog of compression
patterns.
