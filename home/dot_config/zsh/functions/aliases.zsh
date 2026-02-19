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
alias tmux='tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf'  # Use XDG-compliant config path

# ───────────────────────────────────────────────────────────────────────────────
# Claude Code
# ───────────────────────────────────────────────────────────────────────────────
alias sonnet='claude --model sonnet'   # Quick access to Sonnet model
alias opus='claude --model opus'       # Quick access to Opus model
alias haiku='claude --model haiku'
alias csettings='nvim "$(chezmoi source-path)/dot_config/claude/settings.json"'  # Edit chezmoi-managed Claude settings