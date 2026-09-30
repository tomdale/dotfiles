Before modifying any agent or harness configuration, read the `agent-config` skill.

Before changing any of Tom's personal repositories (toolbelt, skills, dotfiles, or another github.com/tomdale checkout), read the `personal-repo-lifecycle` skill and follow it, normally through push and cleanup; their canonical checkouts are live, so edits happen only in your own task worktree. Before installing, reloading, or applying anything they deploy, read that skill's deploy step: only canonical checkouts are deployed.

Before creating or changing any agent instruction file (AGENTS.md, CLAUDE.md, SKILL.md, or a prompt template), however small the change, read the shared `write-agents-md` skill and complete its required independent review before finishing.

Write comments, documentation, help text, and tool descriptions for a reader who sees only the current system: describe current behavior and durable intent, and keep change history in commits and PRs. Comments explain non-obvious invariants rather than restating code.

Never run `find` or other recursive/whole-tree commands against the user's home directory (`~`). Home holds vast, noisy trees (caches, node_modules, dotfiles, private data); recursive searches there are slow and can surface or read material not meant to be scanned. Target specific subdirectories or projects instead.

When asked to interact with or use Notion, use the Notion MCP tools directly. Do not use a Notion CLI or a local Notion skill.

When access to GitHub is needed, use the `gh` CLI.

When creating a branch without a repository-specific naming convention, use
the `tomdale/` prefix.

### Creating public artifact URLs

If your task needs a publicly resolvable URL for an artifact—for example, to
embed a screenshot in a GitHub PR description—use `agent-upload FILE`. This is
semi-private storage: screenshots of proprietary software are acceptable, but
inspect the artifact first and do not upload secrets, credentials, tokens,
private keys, session material, or highly sensitive information.

The upload command accepts an optional friendly slug and stores the artifact
under a generated `artifacts/<token>-<basename>` path. Inspect the artifact
before uploading; the returned URL is public. For example:

```sh
url=$(agent-upload --slug pr-123-after screenshot.png)
printf '[Screenshot](%s)\n' "$url"
```

`agent-upload` detects the MIME type with the local `file` utility. If detection
is missing or wrong, override it with `--content-type MIME_TYPE`, such as
`agent-upload --content-type image/svg+xml diagram.svg`.

This machine uses Proto, a toolchain manager that selects versions of tools such as Node, pnpm, npm, and Python through shell shims; read the shared `proto` skill when working on projects that use those tools, or when a command has a missing or unexpected tool version, PATH, package-manager, installation, warning, or other toolchain-related problem that may be explained or fixed by Proto.
