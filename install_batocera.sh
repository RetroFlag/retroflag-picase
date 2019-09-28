#!/bin/bash
echo "Downloading install script .... for BATOCERA"
sleep 2
wget -q -O - https://raw.githubusercontent.com/crcerror/retroflag-picase/master/other_os/batocera_install.sh | bash
