#!/bin/bash

[ -z $SourcePath ] && SourcePath=https://raw.githubusercontent.com/RetroFlag/retroflag-picase/master


#Check if root--------------------------------------
if [[ $EUID -ne 0 ]]; then
   echo "Please execute script as root." 
   exit 1
fi
#-----------------------------------------------------------

#RetroFlag pw io ;2:in ;3:in ;4:in ;14:out 1----------------------------------------
File=/boot/firmware/config.txt
wget -O  "/boot/firmware/overlays/RetroFlag_pw_io.dtbo" "$SourcePath/RetroFlag_pw_io.dtbo"
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
mkdir "/opt/RetroFlag"
script=/opt/RetroFlag/SafeShutdown.py
wget -O $script "$SourcePath/ubuntu_SafeShutdown.py"

#Enable Python script to run on start up------------
service=/lib/systemd/system/safe-shutdown.service
wget -O $service "$SourcePath/ubuntu_safe-shutdown.service"

systemctl enable safe-shutdown
echo "Added service '$service' to system startup."

#-----------------------------------------------------------

#Reboot to apply changes----------------------------
echo "RetroFlag Pi Case installation done. Will now reboot after 3 seconds."
sleep 3
sudo reboot
#-----------------------------------------------------------
