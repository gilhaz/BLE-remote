#!/bin/bash

# Setting path
path_="$( cd "$(dirname "$0")" ; pwd -P )"

if [[ ! -d  $path_/log ]]; then
  sudo mkdir $path_/log/
  sudo chmod 755 $path_/log
fi


# Load 'ble_config.conf' values
source $path_/ble_config.conf
# load functions
source $path_/functions.sh

# Chacking if a mac address was passed to script
_chack_input ${DEVICES[@]}

# Reaset the hci0 to fix connection problams
_toggle_hci

# Chaching availability of the devices in array
declare -A devices_list

for mac_address in ${DEVICES[@]}; do
  echo "Attampting to connect to $mac_address"
  if _check_state $mac_address; then # if the result is 'true'

    if _connect $mac_address; then
      echo "$mac_address is connected with pid number: $pid"
    else
      echo "$mac_address falid to connect, trying again.."
      sleep 1

      if _connect $mac_address; then
        echo "$mac_address is connected with pid number: $pid"
      else
        echo "$mac_address is unreachable"
      fi
    fi
    # if '_check_state $mac_address' result is 'false'
  fi

done
