stopwatch() {

  trap 'echo -e "\rStopwatch: $(($(date +%s) - $anfang))  " ; return 0' SIGINT

  anfang=$(date +%s)

  if [[ $# -eq 0 ]]; then
    while true; do
      echo -en "\rStopwatch: $(($(date +%s) - $anfang))"
      sleep 1
    done
  fi


}
