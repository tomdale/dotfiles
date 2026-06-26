# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](https://iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# If using with "light" variant of the Solarized color schema, set
# SOLARIZED_THEME variable to "light". If you don't specify, we'll assume
# you're using the "dark" variant.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light)
      CURRENT_FG=${CURRENT_FG:-'white'}
      CURRENT_DEFAULT_FG=${CURRENT_DEFAULT_FG:-'white'}
      ;;
    *)
      CURRENT_FG=${CURRENT_FG:-'black'}
      CURRENT_DEFAULT_FG=${CURRENT_DEFAULT_FG:-'default'}
      ;;
esac

### Theme Configuration Initialization
#
# Override these settings in your ~/.zshrc

# Current working directory
: ${AGNOSTER_DIR_FG:=${CURRENT_FG}}
: ${AGNOSTER_DIR_BG:=blue}

# user@host
: ${AGNOSTER_CONTEXT_FG:=${CURRENT_DEFAULT_FG}}
: ${AGNOSTER_CONTEXT_BG:=black}

# Git related
: ${AGNOSTER_GIT_CLEAN_FG:=${CURRENT_FG}}
: ${AGNOSTER_GIT_CLEAN_BG:=green}
: ${AGNOSTER_GIT_DIRTY_FG:=black}
: ${AGNOSTER_GIT_DIRTY_BG:=yellow}

# Bazaar related
: ${AGNOSTER_BZR_CLEAN_FG:=${CURRENT_FG}}
: ${AGNOSTER_BZR_CLEAN_BG:=green}
: ${AGNOSTER_BZR_DIRTY_FG:=black}
: ${AGNOSTER_BZR_DIRTY_BG:=yellow}

# Mercurial related
: ${AGNOSTER_HG_NEWFILE_FG:=white}
: ${AGNOSTER_HG_NEWFILE_BG:=red}
: ${AGNOSTER_HG_CHANGED_FG:=black}
: ${AGNOSTER_HG_CHANGED_BG:=yellow}
: ${AGNOSTER_HG_CLEAN_FG:=${CURRENT_FG}}
: ${AGNOSTER_HG_CLEAN_BG:=green}

# VirtualEnv colors
: ${AGNOSTER_VENV_FG:=black}
: ${AGNOSTER_VENV_BG:=blue}

# AWS Profile colors
: ${AGNOSTER_AWS_PROD_FG:=yellow}
: ${AGNOSTER_AWS_PROD_BG:=red}
: ${AGNOSTER_AWS_FG:=black}
: ${AGNOSTER_AWS_BG:=green}

# Status symbols
: ${AGNOSTER_STATUS_RETVAL_FG:=red}
: ${AGNOSTER_STATUS_ROOT_FG:=yellow}
: ${AGNOSTER_STATUS_JOB_FG:=cyan}
: ${AGNOSTER_STATUS_FG:=${CURRENT_DEFAULT_FG}}
: ${AGNOSTER_STATUS_BG:=black}

## Non-Color settings - set to 'true' to enable
# Show the actual numeric return value rather than a cross symbol.
: ${AGNOSTER_STATUS_RETVAL_NUMERIC:=false}
# Show git working dir in the style "/git/root   master  relative/dir" instead of "/git/root/relative/dir   master"
: ${AGNOSTER_GIT_INLINE:=false}
# Show the git branch status in the prompt rather than the generic branch symbol
: ${AGNOSTER_GIT_BRANCH_STATUS:=true}

## Symbol Configuration
# Override these in your ~/.zshrc to customize symbols

# Git symbols
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  : ${AGNOSTER_GIT_BRANCH_SYMBOL:=$'\ue0a0'}      # Default branch symbol: 
  : ${AGNOSTER_GIT_AHEAD_SYMBOL:=$'\u21b1'}       # Ahead of remote: ↱
  : ${AGNOSTER_GIT_BEHIND_SYMBOL:=$'\u21b0'}      # Behind remote: ↰
  : ${AGNOSTER_GIT_DIVERGED_SYMBOL:=$'\u21c5'}    # Diverged from remote: ⇅
  : ${AGNOSTER_GIT_TAG_SYMBOL:='◈'}               # Detached at tag
  : ${AGNOSTER_GIT_COMMIT_SYMBOL:='➦'}            # Detached at commit
  : ${AGNOSTER_GIT_STAGED_SYMBOL:='✚'}            # Staged changes
  : ${AGNOSTER_GIT_UNSTAGED_SYMBOL:='±'}          # Unstaged changes
  : ${AGNOSTER_GIT_BISECT_SYMBOL:='<B>'}          # Bisecting
  : ${AGNOSTER_GIT_MERGE_SYMBOL:='>M<'}           # Merging
  : ${AGNOSTER_GIT_REBASE_SYMBOL:='>R>'}          # Rebasing
}

