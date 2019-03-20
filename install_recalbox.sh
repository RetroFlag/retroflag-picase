#!/bin/bash
echo "Downloading install script .... for RECALBOX"
sleep 2
wget -q -O - https://raw.githubusercontent.com/crcerror/retroflag-picase/master/other_os/recalbox_install.sh | bash
