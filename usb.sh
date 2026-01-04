usb() {
    destination=$(df | awk '{ print $9 }' | grep -e '^/Volumes/' | fzf --no-multi)
    [ -z $destination ] && return 130
    cd $destination
  }


eject_usb() {
    destination=$(df | awk '{ print $9 }' | grep -e '^/Volumes/' | fzf --no-multi)
    [ -z $destination ] && return 130
    cd
    diskutil eject $destination
  }