# Status symbols
: ${AGNOSTER_STATUS_ERROR_SYMBOL:='✘'}            # Non-zero exit code
: ${AGNOSTER_STATUS_ROOT_SYMBOL:='⚡'}            # Running as root
: ${AGNOSTER_STATUS_JOB_SYMBOL:='⚙'}             # Background jobs

# Other VCS symbols
: ${AGNOSTER_BZR_MODIFIED_SYMBOL:='✚'}           # Bazaar modified
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  : ${AGNOSTER_HG_SYMBOL:='☿'}                     # Mercurial symbol
  : ${AGNOSTER_HG_MODIFIED_SYMBOL:='±'}           # Mercurial modified
}

# Virtualenv symbols
: ${AGNOSTER_CONDA_SYMBOL:='🐍'}                  # Conda environment


# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
  SEGMENT_SEPARATOR=$'\ue0b0'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

git_toplevel() {
	local repo_root=$(git rev-parse --show-toplevel)
	if [[ $repo_root = '' ]]; then
		# We are in a bare repo. Use git dir as root
		repo_root=$(git rev-parse --git-dir)
		if [[ $repo_root = '.' ]]; then
			repo_root=$PWD
		fi
	fi
	echo -n $repo_root
}

typeset -g __TOMDALE_GIT_PROMPT_VALID=0
typeset -g __TOMDALE_GIT_PROMPT_OK=1
typeset -g __TOMDALE_GIT_PROMPT_PWD=''
typeset -g __TOMDALE_GIT_PROMPT_ROOT=''
typeset -g __TOMDALE_GIT_PROMPT_GIT_DIR=''
typeset -g __TOMDALE_GIT_PROMPT_BRANCH=''
typeset -g __TOMDALE_GIT_PROMPT_COMMIT=''
typeset -g __TOMDALE_GIT_PROMPT_AHEAD=0
typeset -g __TOMDALE_GIT_PROMPT_BEHIND=0
typeset -g __TOMDALE_GIT_PROMPT_STAGED=0
typeset -g __TOMDALE_GIT_PROMPT_UNSTAGED=0
typeset -g __TOMDALE_GIT_PROMPT_DIRTY=0
typeset -g __TOMDALE_GIT_PROMPT_MODE=''

__tomdale_git_prompt_reset() {
  __TOMDALE_GIT_PROMPT_VALID=0
}

