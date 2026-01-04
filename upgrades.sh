[[ $(uname) != "Darwin" ]] && return 1

upgrade_macos() {
  trap 'return 127' SIGINT
  echo "⚙︎ Checking for updates to MacOS"
  softwareupdate --install --all
}


upgrades() {
  # upgrade_macos
  brew_upgrade
}
