---
name: notion
description: Use the Notion CLI to search, inspect, create, and update Notion pages and databases safely. Read this before any Notion interaction.
---

# Notion CLI

Use the installed `notion` CLI for Notion work. Do not edit Notion through the web UI or call the Notion API directly unless the user explicitly asks for that. The CLI is the source of truth for authentication, output formats, and supported operations.

## Before the first command

Check that the CLI is available and inspect its current interface:

```bash
command -v notion
notion --help
notion <subcommand> --help
```

If it is not installed or authenticated, stop and report that clearly rather than substituting an unrelated tool or guessing credentials. Never print, commit, or paste an API token or other credential.

## General workflow

1. **Discover** the relevant page or database with search. Search by distinctive title terms and confirm the result rather than relying on a guessed ID or URL.
2. **Inspect** the complete page or database before changing it. Record the page ID, title, parent, and relevant properties/content.
3. **Plan** the smallest change that satisfies the request. Preserve existing content and properties unless the user asks for replacement.
4. **Write** only after the target and intended mutation are unambiguous. Prefer the CLI's structured/JSON output for automation and capture the command result.
5. **Verify** by fetching the changed object again and checking the title, properties, parent, and content—not merely that the command exited successfully.

Example command shape (confirm exact subcommands and flags with `notion --help` first):

```bash
notion search "distinctive terms"
notion get <page-id>
notion create ...
notion update <page-id> ...
```

## Safety rules

- Treat page IDs, database IDs, and URLs as data; copy them from search/fetch results.
- Search before create to avoid duplicate pages. Fetch before update to avoid overwriting unrelated content.
- Do not delete, archive, move, rename, or rewrite a page/database without explicit user approval for that specific operation.
- For destructive or broad changes, show the proposed scope and ask for confirmation before executing.
- Use a dry-run or confirmation flag when the CLI provides one.
- Quote titles, text, IDs, and URLs so shell metacharacters cannot alter a command.
- Preserve rich text, block structure, property types, and existing formatting. Do not flatten a page to plain text unless requested.
- Avoid bulk mutations in a loop until one representative operation has been inspected and verified.
- Use `--help` to resolve version-specific flags; do not infer flags from another Notion client.

## Output and scripting

Prefer structured output when supported (usually `--json`) and pipe it through a JSON tool only after confirming the schema. Keep reads separate from writes so a failed or partial command cannot be mistaken for a successful mutation. Save IDs from command output, not from display titles. Redact credentials and sensitive page content from logs and summaries.

When reporting work, include the page/database title, the operation performed, and the verification result. If the CLI's command names differ from the examples above, follow its help output and update this skill only when the local CLI's interface is intentionally standardized.
