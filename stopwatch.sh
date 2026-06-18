stopwatch() {

  # Hide cursor
  tput civis

  # Hide control characters (^C)
  stty -echoctl

  trap 'echo -e "\rStopwatch ran for $sec"; tput cnorm; return 0' SIGINT

  anfang=$(date +%s)

  if [[ $# -eq 0 ]]; then
    while true; do
      sec=$(($(date +%s) - $anfang))
      echo -en "\rStopwatch: $sec"
      sleep 1
    done
  fi

}
