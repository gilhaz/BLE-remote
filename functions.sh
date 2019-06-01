#!/bin/bash

# Chacking the input is a mac address
function _chack_input() { # - get array of mac address as input

if [ -z "$1" ]; then
  echo "missing value!"
  exit 1

else
  echo values in array: "${#@}"
  n=null
  echo "checking MAC address format.."

  for mac_address in ${@}; do
    ((n++))

  if [[ $mac_address =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]]; then
    echo "$n: '"$mac_address"' OK"

  else
    echo "$n: '"$mac_address"' is not a valid MAC address"
    echo "Use this format: XX:XX:XX:XX:XX:XX XX:XX:XX:XX:XX:XX"
    echo "Use only hex string [0-9] [a-f] and colon [:]"
    exit 1

  fi
done
fi
return 0
}

# Reaset the hci0 to fix connection problams
function _toggle_hci() {
  echo toggle hci0 down and up
  sudo hciconfig hci0 down; sudo hciconfig hci0 up
  return 0
}

# Chaching availability of the device
function _check_state() { # - get 1 mac address as input & returns [true/false]
  scan="$(sudo timeout -s SIGINT 5 hcitool lescan | grep $1)"

  if [[ $scan == *$1* ]]; then
    echo "'"$1"' is avalible"
    return 0
  else
    echo "'"$1"' is not avalible"
    return 1

  fi
}

# Killing process of active gettool connection
function _kill() { # -get a MAC address as input
kill_pid="${devices_list[${1}]}"
if [[ ! -z $kill_pid ]]; then
  echo killing $1
  kill "$kill_pid"
  unset "devices_list[$1]" #delete device $mac_address & $pid from $devices_list array
  return 0
else
  echo "unable to kill '"$1"' process: $kill_pid"
  return 1
fi
}

# Connecting to BLE device with getttool and kip the connection running
function _connect() { # - get 1 mac address as input & returns [PID number/exit 1]

log="log-"${1//:}"" # remove ':' cherecters from var
sudo touch $path_/log/$log

echo "Connecting.."
sudo echo 'connect' | sudo gatttool -I -b $1 >$path_/log/$log &
pid=$!
devices_list+=( ["$1"]=$pid )

while [ -z "$connect_grep" ]; do
  if [[ "$r" != false ]]; then
    echo "Waiting for state.."
  fi

  # Search for string to indicate state
  connect_grep="$(egrep -m 1 "Connection successful|Invalid file descriptor|error" $path_/log/$log)"
  r=false
  sleep 1
done

echo "$connect_grep"

if [[ $connect_grep != *"Connection successful"* ]]; then
  echo "Connection faild"
  _kill $1
  return 1
else
  echo "$pid"
  return 0
fi

}
