---
name: minify-prompt
description: Optimize token usage in AI agent memory and instruction files (CLAUDE.md, MEMORY.md, SKILL.md, system prompts). Use when the user mentions "minify", "reduce tokens", "optimize prompt", "too long", "compress instructions", "token budget", or wants to shrink agent configuration files. Strips markdown formatting and rewrites content for maximum information density.
---

# Minify Prompt

Core insight: markdown is a visual rendering format. Headings, bold, italic,
code fences, bullets, tables exist to make documents scannable by human eyes.
Agents consume tokens, not pixels. Formatting tokens that do not carry semantic
information are waste.

## Workflow

1. Run `wc -w` on the target file.
2. Read the full file.
3. Apply all techniques from [techniques.md](techniques.md).
4. Rewrite the file as dense plain text.
5. Run `wc -w` again and report the reduction percentage.

## Output Format Rules

The rewritten file must not contain headings, bold or italic markers, code
fences, bullets, numbered lists, table markup, horizontal rules, HTML tags, or
blank lines used only for visual spacing.

Instead use plain sentences, short paragraphs, one blank line max between
topics, parenthetical metadata, comma-separated inline lists, colon-delimited
key-value pairs, and indentation only when it carries real hierarchy.

## Core Principles

Never lose meaning. Every instruction, constraint, and piece of information in
the original must survive. When unsure whether something is low-signal, keep
it.

Factor out repetition. If multiple items share a prefix, parent path, or
structural pattern, state the common element once and make the varying parts
relative to it.

Every token must earn its place. Before writing a token, ask whether it carries
information the agent needs or is just visual chrome.

Show your work. Report before and after word counts and briefly list what was
removed so the user can verify that nothing meaningful was lost.

## Techniques

See [techniques.md](techniques.md) for the full catalog of compression
patterns.
