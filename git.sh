git_switch() {
  # git switch via fzf
  echo "Choose git branch to switch to:"

  # Check if user is standing in git repo
  is_git=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  if [[ $is_git != true ]]; then
    echo "This is not a git repo"
    return 1
  fi

  # --
  j=1
  branches[$j]=$(git branch | grep "^*" | sed 's/*\ //')
  ((j++))

  for i in $(git branch | grep -v '^*'); do
    branches[$j]=$i
    ((j++))
  done

  # --
  picker_height=$((${#target[@]} + 5))
  target=$(printf "%s\n" "${branches[@]}" | sort -r | fzf -i --no-multi --cycle --height=$picker_height)

  if [ -z $target ]; then
    echo "None chosen..."
    return 130
  else
    git switch $target
  fi

}

if command -v zmodload >/dev/null 2>&1; then
  bindkey -s '^B' git_switch^M
elif command -v shopt >/dev/null 2>&1; then
  bind '"^B":"git_switch^M"'
fi

gor() {
  # git open remote in browser

  # Check if this is a git repo
  is_git=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  [[ $is_git != true ]] && {
    echo "This is not a git repo"
    return 1
  }

  # Fetch remote URL
  url="$(git remote get-url origin 2>/dev/null | sed -E 's#git@([^:]+):#https://\1/#')"
  [[ -z $url ]] && {
    echo "No remote"
    return 1
  } || {
    echo "Open: $url"
    open $url &>/dev/null
  }

}

git_tree() {
  is_git=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  [[ $is_git != true ]] && {
    echo "This is not a git repo"
    return 1
  }
  git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue) <%an> %Creset' --abbrev-commit

}

command -v serie > /dev/null && alias gt=serie || alias gt=git_tree >/dev/null 

git_del() {
  # Git pick to (git) delete
  echo "Remove file from staging area `git rm $i`"
  targets=($(git ls-files --deleted | fzf))

  for i in ${targets[@]}; do
    git rm $i
  done
}

git_undel() {
  targets=$(git diff --cached --name-only --diff-filter=D | fzf)

  for i in ${targets[@]}; do
    git restore --staged $i
  done

  echo 'Hint: Use "git restore <file>" to restore to working directory'

}

git_add() {

  target_files=()
  for i in $(git status --porcelain | awk '{ $1=$1; gsub(/^ /, ""); print $2 }' | fzf --multi); do
    target_files+="$i"
  done

  echo "Added to staging area:"
  for i in ${target_files[@]}; do
    git add "$i" && echo $i
  done

}

git_something() {
  switch to or view stashed commits
}
