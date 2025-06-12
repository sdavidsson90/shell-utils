# Lazy load conda - speeds up loading of zsh
# Requires the following variables:
#   conda config --set auto_activate_base false
#   conda config --set changeps1 False
#   conda config --set quiet true

# if ! command -v conda; then
  # return 1
# fi

# Replace the chucnk, that conda inserts in to your .zshrc with:
conda() {
  $HOME/miniconda3/bin/conda shell.zsh hook >/dev/null 2>&1
  source $HOME/miniconda3/etc/profile.d/conda.sh
  [ $# -gt 0 ] && conda "$@" || true
}

# Activate conda if toggled
toggle_file_env="$HOME/.local/state/conda/toggle_env"
[[ -e $toggle_file_env ]] && toggle_env=$(<$toggle_file_env)

toggle_file_status="$HOME/.local/state/conda/toggle_status"
[[ -e $toggle_file_status ]] && toggle_status=$(<$toggle_file_status)
[[ $toggle_status == "on" ]] && conda activate $toggle_env
