wifi_reboot() {

  [[ $(uname) == "Darwin" ]] || return 1
  sudo -v || return 1

  printf "%-30s" "Turning off WiFi interface"
  networksetup -setairportpower en0 off && echo "✓" || echo "x" 

  printf "%-30s" "Flushing DNS cache "
  sudo dscacheutil -flushcache && echo "✓" || echo "x" 

  printf "%-30s" "Restarting DNS service "
  sudo killall -HUP mDNSResponder && echo "✓" || echo "x" 

  # printf "%-30s" "Renew DHCP lease"
  # sudo ipconfig set en0 DHCP && echo "✓" || echo "x" 

  printf "%-30s" "Turning on WiFi "
  networksetup -setairportpower en0 on && echo "✓" || echo "x" 

}
