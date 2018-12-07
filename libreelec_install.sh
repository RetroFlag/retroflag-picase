#!/bin/bash


#Step 1) remount /flash as writtable------------------------
mount -o remount,rw /flash
echo "Remounted /flash as writtable"

#Step 2) enable UART----------------------------------------
cd /flash/
File=config.txt
if grep -q "enable_uart=1" "$File";
	then
		echo "UART already enabled. Doing nothing."
	else
		echo "enable_uart=1" >> $File
		echo "UART enabled."
fi

#Step 3) Download & rp-tools (includes gpiozero)------------
echo "Downloading rpi-tools..."
cd /storage/.kodi/addons/
wget http://addons.libreelec.tv/8.2/RPi2/arm/virtual.rpi-tools/virtual.rpi-tools-8.2.104.zip

#Step 4) Install--------------------------------------------
echo "Installing rpi-tools..."
unzip virtual.rpi-tools-8.2.104.zip
rm virtual.rpi-tools-8.2.104.zip
chmod +x /storage/.kodi/addons/virtual.rpi-tools/bin/*

#Step 5) Download Python script-----------------------------
echo "Downloading python script..."
cd /flash/
script=libreelec_SafeShutdown.py

if [ -e $script ];
	then
		echo "Script libreelec_SafeShutdown.py already exists. Doing nothing."
	else
		wget "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/libreelec_SafeShutdown.py"
fi
#-----------------------------------------------------------

#Step 6) Enable Python script to run on start up------------
echo "Enabling autostart..."
cd /storage/.config/
echo "python /flash/libreelec_SafeShutdown.py &" >> autostart.sh
echo "Added to autostart"
#-----------------------------------------------------------

#Step 7) Reboot to apply changes----------------------------
echo "RetroFlag Pi Case installation done. Will now reboot after 3 seconds."
sleep 3
sudo reboot
#-----------------------------------------------------------









