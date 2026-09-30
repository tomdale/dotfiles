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
# │ NON-INTERACTIVE (zsh -c, Codex CLI tool calls, scripts, cron):          │
# │   .zshenv → env.zsh                                                    │
# │     1. Set env vars (XDG, LANG, EDITOR, tool homes)                    │
# │     2. Build PATH (homebrew, cargo, ~/.local/bin)                      │
# │     3. Prepend proto shims/bin for runtime version detection           │
# │     4. If login, .zprofile repeats step 3 after macOS path_helper      │
# │     5. Done. (.zshrc never runs)                                       │
# │                                                                         │
# │ INTERACTIVE (new terminal tab, nested `zsh`):                           │
# │   .zshenv → env.zsh                                                    │
# │     1-3. Same as above                                                 │
# │   .zshrc                                                               │
# │     5. register proto chpwd hook (shims already on PATH)               │
# │     6. completion, prompt, direnv, terminal hooks, functions           │
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

# Keychain-backed secrets (no plaintext-at-rest cache). Load the gateway key
# synchronously for every shell, including interactive shells without a usable
# ZLE/TTY. GUI-launched tools and agent shells can start without either, so the
# key cannot depend on the asynchronous .zshrc injection path.
if [[ -z ${AI_GATEWAY_API_KEY-} && -x /usr/bin/security ]]; then
  AI_GATEWAY_API_KEY="$(/usr/bin/security find-generic-password \
    -a vercel-ai-gateway -s 'Vercel AI Gateway' -w 2>/dev/null)"
  [[ -n $AI_GATEWAY_API_KEY ]] && export AI_GATEWAY_API_KEY
fi

# Socket-firewall credentials remain interactive-shell independent, but are
# loaded here only for non-interactive shells because .zshrc owns the TTY path.
if [[ ! -o interactive ]]; then
  if [[ ( -z ${SOCKET_AUTH_B64-} || -z ${SOCKET_PASSWORD_B64-} || -z ${UV_INDEX_SOCKET_FIREWALL_PASSWORD-} ) \
        && -f $HOME/.config/socket-firewall/env.sh ]]; then
    source "$HOME/.config/socket-firewall/env.sh"
  fi
fi

# GPG pinentry needs the active terminal in interactive shells.
if [[ -o interactive && -t 0 ]]; then
    export GPG_TTY="$(tty)"
fi

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

# Homebrew (macOS only)
if [[ -d /opt/homebrew/bin ]]; then
    # `brew shellenv` forks Homebrew and path_helper on every shell startup.
    # The ARM Homebrew prefix is stable, so set its equivalent shell state
    # directly and retain its completion, manpage, and infopage locations.
    export HOMEBREW_NO_ENV_HINTS=1
    export HOMEBREW_PREFIX=/opt/homebrew
    export HOMEBREW_CELLAR=/opt/homebrew/Cellar
    export HOMEBREW_REPOSITORY=/opt/homebrew
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
    typeset -U fpath
    export MANPATH=":${MANPATH:-}"
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
    export PATH="/opt/homebrew/opt/rustup/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

# pnpm global binaries (pnpm 11+ uses $PNPM_HOME/bin, not $PNPM_HOME)
export PATH="$PNPM_HOME/bin:$PATH"

# Local user scripts (~/.local/bin)
export PATH="$HOME/.local/bin:$PATH"

# Cargo-installed binaries (termtint, termtitle, etc.)
export PATH="$CARGO_HOME/bin:$PATH"

# Proto shims perform runtime version detection for every invocation. Full
# shell activation lives in .zshrc, where it can install the interactive chpwd hook.
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"
