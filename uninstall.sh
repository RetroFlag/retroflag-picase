#!/bin/bash

sudo rm -rf /opt/RetroFlag
sudo sed -i -e "s/^sudo python3.*//g" /etc/rc.local

echo "RetroFlag Pi Case uninstallation done. Will now reboot after 3 seconds."
sleep 3
sudo reboot
