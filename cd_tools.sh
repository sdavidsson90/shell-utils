# -------------------------------------------------------
# cd_up: go to parent directory

cd_up() {

  if [[ -z "$LWD" ]]; then
    export LWD="$PWD"
  fi

  if [[ $PWD > $LWD ]]; then
    export LWD="$PWD"
  else
    # Cut paths to equal lengths
    _PWD="${PWD:0:${#LWD}}"
    _LWD="${LWD:0:${#PWD}}"

    # If they are different; directory chain is different
    if [[ $_PWD != $_LWD ]]; then
      export LWD="$PWD"
    fi
  fi

  cd ..

}

# -------------------------------------------------------
# cd_down: go (back) down one directory (child)
# only works if you used `cd_up` prior to using this.

cd_down() {

  # Sanity checks
  if [[ -z "$LWD" ]]; then
    echo "Nowhere to go back to"
    return 1
  fi

  if [[ $PWD == $LWD ]]; then
    echo 'At bottom!'
    return 1
  fi

  # Cut paths to equal lengths
  _PWD=${PWD:0:${#LWD}}
  _LWD=${LWD:0:${#PWD}}

  if [[ $_PWD != $_LWD ]]; then
    echo 'In different working tree.'
    return 1
  fi

  if [[ $PWD > $LWD ]]; then
    echo "Nowhere to go back to"
    return 1
  fi

  # Get all childs of LWD according to PWD
  child_dirs=${LWD:${#PWD}}

  # Remove '/' at beginning of string (if there is one)
  child_dirs=${child_dirs#/}

  # Get the first item (until the first '/')
  target_dir=${child_dirs%%/*}

  cd $target_dir

}

# -------------------------------------------------------
# cd into newest directory
#  cdn 1: cd into newest directory
#  cdn 2: cd into second newest directory

cd_newest() {

  if [ -z $1 ]; then
    n=1
  else
    n=$1
  fi

  target_dir=$(ls -1FArt | /usr/bin/grep "/$" | /usr/bin/grep -v ".git" | tail -n "$n" | head -n 1)

  if [ -z $target_dir ]; then
    echo "No directories to go into!"
    return 1
  fi

  cd $target_dir

}

alias cdn=cd_newest

# -------------------------------------------------------
# -- Keybinds
#
# ctrl + up-arrow : cd in to parent dir
# ctrl + down-arrow : cd in to child dir
# ctrl + n : cd in to newest dir

if command -v zmodload >/dev/null 2>&1; then # if zsh
  bindkey -s "[1;5A" cd_up
  bindkey -s "[1;5B" cd_down
  bindkey -s "" cd_newest
elif command -v shopt >/dev/null 2>&1; then # if bash
  bind '"[1;5A":"cd_up
"'
  bind '"[1;5B":"cd_down
"'
  bind '"":"cd_newest
"'
fi
