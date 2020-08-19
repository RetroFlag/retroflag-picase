#!/bin/bash
#Step 1 make /boot writable---------------------------------
sleep 2s

mount -o remount, rw /boot
mount -o remount, rw /

#Step 2) enable UART and system.power.switch----------------
File=/boot/config.txt
if grep -q "enable_uart" "$File";
	then
		sed -i '/enable_uart/c enable_uart=1' $File 
		echo "UART fix."
	else
		echo "enable_uart=1" >> $File
		echo "UART enabled."
fi

sleep 2s

if grep -q "system.power.switch" "/userdata/system/batocera.conf";
	then
		sed -i '/system.power.switch/c system.power.switch=RETROFLAG' "/userdata/system/batocera.conf"
		echo "power switch fix."
	else
		echo "system.power.switch=RETROFLAG" >> /userdata/system/batocera.conf
		echo "power switch enabled."
fi
#-----------------------------------------------------------

#Step 3) Download Python script-----------------------------
mkdir /userdata/RetroFlag
sleep 2s

script=/userdata/RetroFlag/SafeShutdown.py
wget -O  $script "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/batocera_SafeShutdown.py"
#-----------------------------------------------------------

sleep 2s

#Step 4) Enable Python script to run on start up------------
DIR=/userdata/system/custom.sh

if grep -q "python $script &" $DIR;
	then
		if [ -x $DIR];
			then 
				echo "Executable script already configured. Doing nothing."
			else
				chmod +x $DIR
		fi
	else
		echo "python $script &" >> $DIR
		chmod +x $DIR
		echo "Executable script configured."
fi
#-----------------------------------------------------------

#Step 5) Reboot to apply changes----------------------------
echo "RetroFlag Pi Case Switch installation done. Will now reboot after 3 seconds."
sleep 3
shutdown -r now
#-----------------------------------------------------------
