#!/bin/bash

SourcePath=https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master

#make /boot writable---------------------------------
sleep 2s

mount -o remount, rw /boot
mount -o remount, rw /

#RetroFlag pw io ;2:in ;3:in ;4:in ;14:out 1----------------------------------------
File=/boot/config.txt
wget -O  "/boot/overlays/RetroFlag_pw_io.dtbo" "$SourcePath/RetroFlag_pw_io.dtbo"
if grep -q "RetroFlag_pw_io" "$File";
	then
		sed -i '/RetroFlag_pw_io/c dtoverlay=RetroFlag_pw_io.dtbo' $File 
		echo "PW IO fix."
	else
		echo "dtoverlay=RetroFlag_pw_io.dtbo" >> $File
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
sleep 2s
File=/recalbox/share/system/recalbox.conf
if grep -q "system.power.switch" "$File";
	then
		sed -i '/system.power.switch/c system.power.switch=PIN356ONOFFRESET' "$File"
		echo "power switch fix."
	else
		echo "system.power.switch=PIN356ONOFFRESET" >> $File
		echo "power switch enabled."
fi
#-----------------------------------------------------------

#Download Python script-----------------------------
mkdir /opt/RetroFlag
sleep 2s

script=/opt/RetroFlag/SafeShutdown.py
wget --no-check-certificate -O  $script "$SourcePath/recalbox_SafeShutdown.py"
#-----------------------------------------------------------

sleep 2s

#Enable Python script to run on start up------------
DIR=/etc/init.d/S99RetroFlag

if grep -q "python $script &" "$DIR";
	then
		if [ -x $DIR ];
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

#Reboot to apply changes----------------------------
echo "RetroFlag Pi Case Switch installation done. Will now reboot after 3 seconds."
sleep 3
reboot
#-----------------------------------------------------------
