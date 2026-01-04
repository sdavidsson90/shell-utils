command -v eza >/dev/null || return 1

t() {

  # If arg is number, use this as recursion depth
  [[ "$1" =~ ^[0-9]+$ ]] && depth="-L=$1" || depth="-L=3"

  # If arg is dir, recurse into that
  [[ -d $1 ]] && dir=$1 || dir=$PWD

  eza -a --tree --icons -I .git $depth $dir
}
