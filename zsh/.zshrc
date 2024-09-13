#  __________________________________________________
# ⎧ OH-MY-ZSH                                           ⎫
# ====================================================
#   ├ oh-my-zsh dir
export ZSH="$ZDOTDIR/ohmyzsh"
#   ├ completion cache dir
export ZSH_COMPDUMP="$ZDOTDIR/cache/.zcompdump-$HOST"
#   ├ custom dir
ZSH_CUSTOM="$ZDOTDIR/ohmyzsh-custom"
#   ├ automatic updates
zstyle ':omz:update' mode disabled  # disable automatic updates
#   ├ theme
ZSH_THEME="agnoster"
#   ├ settings
COMPLETION_WAITING_DOTS="true"
#   ├ plugins
plugins=(git ssh volta)

source $ZSH/oh-my-zsh.sh

#  __________________________________________________
# ⎧ PYTHON                                           ⎫
# ====================================================
#   ├ pyenv (shell hooks)
eval "$(pyenv init -)"

#  __________________________________________________
# ⎧ ENV                                              ⎫
# ====================================================
#   ├ direnv
eval "$(direnv hook zsh)"

#  __________________________________________________
# ⎧ TOOLS                                            ⎫
# ====================================================
#   ├ homebrew
export HOMEBREW_NO_ENV_HINTS=1
#   ├ zsh
autoload -Uz compinit && compinit
