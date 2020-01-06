#!/bin/bash
# Retroflag Advanced Shutdown Mod by crcerror
# This is exclusivly for BATOCERA
# Intended to work for BATOCERA versions 5.24
#
# Release Power Button to shutdown your GPi case

version=$(grep -o '^[^ ]*' $HOME/data.version)

# Minimum version of BATOCERA is 5.24 because here batocera-es-swissknife is integrated
# so all versions less then 5.24 will be dropped from further install
if [[ ${version//[^[:digit:]]/} -lt 524 ]]; then
    echo "Error!"
    echo "Your current version of Batocera is '$version'"
    echo "You need at least 5.24 ...."
    exit
fi 

echo "Welcome to the Safe Shutdown installer..."
echo "Batocera '$version' detected..."
sleep 2

echo "Activate RETROFLAG_GPI in batocera.conf"
batocera-settings set system.power.switch RETROFLAG_GPI
sleep 2
echo; echo

echo "Add Safe Shutdown feature for running emulator instance"
if [[ -f /userdata/system/custom.sh ]]; then
   echo
   echo "custom.sh is already available ..."
   echo "I don't change anything here!"
   echo
else 
   cat > /userdata/system/custom.sh <<_EOF_
#!/bin/bash
# custom.sh - place to /userdata/system
# by cyperghost 23/11/19
#
     
if [[ \$1 == stop ]]; then
    batocera-es-swissknife --emukill
fi
_EOF_
    
    chmod +x /userdata/system/custom.sh
fi

echo "Rebooting in 5 seconds...."
sleep 5
shutdown -r now
