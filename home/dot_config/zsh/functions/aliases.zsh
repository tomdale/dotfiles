# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ aliases.zsh - Shell Aliases                                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# Tool Shortcuts
# ───────────────────────────────────────────────────────────────────────────────
alias tt=termtint              # Terminal color scheme switcher
alias cat=bat                  # Syntax-highlighted cat replacement

# ───────────────────────────────────────────────────────────────────────────────
# Shell Management
# ───────────────────────────────────────────────────────────────────────────────
alias reload='source $ZDOTDIR/.zshrc'  # Reload shell config without restarting

# ───────────────────────────────────────────────────────────────────────────────
# Claude Code
# ───────────────────────────────────────────────────────────────────────────────
alias sonnet='claude --model sonnet'   # Quick access to Sonnet model
alias opus='claude --model opus'       # Quick access to Opus model
