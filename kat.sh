kat() {

  # ===========================================================================
  # name: kat
  # description:
  #   prints the content of file to stdout
  #   useful for providing clear separation between multiple files
  # usage:
  #   kat <file>: cat target file(s)
  # ===========================================================================

  HEADER_ON=$(tput bold; tput setaf 0; tput setab 7)
  HEADER_OFF=$(tput sgr0)

  # If no input is given → print all
  if [ -z $1 ]; then
    target_files=()
    for i in *; do
      target_files+=("$i")
    done
  else
    input=("$@")
    target_files=()
    for i in ${input[@]}; do
      target_files+=("$i")
    done
  fi

  for i in "${target_files[@]}"; do

    # Skip directories
    [ -d "$i" ] && continue

    # Header
    last_modified_date=$(date -r "$i" "+%Y-%m-%d %H:%M:%S") 2> /dev/null
    echo -e "${HEADER_ON}$i ($last_modified_date)${HEADER_OFF}"

    [ ! -r "$i" ] && { echo "Not a printable file" ; continue ; }
    [ ! -f "$i" ] && { echo "Not a regular file" ; }
    [ ! -s "$i" ] && { echo "<empty>" ; continue ; }
    bat -pP "$i"

    # Print newline, if there is none
    [ -n "$(tail -c1 $i)" ] && printf "\n" || true

  done

}



katn() {

  # name: katn
  # Prints the last modified file
  # Inputs:
  #   katn: newest file 
  #   katn 1: newest file 
  #   katn 2: second newest file
  #   katn 3: third newest file
  #   and so on ...

  [[ -z $1 ]] && file_n=1 || file_n="$1"
  local file=$(find . -maxdepth 1 -type f -not -name '.*' -exec ls -t {} + | head -n $file_n | tail -n 1) 
  kat $file
}
