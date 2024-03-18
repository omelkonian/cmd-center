function bluetooth__reset {
  device="$1" && shift
  (
   echo -e "remove $device \n scan on \n"
   sleep 10
   echo -e "pair $device \n trust $device \n connect $device \n scan off \n"
   sleep 10
   echo -e "quit \n"
  ) | bluetoothctl
}

function bluetooth__toggle {
  device="$1" && shift
  if bluetooth__connected $device; then
    (
     echo -e "disconnect $device \n"
     sleep 5
     echo -e "quit \n"
    ) | bluetoothctl
  else
    (
     echo -e "connect $device \n"
     sleep 10
     echo -e "quit \n"
    ) | bluetoothctl
    # Reset if connection fails
    if ! bluetooth__connected $device; then
      notify-send "resetting..."
      bluetooth__reset $device
    fi
  fi
}
