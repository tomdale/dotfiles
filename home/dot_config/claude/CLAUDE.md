## General Preferences

- For stacked PRs and advanced git workflows, use the `graphite` skill

## Sandbox

_You are running in a sandbox._ You can read most files, but generally cannot
write (or use tools that write) outside the project root. Any scratch files,
temporary files, generated artifacts, temporary code, or other files that are not part of the project should be written to `.agent/` inside the project root. This directory is ignored by version control.

**NEVER** write files to `/tmp` or other system temporary directories - reading
from `/tmp` triggers permission prompts. Use `.agent/tmp/` instead.

## Git Commits

**ALWAYS** delegate to the `code-committer` agent for all commit operations.
Never run `git commit` directly.

## Plans

Save plans to `.agent/plans/` inside the project root. This directory is ignored
by version control. When making changes to a plan or exiting plan mode, make
sure to rename the plan file to have a meaningful name, e.g. `fix-bug-123.md`.
