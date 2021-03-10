#!/bin/bash

SourcePath=https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master

#-----------------------------------------------------------
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

if grep -q "system.power.switch" "/userdata/system/batocera.conf";
	then
		sed -i '/system.power.switch/c system.power.switch=RETROFLAG' "/userdata/system/batocera.conf"
		echo "power switch fix."
	else
		echo "system.power.switch=RETROFLAG" >> /userdata/system/batocera.conf
		echo "power switch enabled."
fi
#-----------------------------------------------------------

mkdir /userdata/RetroFlag
sleep 2s
script=/userdata/RetroFlag/SafeShutdown.py
wget -O  $script "$SourcePath/batocera_SafeShutdown.py"
#-----------------------------------------------------------

sleep 2s
DIR=/userdata/system/custom.sh

if grep -q "python $script &" "$DIR";
	then
		if [ -x "$DIR" ];
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

echo "RetroFlag Pi Case Switch installation done. Will now reboot after 3 seconds."
sleep 3
shutdown -r now
#-----------------------------------------------------------
