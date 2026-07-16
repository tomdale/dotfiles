# Zsh configuration

Environment setup belongs in `.zshenv` or the sourced `env.zsh`; interactive
aliases, functions, prompt, completions, plugins, and hooks belong in `.zshrc`.
`.zprofile` is reserved for login-only setup. Do not rely on `.zprofile` for
environments that start non-login interactive shells.

The deployed shell layout is:

- `~/.zshenv` — sets `ZDOTDIR` and sources environment configuration.
- `~/.config/zsh/env.zsh` — environment variables and `PATH`.
- `~/.config/zsh/.zprofile` — minimal login-only setup.
- `~/.config/zsh/.zshrc` — interactive configuration.
- `~/.config/zsh/functions/` — aliases and shell functions.
- `~/.config/zsh/custom/themes/` — Oh My Zsh themes.

Zsh startup order is `.zshenv` for every shell, `.zprofile` for login shells,
`.zshrc` for interactive shells, and `.zlogin` for login shells after `.zshrc`.
