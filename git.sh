gs() {
  # git switch via fzf

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
  target=$(printf "%s\n" "${branches[@]}" | sort -r | fzf -i --no-multi --cycle --height=5)
  git switch $target

}

gor() {
  # git open remote in borwser

  # Check if user is standing in git repo
  is_git=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  if [[ $is_git != true ]]; then
    echo "This is not a git repo"
    return 1
  fi

  url="$(git remote get-url origin | sed -E 's#git@([^:]+):#https://\1/#')"
  echo "Open: $url"
  open $url

}
