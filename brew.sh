command -v brew >/dev/null || return 1

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1

brew_list() {
  apps=()
  apps+="$(brew list --installed-on-request)"
  apps+="$(brew list --casks)"
  printf "%s\n" "${apps[@]}" | fzf --multi
}

brew_remove() {
  selected=($(brew_list))
  for i in "${selected[@]}"; do
    brew remove "$i"
  done
}

brew_upgrade() {
  echo "⚙︎ Checking for updates to Homebrew"
  brew update
  brew upgrade
  brew doctor
  brew autoremove
  brew cleanup
}
