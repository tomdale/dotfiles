Always include the `tomdale/` prefix when creating git branches.

When writing PR verification steps, do not include local environment workarounds such as `proto run ...`. Report the project-level command that reviewers or CI should use instead.

## Proto-managed Node/pnpm projects

Shell startup puts proto's shims before system tools, so normal project commands like `node`, `npm`, and `pnpm` should resolve through proto and honor the nearest project tool configuration. Prefer running the project-level command directly, for example `pnpm install`, `pnpm test`, `pnpm lint`, or whatever the repo documents.

When a Node project has `packageManager` set to pnpm or includes `pnpm-lock.yaml`, use pnpm. Do not switch package managers, regenerate lockfiles with another tool, or bypass proto by calling Homebrew/system Node or pnpm paths.

If a background shell appears to be using the wrong tool version, diagnose the environment before changing project files:

```sh
command -v node
node --version
command -v pnpm
pnpm --version
proto diagnose --shell zsh
```

For local troubleshooting only, `proto exec --tools-from-config -- <command>` can be used to force a command to run with proto's configured tool environment. Do not put `proto exec`, `proto run`, or other local shell workarounds in PR verification steps unless the repository itself documents them.

## Pi workflow rules

Comments should explain why, not what. Never reference how code changed from a previous version. Ask: "will this make sense in a year to someone who never saw the old code?" If not, put it in a commit message or PR description, not code.

Use scratch/temp files in `./.agent/` when the repo provides it or in the OS temp directory when the artifact does not belong in the repo. Do not leave accidental generated files in the workspace.

Git commits: prefer the `/commit` prompt or the `code-committer` subagent. Never run `git commit` directly unless local workspace rules define their own commit workflow. Stage only files that belong to the current task.

The bash tool runs non-interactive. REPLs, pagers, editors, CLI prompts, progress bars, and color output may behave differently or fail without a tty. For REPLs, interactive prompts, TUIs, or progress-displaying programs, use tmux patterns from the `interactive-shell` skill when available.

For substantial changes, use `/plan` first. Before executing risky or broad plans, use `/plan-review` or a reviewer subagent for a second opinion.

For large searches or context-heavy investigations, delegate to the `scout`, `github-researcher`, or other focused subagents through the `subagent` tool to keep the main conversation compact.
