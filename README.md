# BLE-remote

Using a BLE remote for home automation with RaspberryPi.

## What It Will Do..

- ***Connect*** to a given MAC address of a BLE device (with a button)
- ***Monitor*** for disconnect or errors and try to connect again
- ***Listen*** to clicks being made by the device

### Prerequisites
- RaspberryPi (tested on pi 3)
- BLE remote

Here is the result of ```hcitool leinfo``` for the BLE remote I've used:
```shell
pi@raspberrypi:~ $ sudo hcitool leinfo <MAC-ADDRESS>
Requesting information ...
	Handle: 64 (0x0040)
	LMP Version: 4.0 (0x6) LMP Subversion: 0x4103
	Manufacturer: Telink Semiconductor Co. Ltd (529)
	Features: 0x01 0x00 0x00 0x00 0x00 0x00 0x00 0x00
```
>You can find the MAC address by:\
First, running ```hcitool lescan```\
Then, turn on the device and watch for the last one added.

## Install Node-Red (to setup the HTTP response server)
In Terminal execute the following commands:
```shell
bash <(curl -sL https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/update-nodejs-and-nodered)
sudo systemctl enable nodered.service
sudo systemctl start nodered.service
npm install node-red-dashboard
```
### Add Node-Red Flow
*This flow will set HTTP response to POST from BLE-remote script (for use in automation)*
- Go to your Node-Red GUI (e.g. localhost:1880)
- Import > Clipboard
- Past the following flow
- Click 'Import'
- Change the 'MAC list' node, to list the MAC address you set in 'ble_config.conf'
- Click 'Deploy'

#### BLE-remote Node-Red flow
```json
[{"id":"d8fb803d.87e658","type":"tab","label":"BLE-remote","disabled":false,"info":""},{"id":"aac8f684.b0a22","type":"http in","z":"d8fb803d.87e658","name":"","url":"/BLE-remote","method":"post","upload":false,"swaggerDoc":"","x":90,"y":160,"wires":[["93c4ad11.7d4358","660362d6.eae364","393ae75d.74d858"]]},{"id":"f872ad39.b958f","type":"debug","z":"d8fb803d.87e658","name":"Clicks","active":true,"tosidebar":true,"console":false,"tostatus":false,"complete":"payload","targetType":"msg","x":610,"y":140,"wires":[]},{"id":"93c4ad11.7d4358","type":"http response","z":"d8fb803d.87e658","name":"http responce","statusCode":"","headers":{},"x":340,"y":100,"wires":[]},{"id":"238d1384.d32314","type":"change","z":"d8fb803d.87e658","name":"\"Device2\".clicks","rules":[{"t":"set","p":"payload","pt":"msg","to":"payload.clicks","tot":"msg"}],"action":"","property":"","from":"","to":"","reg":false,"x":460,"y":180,"wires":[["7f1ac3fe.096ccc"]]},{"id":"dd6282b0.10742","type":"change","z":"d8fb803d.87e658","name":"\"Device1\".clicks","rules":[{"t":"set","p":"payload","pt":"msg","to":"payload.clicks","tot":"msg"}],"action":"","property":"","from":"","to":"","reg":false,"x":460,"y":140,"wires":[["f872ad39.b958f"]]},{"id":"7f1ac3fe.096ccc","type":"debug","z":"d8fb803d.87e658","name":"Clicks","active":true,"tosidebar":true,"console":false,"tostatus":false,"complete":"payload","targetType":"msg","x":610,"y":180,"wires":[]},{"id":"660362d6.eae364","type":"switch","z":"d8fb803d.87e658","name":"MAC list","property":"payload.mac_address","propertyType":"msg","rules":[{"t":"eq","v":"FF:FF:3D:19:A9:F9","vt":"str"},{"t":"eq","v":"FF:FF:3D:19:7C:7A","vt":"str"},{"t":"else"}],"checkall":"true","repair":false,"outputs":3,"x":280,"y":160,"wires":[["dd6282b0.10742"],["238d1384.d32314"],["9185a6f7.b36e4"]]},{"id":"393ae75d.74d858","type":"debug","z":"d8fb803d.87e658","name":"full JSON","active":true,"tosidebar":true,"console":false,"tostatus":false,"complete":"payload","targetType":"msg","x":320,"y":60,"wires":[]},{"id":"9185a6f7.b36e4","type":"debug","z":"d8fb803d.87e658","name":"Debug","active":false,"tosidebar":true,"console":false,"tostatus":false,"complete":"payload","targetType":"msg","x":430,"y":220,"wires":[]}]
```
>In Node-Red:\
Change the 'MAC list' node, to list the MAC address you set in 'ble_config.conf'\
Click 'Deploy'


## Install bluez (bluetooth protocol stack)
In Terminal execute the following commands:\
*Replace any occurrence of ```bluez-5.50``` with the newest version you find in* ***[bluez.org](http://www.bluez.org/download/)***

```shell
sudo wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.50.tar.xz
dpkg --get-selections | grep -v deinstall | grep bluez
tar xvf bluez-5.50.tar.xz
sudo apt-get install libglib2.0-dev libdbus-1-dev libusb-dev libudev-dev libical-dev systemd libreadline-dev
cd bluez-5.50
sudo ./configure --enable-library
sudo make -j8 && sudo make install
sudo cp attrib/gatttool /usr/local/bin/
```

### Get your device MAC address  
*find the MAC address by:
- First, running ```hcitool lescan```
- Then, turn on the device and watch for the last one added.*
```shell
sudo hciconfig hci0 down; sudo hciconfig hci0 up
sudo hcitool lescan
```
>Exit with ```ctrl c```

## Install BLE-remote
### Download the repository
```shell
sudo apt-get install git-core
git clone https://github.com/gilhaz/BLE-remote.git
```

### Run the Install script
```shell
sudo BLE-remote/install.sh
```

### Edit ble_config.conf
*Fill the < $POST_SERVER > and < $DEVICES > as listed in the file*
```shell
sudo nano BLE-remote/ble_config.conf
```

. . . . . NEED MORE INSTRUCTIONS . . . . .
