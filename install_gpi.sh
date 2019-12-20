#!/bin/bash
echo "Downloading install script ...."
sleep 2
wget -q -O - https://raw.githubusercontent.com/crcerror/retroflag-picase/master/gpi/install.sh | bash
