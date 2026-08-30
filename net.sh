net() {
  ping -t 2 -c 1 8.8.8.8 > /dev/null 2>&1 && echo "We can reach the internet!" || echo "No internet!"
}
