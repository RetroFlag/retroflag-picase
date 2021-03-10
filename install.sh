#!/bin/bash

SourcePath=https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master

#Check if root--------------------------------------
if [[ $EUID -ne 0 ]]; then
   echo "Please execute script as root." 
   exit 1
fi
#-----------------------------------------------------------

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

#Download Python script-----------------------------
sudo mkdir "/opt/RetroFlag"
script=/opt/RetroFlag/SafeShutdown.py
wget -O $script "$SourcePath/SafeShutdown.py"

#Enable Python script to run on start up------------
RC=/etc/rc.local

if grep -q "sudo python $script &" "$RC";
	then
		echo "File $RC already configured. Doing nothing."
	else
		sed -i -e "s/^exit 0/sudo python \/opt\/RetroFlag\/SafeShutdown.py \&\n&/g" "$RC"
		echo "File /etc/rc.local configured."
fi
#-----------------------------------------------------------

#Reboot to apply changes----------------------------
echo "RetroFlag Pi Case installation done. Will now reboot after 3 seconds."
sleep 3
sudo reboot
#-----------------------------------------------------------









