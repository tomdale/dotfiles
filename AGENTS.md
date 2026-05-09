# AGENTS

If Codex needs to clarify ambiguous behavior in how the Codex CLI operates, it may refer to `~/Code/codex` to review the actual Codex CLI source code.

Codex should always run `chezmoi apply` and related `chezmoi apply...` commands unsandboxed.

This is a public repository. Do not commit, stage, or push secrets or anything
potentially compromising. Treat private keys, tokens, credentials, machine IDs,
account IDs, signing keys, personal access tokens, session material, local-only
hostnames, and unexplained high-entropy values as sensitive until proven
otherwise. Before any commit, PR, push, or patch that adds configuration values,
scan the diff for sensitive material. If sensitive or potentially compromising
material appears in tracked source, stop all work immediately and warn the user;
do not continue, stage, commit, or push until the material has been removed from
tracked files or replaced with a documented local-only mechanism.

When modifying any local Codex/agent plugin managed by this repo, update the
plugin source under `home/`, run `chezmoi apply` for the affected plugin path,
and restart Codex so the next session loads the applied plugin. Local plugins
are installed into Codex's cache under
`~/.codex/plugins/cache/<marketplace-name>/<plugin-name>/local/`; do not bump the
plugin manifest version just to refresh a local plugin.

If a local plugin change still is not picked up after applying and restarting
Codex, bust the installed cache for that plugin. For example, after changing the
`tomdale` plugin:

```sh
rm -rf ~/.codex/plugins/cache/tomdale-codex-plugins/tomdale/local
```

Do not edit files directly in `~/.codex/plugins/cache`; treat that directory as
Codex-managed generated state.
