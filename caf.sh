[[ $(uname) != "Darwin" ]] && return 1

caf() {

  session_name="caffeinate"
  tmux has-session -t "$session_name" 2>/dev/null && {
    echo "A session with this name already exists: $session_name"
    return 1
  }
  tmux new-session -d -s "$session_name" && echo "Launched a Tmux session: $session_name"
  tmux send-keys -t "$session_name" "bash -c \"caffeinate -dimsu -t 18000; tmux kill-session -t $session_name\"" C-m

}
