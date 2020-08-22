#!/bin/bash
#Prestep autodetect which system is used -------------------

if [[ -e /recalbox/batocera.version || -e /usr/share/batocera/batocera.version ]]; then
    echo "--> Detected BATOCERA system"
    inst_dir="/recalbox/share/scripts"
    autostartscript="/recalbox/share/system/custom.sh"
elif [[ -e /recalbox/recalbox.version ]]; then
    echo "--> Detected RECALBOX system"
    inst_dir="/opt/RetroFlag"
    autostartscript="/etc/init.d/S99RetroFlag"
else
    echo
    echo "Error!"
    echo "Could not find a valid system! So nothing changed now ..."
    exit
fi

# Build global variables
script="${inst_dir}/recalbox_SafeShutdown.py"

#Step 1 make /boot writable---------------------------------
sleep 2s

mount -o remount, rw /boot
mount -o remount, rw /

#Step 2) enable UART and system.power.switch----------------
sleep 2s

if grep -q "^enable_uart=1" "/boot/config.txt"; then
	echo "UART already enabled... Proceed!"
elif grep -q "^#enable_uart=1" "/boot/config.txt"; then
	echo "UART is disabled. Enabling now!"
	echo "Activating UART - your CPU could be throttled by this"
	sed -i -e "s|^#\senable_uart=1|enable_uart=1|" "/boot/config.txt" &> /dev/null
else
	echo "UART is disabled."
	echo "Appending enable_uart=1 to config.txt"
	echo "enable_uart=1" >> "/boot/config.txt"
fi

#Step 3) Download Python script-----------------------------
sleep 2

mkdir "$inst_dir"
cd "$inst_dir"

if [ -e $script ];
	then
		echo "Script SafeShutdown.py already exists. Overwriting file now!"
		echo "Downloading ..."
	else
		echo "Script will be installed now! Downloading ..."
fi

wget -N -q --show-progress "https://raw.githubusercontent.com/crcerror/retroflag-picase/master/other_os/recalbox_SafeShutdown.py"
wget -N -q --show-progress "https://raw.githubusercontent.com/crcerror/retroflag-picase/master/other_os/recalbox_SafeShutdown.sh"
chmod +x recalbox_SafeShutdown.sh

#Step 4) Enable Python script to run on start up------------
sleep 2s

if grep -q "python $script &" "$autostartscript";
	then
		if [ -x $autostartscript ];
			then 
				echo "Executable $autostartscript already configured. Doing nothing."
			else
				chmod +x $autostartscript
		fi
	else
		echo "python $script &" >> $autostartscript
		chmod +x $autostartscript
		echo "Executable $autostartscript configured."
fi

#-----------------------------------------------------------

#Step 6) enable overlay file for proper powercut ---------------
cd /boot/
File=config.txt
if ! grep -q "^[ ]*dtoverlay=gpio-poweroff,gpiopin=4,active_low=1,input=1" "$File"; then
    echo "Enable overlay file"
    echo "# Overlay setup for proper powercut, needed for Retroflag cases" >> "$File"
    echo "dtoverlay=gpio-poweroff,gpiopin=4,active_low=1,input=1" >> "$File"
fi

#-----------------------------------------------------------

#Step 5) Reboot to apply changes----------------------------
echo "RetroFlag Pi Case Switch installation done. Will now reboot after 3 seconds."
sleep 3
shutdown -r now
#-----------------------------------------------------------
