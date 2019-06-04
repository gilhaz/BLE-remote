#!/bin/bash
#
# BLE_remote /run.sh
# Main script to be run by '/etc/systemd/system/BLE-remote.service'
# Connect to devices listed in /ble_config.conf file,
# and watch devices for errors or clicks
# Creator: Gil Hazan (gilhaz)

# Getting 'ble_config.conf' values as environment variables from 'BLE-remote.service'
DEVICES=("${1[@]}")
POST_SERVER=$2

# Setting path
path_="$( cd "$(dirname "$0")" ; pwd -P )"

if [[ ! -d  $path_/log ]]; then
  sudo mkdir $path_/log/
  sudo chmod 755 $path_/log
fi

# load functions
source $path_/functions.sh

# Chacking if a mac address was passed to script
_chack_input ${DEVICES[@]} # array var from '/ble_config.conf'

# Reaset the hci0 to fix connection problams
_toggle_hci

# Chaching availability of the devices in array
declare -A active_devices # declare NAMEs associative arrays ( [ key|value ] array variable )
declare -A devices_clicks # declare NAMEs associative arrays ( [ key|value ] array variable )

for mac_address in ${DEVICES[@]}; do
  _run $mac_address
  sleep 1
done

# Watch for errors for devices listed in '$active_devices'
if [[ -z "$active_devices" ]]; then
  echo "Watching "${!active_devices[@]}" for clicks or errors"

  while [[ true ]]; do
    if [ ! -z "$(_error_catch)" ]; then
      echo "Error! restarting"
      exit 1
    fi

    for mac_address in ${!active_devices[@]}; do
    _click_catch $mac_address
    sleep 1.3
  done
  done

else
  echo "Can't find any of: "${DEVICES[@]}""
exit 1

fi