__tomdale_git_prompt_info() {
  (( $+commands[git] )) || return 1
  if (( __TOMDALE_GIT_PROMPT_VALID )) && [[ $__TOMDALE_GIT_PROMPT_PWD == "$PWD" ]]; then
    return $__TOMDALE_GIT_PROMPT_OK
  fi

  __TOMDALE_GIT_PROMPT_VALID=1
  __TOMDALE_GIT_PROMPT_OK=1
  __TOMDALE_GIT_PROMPT_PWD="$PWD"
  __TOMDALE_GIT_PROMPT_ROOT=''
  __TOMDALE_GIT_PROMPT_GIT_DIR=''
  __TOMDALE_GIT_PROMPT_BRANCH=''
  __TOMDALE_GIT_PROMPT_COMMIT=''
  __TOMDALE_GIT_PROMPT_AHEAD=0
  __TOMDALE_GIT_PROMPT_BEHIND=0
  __TOMDALE_GIT_PROMPT_STAGED=0
  __TOMDALE_GIT_PROMPT_UNSTAGED=0
  __TOMDALE_GIT_PROMPT_DIRTY=0
  __TOMDALE_GIT_PROMPT_MODE=''

  local rev_parse git_status line xy git_dir
  rev_parse=$(GIT_OPTIONAL_LOCKS=0 command git rev-parse --is-inside-work-tree --show-toplevel --git-dir 2>/dev/null) || return 1
  local -a rev_parse_lines
  rev_parse_lines=("${(@f)rev_parse}")
  [[ ${rev_parse_lines[1]} == true ]] || return 1

  git_status=$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v2 --branch --ignore-submodules=dirty 2>/dev/null) || return 1

  __TOMDALE_GIT_PROMPT_ROOT="${rev_parse_lines[2]}"
  git_dir="${rev_parse_lines[3]}"
  [[ $git_dir != /* ]] && git_dir="$PWD/$git_dir"
  __TOMDALE_GIT_PROMPT_GIT_DIR="$git_dir"

  for line in "${(@f)git_status}"; do
    case "$line" in
      '# branch.head '*)
        __TOMDALE_GIT_PROMPT_BRANCH="${line#\# branch.head }"
        ;;
      '# branch.oid '*)
        __TOMDALE_GIT_PROMPT_COMMIT="${line#\# branch.oid }"
        ;;
      '# branch.ab '*)
        local ab="${line#\# branch.ab }"
        local ahead_part="${ab%% *}"
        local behind_part="${ab##* }"
        __TOMDALE_GIT_PROMPT_AHEAD="${ahead_part#+}"
        __TOMDALE_GIT_PROMPT_BEHIND="${behind_part#-}"
        ;;
      [12u]' '*)
        xy="${line[3,4]}"
        [[ ${xy[1]} != "." ]] && __TOMDALE_GIT_PROMPT_STAGED=1
        [[ ${xy[2]} != "." ]] && __TOMDALE_GIT_PROMPT_UNSTAGED=1
        ;;
      '?'*)
        __TOMDALE_GIT_PROMPT_UNSTAGED=1
        ;;
    esac
  done

  (( __TOMDALE_GIT_PROMPT_STAGED || __TOMDALE_GIT_PROMPT_UNSTAGED )) && __TOMDALE_GIT_PROMPT_DIRTY=1

  if [[ -e "${git_dir}/BISECT_LOG" ]]; then
    __TOMDALE_GIT_PROMPT_MODE=" $AGNOSTER_GIT_BISECT_SYMBOL"
  elif [[ -e "${git_dir}/MERGE_HEAD" ]]; then
    __TOMDALE_GIT_PROMPT_MODE=" $AGNOSTER_GIT_MERGE_SYMBOL"
  elif [[ -e "${git_dir}/rebase" || -e "${git_dir}/rebase-apply" || -e "${git_dir}/rebase-merge" || -e "${git_dir}/../.dotest" ]]; then
    __TOMDALE_GIT_PROMPT_MODE=" $AGNOSTER_GIT_REBASE_SYMBOL"
  fi

  __TOMDALE_GIT_PROMPT_OK=0
  return 0
}

autoload -Uz add-zsh-hook
if [[ -z "${precmd_functions[(r)__tomdale_git_prompt_reset]-}" ]]; then
  add-zsh-hook precmd __tomdale_git_prompt_reset
fi

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment "$AGNOSTER_CONTEXT_BG" "$AGNOSTER_CONTEXT_FG" "%(!.%{%F{$AGNOSTER_STATUS_ROOT_FG}%}.)%n"
  fi
}

prompt_git_relative() {
  __tomdale_git_prompt_info || return
  local path_in_repo="${PWD#$__TOMDALE_GIT_PROMPT_ROOT}"
  path_in_repo="${path_in_repo#/}"
  if [[ $path_in_repo != '' ]]; then
    prompt_segment "$AGNOSTER_DIR_BG" "$AGNOSTER_DIR_FG" "${path_in_repo:gs/%/%%}"
  fi;
}

# Git: branch/detached head, dirty status
prompt_git() {
  __tomdale_git_prompt_info || return
  local PL_BRANCH_CHAR=$AGNOSTER_GIT_BRANCH_SYMBOL
  local ref changes=''

  if (( __TOMDALE_GIT_PROMPT_DIRTY )); then
    prompt_segment "$AGNOSTER_GIT_DIRTY_BG" "$AGNOSTER_GIT_DIRTY_FG"
  else
    prompt_segment "$AGNOSTER_GIT_CLEAN_BG" "$AGNOSTER_GIT_CLEAN_FG"
  fi

  if [[ $AGNOSTER_GIT_BRANCH_STATUS == 'true' ]]; then
    if (( __TOMDALE_GIT_PROMPT_AHEAD > 0 && __TOMDALE_GIT_PROMPT_BEHIND > 0 )); then
      PL_BRANCH_CHAR=$AGNOSTER_GIT_DIVERGED_SYMBOL
    elif (( __TOMDALE_GIT_PROMPT_AHEAD > 0 )); then
      PL_BRANCH_CHAR=$AGNOSTER_GIT_AHEAD_SYMBOL
    elif (( __TOMDALE_GIT_PROMPT_BEHIND > 0 )); then
      PL_BRANCH_CHAR=$AGNOSTER_GIT_BEHIND_SYMBOL
    fi
  fi

  if [[ $__TOMDALE_GIT_PROMPT_BRANCH == "(detached)" || -z $__TOMDALE_GIT_PROMPT_BRANCH ]]; then
    ref="$AGNOSTER_GIT_COMMIT_SYMBOL ${__TOMDALE_GIT_PROMPT_COMMIT[1,7]}"
  else
    ref="$PL_BRANCH_CHAR ${__TOMDALE_GIT_PROMPT_BRANCH:gs/%/%%}"
  fi

  if (( __TOMDALE_GIT_PROMPT_UNSTAGED || __TOMDALE_GIT_PROMPT_STAGED )); then
    changes=' '
    (( __TOMDALE_GIT_PROMPT_UNSTAGED )) && changes+="$AGNOSTER_GIT_UNSTAGED_SYMBOL"
    (( __TOMDALE_GIT_PROMPT_STAGED )) && changes+="$AGNOSTER_GIT_STAGED_SYMBOL"
  fi

  echo -n "${ref}${changes}${__TOMDALE_GIT_PROMPT_MODE}"
  [[ $AGNOSTER_GIT_INLINE == 'true' ]] && prompt_git_relative
}

prompt_bzr() {
  (( $+commands[bzr] )) || return

  # Test if bzr repository in directory hierarchy
  local dir="$PWD"
  while [[ ! -d "$dir/.bzr" ]]; do
    [[ "$dir" = "/" ]] && return
    dir="${dir:h}"
  done

  local bzr_status status_mod status_all revision
  if bzr_status=$(command bzr status 2>&1); then
    status_mod=$(echo -n "$bzr_status" | head -n1 | grep "modified" | wc -m)
    status_all=$(echo -n "$bzr_status" | head -n1 | wc -m)
    revision=${$(command bzr log -r-1 --log-format line | cut -d: -f1):gs/%/%%}
    if [[ $status_mod -gt 0 ]] ; then
      prompt_segment "$AGNOSTER_BZR_DIRTY_BG" "$AGNOSTER_BZR_DIRTY_FG" "bzr@$revision $AGNOSTER_BZR_MODIFIED_SYMBOL"
    else
      if [[ $status_all -gt 0 ]] ; then
        prompt_segment "$AGNOSTER_BZR_DIRTY_BG" "$AGNOSTER_BZR_DIRTY_FG" "bzr@$revision"
      else
        prompt_segment "$AGNOSTER_BZR_CLEAN_BG" "$AGNOSTER_BZR_CLEAN_FG" "bzr@$revision"
      fi
    fi
  fi
}

prompt_hg() {
  (( $+commands[hg] )) || return
  local rev st branch
  if $(command hg id >/dev/null 2>&1); then
    if $(command hg prompt >/dev/null 2>&1); then
      if [[ $(command hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment "$AGNOSTER_HG_NEWFILE_BG" "$AGNOSTER_HG_NEWFILE_FG"
        st=$AGNOSTER_HG_MODIFIED_SYMBOL
      elif [[ -n $(command hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment "$AGNOSTER_HG_CHANGED_BG" "$AGNOSTER_HG_CHANGED_FG"
        st=$AGNOSTER_HG_MODIFIED_SYMBOL
      else
        # if working copy is clean
        prompt_segment "$AGNOSTER_HG_CLEAN_BG" "$AGNOSTER_HG_CLEAN_FG"
      fi
      echo -n ${$(command hg prompt "$AGNOSTER_HG_SYMBOL {rev}@{branch}"):gs/%/%%} $st
    else
      st=""
      rev=$(command hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(command hg id -b 2>/dev/null)
      if command hg st | command grep -q "^\?"; then
        prompt_segment "$AGNOSTER_HG_NEWFILE_BG" "$AGNOSTER_HG_NEWFILE_FG"
        st=$AGNOSTER_HG_MODIFIED_SYMBOL
      elif command hg st | command grep -q "^[MA]"; then
        prompt_segment "$AGNOSTER_HG_CHANGED_BG" "$AGNOSTER_HG_CHANGED_FG"
        st=$AGNOSTER_HG_MODIFIED_SYMBOL
      else
        prompt_segment "$AGNOSTER_HG_CLEAN_BG" "$AGNOSTER_HG_CLEAN_FG"
      fi
      echo -n "$AGNOSTER_HG_SYMBOL ${rev:gs/%/%%}@${branch:gs/%/%%}" $st
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
  if [[ $AGNOSTER_GIT_INLINE == 'true' ]] && __tomdale_git_prompt_info; then
    # Git repo and inline path enabled, hence only show the git root
    local repo_root="$__TOMDALE_GIT_PROMPT_ROOT"
    [[ $repo_root == $HOME(|/*) ]] && repo_root="~${repo_root#$HOME}"
    prompt_segment "$AGNOSTER_DIR_BG" "$AGNOSTER_DIR_FG" "${repo_root:gs/%/%%}"
  else
    prompt_segment "$AGNOSTER_DIR_BG" "$AGNOSTER_DIR_FG" '%~'
  fi
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  if [ -n "$CONDA_DEFAULT_ENV" ]; then
    prompt_segment magenta $CURRENT_FG "$AGNOSTER_CONDA_SYMBOL $CONDA_DEFAULT_ENV"
  fi
  if [[ -n "$VIRTUAL_ENV" && -n "$VIRTUAL_ENV_DISABLE_PROMPT" ]]; then
    prompt_segment "$AGNOSTER_VENV_BG" "$AGNOSTER_VENV_FG" "(${VIRTUAL_ENV:t:gs/%/%%})"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local -a symbols

  if [[ $AGNOSTER_STATUS_RETVAL_NUMERIC == 'true' ]]; then
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{$AGNOSTER_STATUS_RETVAL_FG}%}$RETVAL"
  else
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{$AGNOSTER_STATUS_RETVAL_FG}%}$AGNOSTER_STATUS_ERROR_SYMBOL"
  fi
  [[ $UID -eq 0 ]] && symbols+="%{%F{$AGNOSTER_STATUS_ROOT_FG}%}$AGNOSTER_STATUS_ROOT_SYMBOL"
  [[ -n "$(jobs -l)" ]] && symbols+="%{%F{$AGNOSTER_STATUS_JOB_FG}%}$AGNOSTER_STATUS_JOB_SYMBOL"

  [[ -n "$symbols" ]] && prompt_segment "$AGNOSTER_STATUS_BG" "$AGNOSTER_STATUS_FG" "$symbols"
}

#AWS Profile:
# - display current AWS_PROFILE name
# - displays yellow on red if profile name contains 'production' or
#   ends in '-prod'
# - displays black on green otherwise
prompt_aws() {
  [[ -z "$AWS_PROFILE" || "$SHOW_AWS_PROMPT" = false ]] && return
  case "$AWS_PROFILE" in
    *-prod|*production*) prompt_segment "$AGNOSTER_AWS_PROD_BG" "$AGNOSTER_AWS_PROD_FG"  "AWS: ${AWS_PROFILE:gs/%/%%}" ;;
    *) prompt_segment "$AGNOSTER_AWS_BG" "$AGNOSTER_AWS_FG" "AWS: ${AWS_PROFILE:gs/%/%%}" ;;
  esac
}

prompt_terraform() {
  local terraform_info=$(tf_prompt_info)
  [[ -z "$terraform_info" ]] && return
  prompt_segment magenta yellow "TF: $terraform_info"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_aws
  prompt_terraform
  prompt_context
  prompt_dir
  prompt_git
  prompt_bzr
  prompt_hg
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
