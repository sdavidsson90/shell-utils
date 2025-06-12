# name: kat
# description:
#   prints the content of file to stdout
#   useful for providing clear separation between multiple files
# usage:
#   kat <file>: cat target file

kat() {
  HEADER_ON=$(
    tput bold
    tput setaf 0
    tput setab 7
  )
  HEADER_OFF=$(tput sgr0)

  for i in "$@"; do

    # Error handling
    [ -d "$i" ] && continue

    # Header
    local last_modified_date=$(date -r "$i" "+%Y-%m-%d %H:%M:%S")
    echo -e "${HEADER_ON}$i ($last_modified_date)${HEADER_OFF}"

    # Content
    [ ! -f "$i" ] && echo "Does not exist" && continue
    [ ! -r "$i" ] && echo "Not a printable file" && continue
    [ ! -s "$i" ] && echo "<empty>" && continue
    cat "$i"

    # Print newline, if there is none
    [ -n "$(tail -c1 $i)" ] && printf "\n" || true

  done
}
