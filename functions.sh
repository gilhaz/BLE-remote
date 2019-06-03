#!/bin/bash
#
# BLE_remote /functions.sh
# Functions list to be load by /run.sh
# Creator: Gil Hazan (gilhaz)

# Chacking the input is a mac address
function _chack_input() { # - get array of mac address as input

if [ -z "$1" ]; then
  echo "missing value!"
  exit 1

else
  echo values in array: "${#@}"
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
lescan="$(sudo timeout -s SIGINT 5 hcitool lescan | grep $1)"

  if [[ $lescan == *$1* ]]; then
    echo "'"$device_mac"' is avalible"
    return 0
  else

    echo "'"$1"' is not avalible"
    return 1
  fi
}

# Killing process of active gettool connection
function _kill() { # -get a MAC address as input
kill_pid="${active_devices[${1}]}"
if [[ ! -z $kill_pid ]]; then
  echo "killing '"$1"', process pid: $kill_pid"
  kill "$kill_pid" &
  echo "Removing $kill_pid from "${active_devices[@]}""
  unset "active_devices[$1]" #delete device $mac_address & $pid from $active_devices array
  return 0
else
  echo "unable to kill '"$1"',  process pid : $kill_pid"
  return 1
fi
}

function _log_file() { # Get MAC address as input & returns log file name
# Usage examlpe: log_path="$(_log_file $mac_address)"
log_path=""$path_"/log/log-"${1//:}"" # remove ':' cherecters from var
echo $log_path
}

# Connecting to BLE device with getttool and kip the connection running
function _connect() { # - get 1 mac address as input & returns [PID number/exit 1]
log_path="$(_log_file $1)"
sudo touch $log_path

echo "Connecting.."
sudo echo 'connect' | sudo gatttool -I -b $1 >$log_path &
pid="$!"
# - Add [ device | pid ] pair to active_devices array
echo "Addind $1 to active_devices "
active_devices+=( ["$1"]=$pid )

r=1
end=$((SECONDS+10)) # using the $SECONDS variable, which has a count of the time that the script (or shell) has been running for
while [ -z "$connect_grep" ]; do # if [ no state recived ]
  echo $r
  if [[ "$r" != 10 ]]; then
    if [[ "$r" = 1 ]]; then
      echo "Waiting for state.."
    fi
    connect_grep="$(egrep -m 1 "Connection successful|Invalid file descriptor|error" $log_path)"
  else
    connect_grep="Not found"
  fi
  # Search for string to indicate state
  sleep 1
  ((r++))
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

# process all devices and connect
function _run() {
    echo "Attampting to connect $1"
    # Check device availability & connect if true
    if _check_state $1; then
      if _connect $1; then
        echo "Connected :)"
      fi
    fi
}

# Search for 'Invalid file descriptor' error in 'BLE-remote.service' journalctl log
function _error_catch() {
  err_grep= timeout -s SIGINT 1 journalctl -f -u BLE-remote.service | grep -m1 "Invalid"
  if [ ! -z "$err_grep" ] ; then
    echo $err_grep
    return 1
  fi
  return 0
}

function _click_catch() { # get MAC address as input and returns click count if or )
  log_path="$(_log_file $1)"
  click_grep="$(egrep -o "Notification handle" $log_path | wc -l)"

if [[ $click_grep != 0 ]] ; then
 saved_clicks="${devices_clicks[${1}]}"

 if [[ ! -z $saved_clicks ]]; then
 current_click=$((click_grep-saved_clicks))
 else
   current_click=$click_grep
 fi
 if [[ $click_grep != $saved_clicks ]]; then
   echo "$1 $current_click"
 fi
  devices_clicks+=( ["$1"]=$click_grep )
fi
}

# Watch the log for errors and kill process if error
function _watch() { # - Get 1 MAC address as input
for mac_address in ${!active_devices[@]}; do
  kill_pid="${active_devices[${mac_address}]}"
  log_path="$(_log_file $mac_address)"
  err_grep="$(egrep -o -m 1 "error|Invalid|GLib" $log_path)"

  echo $err_grep
  echo $log_path
  if [ ! -z "$err_grep" ]; then
    kill_pid="${active_devices[$mac_address]}" # - get pid from array by MAC value
    echo "ERROR! $err_grep - $kill_pid to kill process"

  else
    echo "$mac_address is OK, keep process $kill_pid runnung"
    echo "sleep 5"
    sleep 5
  fi
done
}

# Extract key & value from NAMEs associative array variable
function _key_arr() { # get arrays variable as input
  for key in ${!arr[@]}; do
    echo ${key} ${arr[${key}]}
done
}
