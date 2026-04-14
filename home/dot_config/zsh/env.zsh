# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ env.zsh - Environment Variables & PATH                                    ║
# ╠═══════════════════════════════════════════════════════════════════════════╣
# ║ Defines environment variables, tool directories, and PATH configuration.  ║
# ║ Sourced from .zshenv so these are available to all programs and scripts,  ║
# ║ not just interactive shells.                                              ║
# ║                                                                           ║
# ║ This is the right place for:                                              ║
# ║   - XDG base directories (where apps store data/config/cache)             ║
# ║   - Tool home directories (CARGO_HOME, PNPM_HOME, etc.)                   ║
# ║   - PATH modifications (order matters - earlier entries take precedence)  ║
# ║   - EDITOR, LANG, and other environment variables                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ Startup Architecture                                                    │
# ├─────────────────────────────────────────────────────────────────────────┤
# │                                                                         │
# │ Two .zshenv files exist because zsh picks which one to source based on  │
# │ whether ZDOTDIR is set:                                                 │
# │                                                                         │
# │   ~/.zshenv           — First shell in session (ZDOTDIR unset).         │
# │                         Sets ZDOTDIR, then sources this file.           │
# │   $ZDOTDIR/.zshenv    — Subshells (ZDOTDIR inherited from parent).     │
# │                         Sources this file directly.                     │
# │                                                                         │
# │ Both entry points converge here. What happens next depends on shell     │
# │ type:                                                                   │
# │                                                                         │
# │ NON-INTERACTIVE (zsh -c, Claude Code, scripts, cron):                   │
# │   .zshenv → env.zsh                                                    │
# │     1. Set env vars (XDG, LANG, EDITOR, tool homes)                    │
# │     2. Build PATH (homebrew, cargo, ~/.local/bin)                      │
# │     3. Strip inherited proto sentinels from parent's PATH              │
# │     4. proto activate --export: resolve tools for cwd, set PATH        │
# │     5. Done. (.zshrc never runs)                                       │
# │                                                                         │
# │ INTERACTIVE (new terminal tab, nested `zsh`):                           │
# │   .zshenv → env.zsh                                                    │
# │     1-3. Same as above                                                 │
# │     4. Proto activation SKIPPED (interactive guard)                    │
# │   .zshrc                                                               │
# │     5. proto activate: resolve tools for cwd + register chpwd hook     │
# │     6. oh-my-zsh, direnv, termtint, termtitle, functions, iTerm2      │
# │                                                                         │
# │ Why skip proto in env.zsh for interactive shells?                       │
# │   - .zshrc runs proto activate anyway (needed for the chpwd hook)      │
# │   - On login shells, macOS /etc/zprofile runs path_helper between      │
# │     .zshenv and .zshrc, which reorders PATH — so .zshenv activation   │
# │     would get clobbered and redone in .zshrc anyway.                   │
# │   - Skipping avoids ~50ms of wasted work.                              │
# │                                                                         │
# │ Proto activation details:                                               │
# │   - --config-mode all: includes global ~/.proto/.prototools so that    │
# │     globally pinned tools (node, pnpm, python) are always activated.   │
# │   - --export: outputs PATH/env exports without registering a chpwd     │
# │     hook (appropriate for non-interactive shells that don't cd).       │
# │   - Sentinel stripping: proto wraps its PATH entries between           │
# │     activate-start and activate-stop directories. Subshells inherit    │
# │     these from the parent but need to re-resolve for their own cwd.   │
# │     We strip the sentinel region before re-activating.                 │
# │                                                                         │
# └─────────────────────────────────────────────────────────────────────────┘

# ───────────────────────────────────────────────────────────────────────────────
# Portable Environment Variables
# Shared with chezmoi scripts - see env.sh for definitions
# ───────────────────────────────────────────────────────────────────────────────
source "${ZDOTDIR:-$HOME/.config/zsh}/env.sh"

# ───────────────────────────────────────────────────────────────────────────────
# Locale & Editor
# ───────────────────────────────────────────────────────────────────────────────
export LANG="en_US.UTF-8"
export EDITOR="nvim"

# ───────────────────────────────────────────────────────────────────────────────
# Resource Limits
# ───────────────────────────────────────────────────────────────────────────────
# Raise open file descriptor limit (default 256 is often too low for dev servers,
# Node.js, etc.). Caps at system hard limit if 65536 isn't allowed.
ulimit -n 65536 2>/dev/null || true

# ───────────────────────────────────────────────────────────────────────────────
# PATH Configuration
# Order matters: earlier entries take precedence
# ───────────────────────────────────────────────────────────────────────────────
# Prevent duplicate PATH entries. typeset -U is a zsh array attribute and is
# not inherited by child shells, so it must be set in every shell's env setup.
typeset -U path

# Homebrew (macOS only — sets HOMEBREW_PREFIX, MANPATH, etc.)
if [[ -d /opt/homebrew/bin ]]; then
    export HOMEBREW_NO_ENV_HINTS=1
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="$(brew --prefix rustup)/bin:$PATH"
fi

# Local user scripts (~/.local/bin)
export PATH="$HOME/.local/bin:$PATH"

# Cargo-installed binaries (termtint, termtitle, etc.)
export PATH="$CARGO_HOME/bin:$PATH"

# Proto toolchain manager
# proto activate --export resolves pinned tool versions for the current
# directory and prepends their real binary dirs + global package dirs to PATH
# (e.g. node/24.0.0/bin, node/globals/bin, pnpm global bin dir). This runs
# for ALL shells so non-interactive contexts (Claude Code, scripts, cron) get
# the same environment as interactive terminals.
# The chpwd hook in .zshrc re-runs activation on directory changes.
#
# --config-mode all includes the global ~/.proto/.prototools so that globally
# pinned tools (node, pnpm, python) are always activated — even when the cwd
# has no local .prototools. Without this, pnpm globals and cargo bins would
# only appear on PATH in directories with their own .prototools.
#
# Subshells inherit the parent's PATH, which may contain activation state from
# a different directory (sentinel dirs activate-start/activate-stop and
# tool-specific paths). Strip these so proto re-activates for *this* shell's cwd.
if [[ "$PATH" == *"$PROTO_HOME/activate-start"* ]]; then
    # Remove everything between activate-start and activate-stop sentinels,
    # plus the sentinels themselves, then remove the stale activation tracking var.
    PATH="${PATH%%$PROTO_HOME/activate-start:*}${PATH#*$PROTO_HOME/activate-stop:}"
    unset _PROTO_ACTIVATED_PATH
fi
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"
if [[ ! -o interactive ]] && command -v proto &>/dev/null; then
    eval "$(proto activate zsh --export --config-mode all)"
    typeset -U path
fi
