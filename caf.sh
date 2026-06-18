[[ $(uname) != "Darwin" ]] && return 1

caf() {
  # ---------------------------------------------------------
  # Prevent system from going to sleep
  # ---------------------------------------------------------

  [[ -n "$1" ]] && {
    [[ "$1" =~ ^[0-9]+$ ]] || {
      echo "Argument is not a number"
      return 1
    }

    max_duration=48
    [[ "$1" -lt "$max_duration" ]] || {
      echo "Time duration (argument) must not be larger than ${max_duration} hours"
      return 1
    }

    # Duration in hours
    duration=$(($1 * 3600))
  } || {
    # Default duration 28800 = 8 hours
    duration=28800
  }


  # Don't ask for password after returning from screensaver
  defaults write com.apple.screensaver askForPassword -int 0
  killall SystemUIServer

  # Launch Tmux session
  session_name="caffeinate"
  tmux has-session -t "$session_name" 2>/dev/null && {
    echo "A session with this name already exists: $session_name"
    return 1
  }
  tmux new-session -d -s "$session_name" && echo "Launched a Tmux session: $session_name"
  tmux send-keys -t "$session_name" "bash -c 'caffeinate -dimsu -t $duration; tmux kill-session -t $session_name'" C-m

}

# Ask for password after returning from screensaver
[[ "$(defaults read com.apple.screensaver askForPassword)" == 0 ]] && {
  defaults write com.apple.screensaver askForPassword -int 1
  killall SystemUIServer
}
