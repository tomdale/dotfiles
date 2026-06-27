# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ aliases.zsh - Shell Aliases                                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# Tool Shortcuts
# ───────────────────────────────────────────────────────────────────────────────
alias tt=termtint              # Terminal color scheme switcher
alias cat=bat                  # Syntax-highlighted cat replacement
alias gnpm=/opt/homebrew/bin/npm  # Homebrew npm
alias glow='glow --pager'      # Always paginate glow output

# Frequently used shortcuts retained from Oh My Zsh.
case $OSTYPE in
  (darwin*|freebsd*) alias ls='ls -G' ;;
  (linux*) alias ls='ls --color=tty' ;;
esac
alias l='ls -lah'
alias la='ls -lAh'
alias g='git'
alias ga='git add'
alias gc='git commit --verbose'
alias gco='git checkout'
alias gp='git push'
alias gr='git remote'
alias -g ...='../..'
alias -g ....='../../..'

d() {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d

mdcopy() {
  prettier --prose-wrap never "$@" | pbcopy
}

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
