Before modifying any agent or harness configuration, read the `agent-config` skill.

When asked to write, rewrite, improve, or generate an AGENTS.md (or dense project guidance for coding agents), read the shared `write-agents-md` skill first.

Comments should explain durable intent or non-obvious invariants; never narrate implementation details, review history, or facts already clear from names, types, and control flow.

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

The upload is public and always lives below the `USER_PREFIX` directory
(default: `tomdale`). `agent-upload --path PATH FILE` stores the file at
`USER_PREFIX/PATH`; if PATH already starts with the exact `USER_PREFIX/` prefix,
the prefix is not added twice. Do not look for these artifacts at the Blob
store root—include the prefix when referring to or searching for an uploaded
file. For example:

```sh
url=$(agent-upload --path pr-123/after.png screenshot.png)
printf '[Screenshot](%s)\n' "$url"
```

`agent-upload` detects the MIME type with the local `file` utility. If detection
is missing or wrong, override it with `--content-type MIME_TYPE`, such as
`agent-upload --content-type image/svg+xml diagram.svg`.

This machine uses Proto, a toolchain manager that selects versions of tools such as Node, pnpm, npm, and Python through shell shims; read the shared `proto` skill when working on projects that use those tools, or when a command has a missing or unexpected tool version, PATH, package-manager, installation, warning, or other toolchain-related problem that may be explained or fixed by Proto.
