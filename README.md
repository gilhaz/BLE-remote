# BLE-remote

Using a BLE remote for home automation with RaspberryPi.

## Getting Started

- connect to a given MAC address of a BLE device (with a button)
- listen to clicks being made by the device
- monitor for disconnect or errors and try to connect again

### Prerequisites
- RaspberryPi (tested on pi 3)
- BLE remote

Here is the result of 'hcitool leinfo' for the BLE remote I've used:
```
pi@raspberrypi:~ $ ***sudo hcitool leinfo <MAC-ADDRESS>***
Requesting information ...
	Handle: 64 (0x0040)
	LMP Version: 4.0 (0x6) LMP Subversion: 0x4103
	Manufacturer: Telink Semiconductor Co. Ltd (529)
	Features: 0x01 0x00 0x00 0x00 0x00 0x00 0x00 0x00
```

### install bluez (bluetooth protocol stack)
In Terminal execute the following commands:
*Replace any occurrence of 'bluez-5.50' with the newest version you find in [bluez.org](http://www.bluez.org/download/)*

```
sudo wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.50.tar.xz
dpkg --get-selections | grep -v deinstall | grep bluez
tar xvf bluez-5.50.tar.xz
sudo apt-get install libglib2.0-dev libdbus-1-dev libusb-dev libudev-dev libical-dev systemd libreadline-dev
cd bluez-5.50
sudo ./configure --enable-library
sudo make -j8 && sudo make install
sudo cp attrib/gatttool /usr/local/bin/
```
