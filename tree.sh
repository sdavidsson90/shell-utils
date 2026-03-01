command -v eza >/dev/null || return 1

t() {

  depth="-L=3"
  dir=$PWD

  [[ -d "$1" ]] && dir="$1"
  [[ -d "$2" ]] && dir="$2"

  [[ "$1" =~ ^[0-9]+$ ]] && depth="-L=$1"
  [[ "$2" =~ ^[0-9]+$ ]] && depth="-L=$2"

  eza -a --tree --icons -I .git "$depth" "$dir"
}
