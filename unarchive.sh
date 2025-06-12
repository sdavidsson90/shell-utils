# Automatically selects the right unarchiving tool

unarchive() {
  if [ -z "$@" ]; then
    echo "No target file(s) provided."
    return 1
  fi
  for i in "$@"; do
    if [ -f "$i" ]; then
      case "$i" in
      *.tar.bz2) tar xjf $i ;;
      *.tar.gz) tar xzf $i ;;
      *.bz2) bunzip2 $i ;;
      *.rar) rar x $i ;;
      *.gz) gunzip $i ;;
      *.tar) tar xf $i ;;
      *.tbz2) tar xjf $i ;;
      *.tgz) tar xzf $i ;;
      *.zip) unzip $i ;;
      *.Z) uncompress $i ;;
      *.7z) 7z x $i ;;
      *) echo "$i cannot be unarchived";;
      esac
    else
      echo "$i is not a file"
    fi
  done
}

