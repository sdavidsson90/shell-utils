conda() {
  # == Lazy Conda ===============================================================
  # Do not load conda automatically at the start of every session.
  # Instead this command will allow us to spin up conda, when called for.
  # ============================================================================
  "${HOME}/miniconda3/bin/conda" shell.zsh hook >/dev/null 2>&1
  source "${HOME}/miniconda3/etc/profile.d/conda.sh"
  [ $# -gt 0 ] && conda "$@" || true
}

load_toggled_pyenv() {

  # == Load toggled pyenv ======================================================
  # Reads the toml-file produced by `toggle_pyenv` to determine if a toggled
  # environment should be loaded. If the toml-file indicates toggle is switched:
  #   on: we load the environment.
  #   off: we get on with our lives.
  # ============================================================================

  # Path to statefile
  statefile=$HOME/.local/state/toggle_pyenv.toml
  [ ! -f "$statefile" ] && return 0

  # Read in saved values
  read_toml() {
    key=$1
    grep $key $statefile | sed "s/$key=//g"
  }

  env_state=$(read_toml state)
  env_type=$(read_toml type)
  env_target=$(read_toml target)

  # Ensure we stop, if toggle is off
  [[ $env_state == "off" ]] && return 0

  # Ensure we don't have both conda and venv loaded
  while [[ -n $VIRTUAL_ENV ]]; do deactivate 2>/dev/null || break; done
  while [[ -n $CONDA_DEFAULT_ENV ]]; do conda deactivate; done

  if [[ $env_type == "conda" ]]; then
    conda activate $env_target
  elif [[ $env_type == "venv" ]]; then
    eval source "$env_target/bin/activate"
  fi
}

# This function should be sourced at the start of every session.
load_toggled_pyenv

toggle_pyenv() {

  # == Toggle Pyenv ============================================================
  # Build list of items and select one using fzf. The selection is then saved
  # to a toml-file, which allows us to easily bring back the environment that
  # was last in use - either by selecting the "Toggle on/off" option, or by
  # having it reinvoked at the start of the session, with the function `load_toggled_pyenv`.
  #
  # Items can be:
  #   The previously used environment
  #   The .venv in the current Python project
  #   Conda environments
  # ============================================================================

  # We will get better performance out of pointing at this file, rather than
  # having conda print it for us (although that would be more portable).
  conda_environments="$HOME/.conda/environments.txt"

  # We will use a "statefile" to save settings across sessions
  statefile="$HOME/.local/state/toggle_pyenv.toml"
  mkdir -p $(dirname "$statefile")

  if [ ! -f "$statefile" ]; then
    printf '' >"$statefile"
    printf "%s\n" 'state=' >>"$statefile"
    printf "%s\n" 'type=' >>"$statefile"
    printf "%s\n" 'target=' >>"$statefile"
  fi

  # ----------------------------------------------------------------------------

  # Build items array
  items=()

  # --
  # Toggle item: venv

  # Search for .venv
  search_path="$PWD"
  while true; do
    if [[ -f "$search_path/.venv/bin/activate" ]]; then
      venv_name=$(basename "$search_path")
      venv_path="$search_path/.venv"
      [[ "$venv_path" == "$VIRTUAL_ENV" ]] && break
      items+=("Toggle on: $venv_name (venv found in current project)") && break
    fi
    [[ $(realpath "$search_path") == "/" ]] && break
    search_path="$(realpath "$search_path/..")"
  done



  # --
  # Toggle item: last used
  read_toml() {
    key=$1
    grep $key "$statefile" | sed "s/$key=//g"
  }

  env_state=$(read_toml state)
  env_type=$(read_toml type)
  env_target=$(read_toml target)

  # if [[ $env_target != $venv_path ]]; then
  if [[ -n $env_target ]]; then
    toggle_item=("Toggle")
    [[ $env_state == "on" ]] && toggle_item+=("off:") || toggle_item+=("on:")
    toggle_item+=("$env_target ($env_type)")
    items+="${toggle_item[*]}"
  fi
  # fi

  # Add to items: conda environments
  if [[ -f "$conda_environments" ]]; then
    for i in $(tail -n +2 "$conda_environments" | sed 's/.*\///'); do
      items+=("conda: $i")
    done
  fi

  # --
  picker_height=$((${#items[@]} + 2))
  chosen_item=$(printf "%s\n" "${items[@]}" | fzf -i --no-multi --cycle --height=$picker_height)

  # --
  if [[ -z $chosen_item ]]; then
    echo "None chosen..."
    return 130 # (terminated by user)
  fi

  case $chosen_item in
  "Toggle off"*)
    env_state=off
    env_type="$env_type"
    env_target="$env_target"
    cmd=true
    ;;
  "Toggle on"*"venv"*)
    env_state=on
    env_type=venv
    [[ -n $venv_path ]] && env_target=$venv_path
    cmd="source $env_target/bin/activate"
    ;;
  "Toggle on"*"conda"*)
    env_state=on
    env_type=conda
    env_target=$env_target
    cmd="conda activate $env_target"
    ;;
  "conda: "*)
    env_state=on
    env_type=conda
    env_target=$(sed "s/conda: //" <<<$chosen_item)
    cmd="conda activate $env_target"
    ;;
  esac

  # --
  # Activate chosen environment
  while [[ -n $VIRTUAL_ENV ]]; do deactivate; done
  while [[ -n $CONDA_DEFAULT_ENV ]]; do conda deactivate; done

  eval $cmd && {
    printf '' >"$statefile"
    printf "%s\n" "state=$env_state" >>"$statefile"
    printf "%s\n" "type=$env_type" >>"$statefile"
    printf "%s\n" "target=$env_target" >>"$statefile"
  }

  # zle reset-prompt

}

# zle -N toggle_pyenv 
# command -v zmodload >/dev/null && bindkey '^O' toggle_pyenv
command -v zmodload >/dev/null && bindkey -s '^O' toggle_pyenv^M
command -v shopt >/dev/null && bind '"^E":"toggle_pyenv^M"'

# --
open_python_console() {
  ipython 2>/dev/null || python3
}

command -v zmodload >/dev/null && bindkey -s '^P' open_python_console^M
command -v shopt >/dev/null && bind '"^P":"open_python_console^M"'
