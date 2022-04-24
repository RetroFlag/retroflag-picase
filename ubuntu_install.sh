#!/bin/bash

#DEV_ROOT=

CURL_EXEC=$( which curl )
PYTHON_EXEC=$( which python | which python3 )
WGET_EXEC=$( which wget )

[ -z $SourcePath ] && SourcePath=https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master


#Check if root--------------------------------------
if [[ $EUID -ne 0 ]]; then
   echo
   echo "Please execute script as root." 
   exit 1
fi
#---------------------------------------------------

if [[ -z "$WGET_EXEC" ]]; then
	echo
	echo "Requires 'wget'. Please install and try again."
	exit 1
fi

if [[ -z "$CURL_EXEC" ]]; then
	echo
	echo "Requires 'curl'. Please install and try again."
	exit 1
fi

if [[ -z "$PYTHON_EXEC" || ! "$( $PYTHON_EXEC -V )" = "Python 3"* ]]; then
	echo
	echo "Requires 'python3'. Please install and try again."
	exit 1
fi

if [[ -z "$( python3 -c "import RPi.GPIO as GPIO; print(GPIO.VERSION)" )" ]]; then
	echo
	echo "Library 'python3-rpi.gpio' not found. Please install and try again."
	exit 1
fi

#RetroFlag pw io ;2:in ;3:in ;4:in ;14:out 1----------------------------------------
[[ ! -z "$DEV_ROOT" ]] && mkdir -p $DEV_ROOT/boot/firmware/overlays
File=$DEV_ROOT/boot/firmware/config.txt
$WGET_EXEC -q -O  "$DEV_ROOT/boot/firmware/overlays/RetroFlag_pw_io.dtbo" "$SourcePath/RetroFlag_pw_io.dtbo"
if grep -q "RetroFlag_pw_io" "$File";
	then
		sed -i '/RetroFlag_pw_io/c dtoverlay=RetroFlag_pw_io.dtbo' $File 
		echo "PW IO fix."
	else
		echo "dtoverlay=RetroFlag_pw_io.dtbo" >> $File
		echo "dtoverlay=gpio-poweroff,gpiopin=4,active_low=1,input=1" >> $File
		echo "PW IO enabled."
fi
if grep -q "enable_uart" "$File";
	then
		sed -i '/enable_uart/c enable_uart=1' $File 
		echo "UART fix."
	else
		echo "enable_uart=1" >> $File
		echo "UART enabled."
fi

#-----------------------------------------------------------

#Download Python script-----------------------------
mkdir -p "$DEV_ROOT/opt/RetroFlag"
script=$DEV_ROOT/opt/RetroFlag/SafeShutdown.py
$WGET_EXEC -q -O $script "$SourcePath/ubuntu_SafeShutdown.py"

#Enable Python script to run on start up------------
[[ ! -z "$DEV_ROOT" ]] && mkdir -p $DEV_ROOT/lib/systemd/system/
service=$DEV_ROOT/lib/systemd/system/safe-shutdown.service
curl -s "$SourcePath/ubuntu_safe-shutdown.service" | awk '{gsub(/PYTHON_EXEC/,"'$PYTHON_EXEC'")}1' > $service

systemctl enable safe-shutdown
echo "Added service '$service' to system startup."

#-----------------------------------------------------------

#Reboot to apply changes----------------------------
echo "RetroFlag Pi Case installation done. Will now reboot after 3 seconds."
sleep 3
sudo reboot
#-----------------------------------------------------------
