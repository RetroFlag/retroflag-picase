#!/bin/bash
#Step 1 make /boot writable---------------------------------
sleep 2s

mount -o remount, rw /boot
mount -o remount, rw /

#Step 2) enable UART and system.power.switch----------------
File=/boot/config.txt
if grep -q "enable_uart=1" "$File";
	then
		echo "UART already enabled. Doing nothing."
	else
		echo "enable_uart=1" >> $File
		echo "UART enabled."
fi

sleep 2s

if grep -q "^system.power.switch=PIN356ONOFFRESET*" "/recalbox/share/system/recalbox.conf";
	then
		echo "PIN356ONOFFRESET configuration already enabled."
	else
		echo "system.power.switch=PIN356ONOFFRESET" >> /recalbox/share/system/recalbox.conf
		echo "PIN356ONOFFRESET configuration enabled."
fi
#-----------------------------------------------------------

#Step 3) Download Python script-----------------------------
mkdir /opt/RetroFlag
sleep 2s

script=/opt/RetroFlag/SafeShutdown.py

if [ -e $script ];
	then
		echo "Script SafeShutdown.py already exists. Doing nothing."
	else
		wget --no-check-certificate -O  $script "https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master/recalbox_SafeShutdown.py"
fi
#-----------------------------------------------------------

sleep 2s

#Step 4) Enable Python script to run on start up------------
DIR=/etc/init.d/S99RetroFlag

if grep -q "python $script &" "S99RetroFlag";
	then
		if [ -x $DIR];
			then 
				echo "Executable S99RetroFlag already configured. Doing nothing."
			else
				chmod +x $DIR
		fi
	else
		echo "python $script &" >> $DIR
		chmod +x $DIR
		echo "Executable S99RetroFlag configured."
fi
#-----------------------------------------------------------

#Step 5) Reboot to apply changes----------------------------
echo "RetroFlag Pi Case Switch installation done. Will now reboot after 3 seconds."
sleep 3
shutdown -r now
#-----------------------------------------------------------
