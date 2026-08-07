Before modifying any agent or harness configuration, read the `agent-config` skill.

When asked to interact with or use Notion, use the Notion MCP tools directly. Do not use a Notion CLI or a local Notion skill.

When access to GitHub is needed, use the `gh` CLI.

When creating a branch without a repository-specific naming convention, use
the `tomdale/` prefix.

This machine uses Proto, a toolchain manager that selects versions of tools such as Node, pnpm, npm, and Python through shell shims; read the shared `proto` skill when working on projects that use those tools, or when a command has a missing or unexpected tool version, PATH, package-manager, installation, warning, or other toolchain-related problem that may be explained or fixed by Proto.
