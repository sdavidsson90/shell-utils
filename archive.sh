archive() {

  if [ -z "$@" ]; then
    echo "No target file(s) provided."
    return 1
  fi

  if [ ! -e $1 ]; then
    echo "Not a valid file path: $1"
  fi

  tar czf "${1}.tar.gz" "$@"

}
