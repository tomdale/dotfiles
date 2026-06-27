# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ python.zsh - Automatic Python Virtual Environment Activation             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

typeset -gaU PYTHON_VENV_NAMES
PYTHON_VENV_NAMES=(.venv venv)

auto_vrun() {
  if (( $+functions[deactivate] )) && [[ $PWD != ${VIRTUAL_ENV:h}* ]]; then
    deactivate >/dev/null 2>&1
  fi

  [[ $PWD == ${VIRTUAL_ENV:h} ]] && return

  local activate
  for activate in "${^PYTHON_VENV_NAMES[@]}"/bin/activate(N.); do
    (( $+functions[deactivate] )) && deactivate >/dev/null 2>&1
    source "$activate" >/dev/null 2>&1
    break
  done
}

add-zsh-hook chpwd auto_vrun
auto_vrun
