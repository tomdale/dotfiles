---
name: proto
description: Use Proto-managed toolchains correctly on this machine. Use when working on a project with Proto configuration, diagnosing Node or pnpm versions, installing dependencies, running project commands, or writing verification instructions.
---

# Proto-managed toolchains

Proto is a toolchain manager that installs, selects, and runs development tools such as Node, npm, pnpm, and Python. A project's Proto configuration declares the versions it expects; Proto's shell shims resolve commands to those versions, allowing project commands to work without hard-coded tool paths.

Proto resolves configuration from the current directory and its ancestors, with user or global defaults as fallbacks. Shell startup places the shims on `PATH`, so commands such as `node` and `pnpm` automatically use the nearest configured versions. Use the project's commands directly rather than invoking version-specific binaries.

For more context:

- [Proto documentation](https://moonrepo.dev/docs/proto)
- [Proto GitHub repository](https://github.com/moonrepo/proto)

Shell startup puts Proto's shims before system tools. Run project commands directly so they resolve through the nearest project tool configuration.

For Node projects, prefer the project's package manager and documented commands:

```sh
pnpm install
pnpm test
pnpm lint
```

When a Node project has `packageManager` set to `pnpm` or includes `pnpm-lock.yaml`, use pnpm. Do not switch package managers, regenerate lockfiles with another tool, or bypass Proto by calling Homebrew or system Node and pnpm paths.

If a background shell appears to use the wrong tool version, diagnose the environment before changing project files:

```sh
command -v node
node --version
command -v pnpm
pnpm --version
proto diagnose --shell zsh
```

For local troubleshooting only, `proto exec --tools-from-config -- <command>` can force a command to run with the project's configured tool environment. Do not include `proto exec`, `proto run`, or other local shell workarounds in PR verification steps unless the repository itself documents them. Report the project-level command that reviewers or CI should use instead.
