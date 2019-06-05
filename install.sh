#!/bin/bash
#
# BLE_remote /install.sh
# Installing 'BLE_remote'
# Creator: Gil Hazan (gilhaz)

# Get path to install folder
install_dir=$(dirname $(readlink -f "${0}"))
# Set path to 'BLE-remote.service' file
service_dir="/etc/systemd/system/BLE-remote.service"

# Ceating systemctl 'BLE-remote.service'
echo "Copy 'BLE-remote.service' to $service_dir"
cp $install_dir/BLE-remote.service $service_dir
echo "Editing $service_dir EnvironmentFile & ExecStart"
sed -i "9s#.*#EnvironmentFile="$install_dir"/ble_config.conf#" $service_dir
sed -i "10s#.*#ExecStart="$install_dir"/./run.sh "'${DEVICES[@]} $POST_SERVER'"#" $service_dir
echo "Run 'systemctl daemon-reload'"
systemctl daemon-reload
echo "Done"
