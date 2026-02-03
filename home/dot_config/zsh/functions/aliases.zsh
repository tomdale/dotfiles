# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ aliases.zsh - Shell Aliases                                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# Tool Shortcuts
# ───────────────────────────────────────────────────────────────────────────────
alias tt=termtint              # Terminal color scheme switcher
alias cat=bat                  # Syntax-highlighted cat replacement
alias gnpm=/opt/homebrew/bin/npm  # Homebrew npm

# ───────────────────────────────────────────────────────────────────────────────
# Shell Management
# ───────────────────────────────────────────────────────────────────────────────
alias reload='source $ZDOTDIR/.zshrc && echo "Zsh configuration reloaded"'  # Reload shell config without restarting

# ───────────────────────────────────────────────────────────────────────────────
# Claude Code
# ───────────────────────────────────────────────────────────────────────────────
alias sonnet='claude --model sonnet'   # Quick access to Sonnet model
alias opus='claude --model opus'       # Quick access to Opus model
alias haiku='claude --model haiku'
alias agent='agentstate'          # Agent state viewer
alias a='agentstate'              # Short alias for agentstate
