# ---------------
conda_activate() {
  echo "Activate conda environment: "
  j=1
  state_dir="$HOME/.local/state/conda"

  # Toggle item
  toggle_file_status="$state_dir/toggle_status"
  [[ -e $toggle_file_status ]] && toggle_status=$(<$toggle_file_status)

  toggle_file_env="$state_dir/toggle_env"
  [[ -e $toggle_file_env ]] && toggle_env=$(<$toggle_file_env)

  if [[ $toggle_status = "on" ]]; then
    items[$j]="Toggle off"
    ((j++))
  elif [[ $toggle_status = "off" ]]; then
    items[$j]="Toggle on ($toggle_env)"
    ((j++))
  fi

  # Base item
  items[$j]="base"
  ((j++))

  # Other envs
  env_file="$HOME/.conda/environments.txt"
  for i in $(tail -n +2 "$env_file" | sed 's/.*\///'); do
    items[$j]="$i"
    ((j++))
  done

  # -- Select item
  picker_height=$(( $(awk 'END { print NR }' <$env_file) + 3 ))
  chosen_item=$(printf "%s\n" "${items[@]}" | fzf -i --no-multi --cycle --height=$picker_height)

  # --
  if [[ -z $chosen_item ]]; then
    echo "None chosen..."
    return 130

  elif [[ $chosen_item == *"Toggle"* ]]; then

    if [[ $toggle_status == "off" ]]; then
      printf "on" >$toggle_file_status
      echo $toggle_env
      conda activate $toggle_env

    elif [[ $toggle_status == "on" ]]; then
      printf "off" >$toggle_file_status
      echo "\033[1AToggled off conda!          "
      conda deactivate
    fi

  else
    # -- Log chosen env before proceeding
    mkdir -p $state_dir
    printf $chosen_item >$toggle_file_env
    printf 'on' >$toggle_file_status
    echo $chosen_item
    conda activate "$chosen_item"
  fi

}

# Keybind
# ctrl + w : select conda environment to activate
bindkey -s '' conda_activate

# ---------------
conda_list() {
  conda list | tail -n +4 | sed '$d' | cut -d ' ' -f1 | fzf
}
