battery() {
  bdir="/sys/class/power_supply/BAT0"

  now=$(<"${bdir}/charge_now")
  full=$(<"${bdir}/charge_full")
  percentage=$(bc <<<"scale=10; ($now / $full) * 100")
  printf "Battery: "
  printf "%.2f %%" "$percentage"
  printf "\n"

  cycles=$(<"${bdir}/cycle_count")
  printf "Battery cycles: $cycles"
  printf "\n"

  temp=$(<"${bdir}/temp")
  printf "Battery temperature: $temp"
  printf "\n"

}

display_toggle() {
  # Purpose: Toggle built-in display on/off. Useful on laptop server installations.

  # Only proceed if this is an SSH session
  [[ "$(uname)" == "Linux" ]] || return 1
  # [[ -z "$SSH_TTY" ]] || return 1

  # -----------------------------------------------------------------------------
  # Check state of display
  display_state_file="/sys/class/backlight/intel_backlight/bl_power"
  value=$(<"$display_state_file")

  if [[ $value == 1 ]]; then
    word="off"
    opposite_word="on"
    opposite_value='0'
  elif [[ $value == 0 ]]; then
    word="on"
    opposite_word="off"
    opposite_value='1'
  fi
  # -----------------------------------------------------------------------------
  # Prompt user
  msg="Display is $word - turn it $opposite_word? [Y/n]: "
  echo -en "$msg"

  # Attempt to get a response that is either: Y, y, N or n.
  # Empty response will be interpreted as: Y.

  response=$(bash -c "read -n 1 response; echo -n \$response")

  if [ -z "$response" ]; then
    response='Y'
    echo -en "\033[1A\033[2K"
    echo -en "\r${msg}${response}"
  fi

  while [[ ! "$response" =~ ^[YyNn]$ ]]; do
    echo -en "\nTry again! [Y/n]: "
    response=$(bash -c "read -n 1 response; echo -n \$response")

    # If input is 'enter' - accept as 'Y':
    if [ -z "$response" ]; then
      response='Y'
      echo -en "\rTry again! [Y/n]: y"
    fi
  done

  echo ""

  # -----------------------------------------------------------
  case "$response" in
  [Yy])
    sudo bash -c "echo $opposite_value > $display_state_file" &&
      echo "It's $opposite_word!" ||
      echo "... whoopsie, couldn't turn the display $opposite_word"
    ;;
  [Nn])
    echo "It stays $word!"
    exit 0
    ;;
  esac
}
