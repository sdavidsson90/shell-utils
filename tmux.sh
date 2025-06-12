# -------------------------------------
# Checks if you have any open Tmux sessions (in case you forget)
if [ -z "$TMUX" ]; then
  tmux ls >/dev/null 2>&1
  if [[ $? == 0 ]]; then
    echo -e "\033[1mOpen Tmux sessions:\033[0m"
    tmux ls
  fi
fi

# -------------------------------------
# List Tmux sessions (if there are any)
tl() {
  tmux ls >/dev/null 2>&1
  if [[ $? == 1 ]]; then
    echo "There are no open Tmux sessions."
    return 1
  fi

  echo -e "\033[1mOpen Tmux sessions:\033[0m"
  tmux ls
}

# ---------------------------------
# New Tmux session (optional: name)
tn() {
  if [ -z $1 ]; then
    tmux new
  else
    tmux new -s "$1"
  fi
}

# -------------------------
# New detached Tmux session
tnd() {
  tmux new-session -d "$@" &&
    echo "New (detached) Tmux session launched!"
}

# -----------------------------------------------------
# Choose which Tmux session to attach to (if there any)
ta() {

  number_of_sessions=$(tmux ls 2>/dev/null | wc -l | tr -d ' ')

  if [[ $number_of_sessions -lt 1 ]]; then
    echo "There are no open Tmux sessions."
    return 1
  elif [[ $number_of_sessions == 1 ]]; then
    tmux attach
  elif [[ $number_of_sessions -gt 1 ]]; then
    session="$(tmux ls | fzf +m | cut -d ':' -f1)"

    tmux attach -t $session >/dev/null 2>&1 || echo "No session chosen!" && return 130
  fi

}

# ------------------------------------------------
# Choose which Tmux session to kill (if there any)
tk() {
  tmux ls >/dev/null 2>&1
  if [[ $? == 1 ]]; then
    echo "There are no open Tmux sessions!"
    return 1
  fi

  for i in $(tmux ls | fzf | cut -d ':' -f1); do
    tmux kill-session -t $i
    echo "Killed Tmux session: $i"
  done

  tmux ls >/dev/null 2>&1
  if [[ $? == 1 ]]; then
    echo "There are no more open Tmux sessions!"
    return 0
  fi
}

# ----------------------
# Kill all Tmux sessions
tka() {
  tmux ls >/dev/null 2>&1
  if [[ $? == 1 ]]; then
    echo "There are no open Tmux sessions."
    return 1
  fi

  for i in $(tmux ls | cut -d ':' -f1); do
    tmux kill-session -t $i
    echo "Killed session: $i"
  done

  tmux ls >/dev/null 2>&1
  if [[ $? == 1 ]]; then
    echo "There are no more open Tmux sessions."
    return 1
  fi
}

# ----------------------
alias etm="$EDITOR $HOME/Filen_io/ssd_env/config/app/tmux/tmux.conf "
