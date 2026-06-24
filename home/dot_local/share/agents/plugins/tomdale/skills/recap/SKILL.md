---
name: recap
description: Summarize prior Codex work for the current directory and its child directories from local Codex session transcripts. Use when the user asks to recap, summarize, reconstruct, review, or understand what work has happened in a repo or directory.
---

# Recap

Use this skill to summarize prior Codex work in the current directory tree.

## Workflow

1. Invoke the bundled script with the shell working directory left at the
   user's current directory:

   ```bash
   /path/to/this/skill/scripts/codex-session-recap --excerpt
   ```

   Resolve the script path relative to this skill directory.

2. Read the returned session paths and compact digests. Each digest extracts
   the user requests, final assistant outcomes, patch-applied files, and shell
   commands from the JSONL transcript.

3. Summarize the nature of the work that happened in the current directory and
   any child directories:
   - Group related sessions by theme or project area.
   - Prefer concrete outcomes, files, commands, and decisions over a chronological transcript dump.
   - Mention uncertainty when the excerpts are insufficient.
   - Include notable session paths only when they help the user follow up.

## Script Behavior

The script scans `${CODEX_HOME:-$HOME/.codex}/sessions` for Codex rollout JSONL
files whose latest recorded cwd is the current directory or a child directory.

By default it prints matching file paths. With `--excerpt`, it also prints a
compact digest for each session. Use `--raw-excerpt` only when the digest is
insufficient and you need to inspect the first 50 and last 50 raw JSONL lines.
