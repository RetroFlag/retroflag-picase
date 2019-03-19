#!/bin/bash
#Prestep ask user which system is being used ---------------
echo;echo "+------------------------------------------------------+"
echo "| Which system are you using [B]atocera or [R]ecalbox? |"
read -n 1 -p "+------------------------------------------------------+" choice;
choice=${choice,,}
if ! [[ $choice == "b" || $choice == "r" ]]; then
    clear
    echo "Please type B to select BATOCERA as target system or"
    echo "please type R to select RECALBOX as target system."
    echo "Please restart this script!"
    exit
fi

# Configs for Step 3 -- Location of scripts
inst_dir="/opt/RetroFlag"

# Configs for Step 4 -- Enable automatic start on boot
[[ $choice == "r" ]] && autostartscript="/etc/init.d/S99RetroFlag"
[[ $choice == "b" ]] && autostartscript="/recalbox/share/system/custom.sh"

# Build global variables
script="${inst_dir}/recalbox_SafeShutdown.py"

clear
#Step 1 make /boot writable---------------------------------
sleep 2s

mount -o remount, rw /boot
mount -o remount, rw /

#Step 2) enable UART and system.power.switch----------------
sleep 2s

if grep -q "^enable_uart=1" "/boot/config.txt";
	then
		echo "UART is already enabled. Disabling now!"
		echo "Commenting out line - your CPU is not throttled anymore"
		sed -i -e "s|^enable_uart=1|#enable_uart=1|" "/boot/config.txt" &> /dev/null
	else
		echo "UART is disabled. CPU is working with full speed"
fi
sleep 2s

if grep -q "^system.power.switch=PIN356ONOFFRESET*" "/recalbox/share/system/recalbox.conf";
	then
		echo "PIN356ONOFFRESET configuration already enabled."
	else
		echo "system.power.switch=PIN356ONOFFRESET" >> /recalbox/share/system/recalbox.conf
		echo "PIN356ONOFFRESET configuration enabled."
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

#Step 5) Reboot to apply changes----------------------------
echo "RetroFlag Pi Case Switch installation done. Will now reboot after 3 seconds."
sleep 3
shutdown -r now
#-----------------------------------------------------------
