Always include the `tomdale/` prefix when creating git branches.

When writing PR verification steps, do not include local environment workarounds such as `proto run ...`. Report the project-level command that reviewers or CI should use instead.

## Proto-managed Node/pnpm projects

Shell startup puts proto's shims before system tools, so normal project commands
like `node`, `npm`, and `pnpm` should resolve through proto and honor the
nearest project tool configuration. Prefer running the project-level command
directly, for example `pnpm install`, `pnpm test`, `pnpm lint`, or whatever the
repo documents.

When a Node project has `packageManager` set to pnpm or includes
`pnpm-lock.yaml`, use pnpm. Do not switch package managers, regenerate lockfiles
with another tool, or bypass proto by calling Homebrew/system Node or pnpm paths.

If a background shell appears to be using the wrong tool version, diagnose the
environment before changing project files:

```sh
command -v node
node --version
command -v pnpm
pnpm --version
proto diagnose --shell zsh
```

For local troubleshooting only, `proto exec --tools-from-config -- <command>`
can be used to force a command to run with proto's configured tool environment.
Do not put `proto exec`, `proto run`, or other local shell workarounds in PR
verification steps unless the repository itself documents them.
