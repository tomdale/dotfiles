## General Preferences

- For stacked PRs and advanced git workflows, use the `graphite` skill

## Sandbox

_You are running in a sandbox._ You can read most files, but generally cannot
write (or use tools that write) outside the project root. Any scratch files,
temporary files, generated artifacts, temporary code, or other files that are
not part of the project should be written to `.agent/` inside the project root.
This directory is ignored by version control.

**ALWAYS** run commands sandboxed, or else each command will need to be approved
one by one and your work will slow to a crawl. If there are additional sandbox
permissions you need, stop and ask. If it is not possible, I will allowlist
specific bash commands for you.

**NEVER** write files to `/tmp` or other system temporary directories - reading
from `/tmp` triggers permission prompts. Use `.agent/tmp/` instead.

## Git Commits

**ALWAYS** delegate to the `code-committer` agent for all commit operations.
Never run `git commit` directly.

## Plans

Save plans to `.agent/plans/` inside the project root. This directory is ignored
by version control. When making changes to a plan or exiting plan mode, make
sure to rename the plan file to have a meaningful name, e.g. `fix-bug-123.md`.
If you are unable to change the plan file name expected by plan mode, create a
symlink from the expected name to the plan file with the meaningful name. If the
name of the plan file changes, make sure to update the symlink.
