#!/bin/bash

# Uninstall all versions of SafeShutdown script
# Supported distributions are RetroPie, Batocera, Recalbox
# v1.0 cyperghost - 2020/01/02

readonly BOOTFILE=/boot/config.txt
readonly SCRIPTDIR=/opt/RetroFlag

echo "Try to delete dir: $SCRIPTDIR"
if [[ -d "$SCRIPTDIR" ]]; then
   rm -rf "$SCRIPTDIR"
   [[ $? -eq 0 ]] && echo "'$SCRIPTDIR': removed sucessfull!" || echo "'$SCRIPTDIR': removal failed!"
else
   echo "Can't find directory '$SCRIPTDIR'"
   echo "Proceed...."
fi

echo
echo "Try to remove autostart-feature"
if grep -q "^sudo python3 $SCRIPTDIR" "/etc/rc.local"; then
    sed -i -e "s|^sudo python3.*||g" "/etc/rc.local"
    [[ $? -eq 0 ]] && echo "Autostart disabled" || echo "Autostart nothing changed"
elif grep -q "sudo python $SCRIPTDIR" "/etc/rc.local"; then
    sed -i -e "s|sudo python.*||g" "/etc/rc.local"
    [[ $? -eq 0 ]] && echo "Autostart disabled" || echo "Autostart nothing changed"
elif [[ -f /etc/init.d/S99RetroFlag ]]; then
    ## RECALBOX
    mount -o remount, rw /boot
    mount -o remount, rw /
    rm -f /etc/init.d/S99RetroFlag
    [[ $? -eq 0 ]] && echo "Autostart disabled" || echo "Autostart nothing changed"
elif [[ -f /usr/share/batocera/batocera.version ]]; then
    ## BATOCERA VERSION > 5.23 supported only
    batocera-settings comment system.power.switch
    [[ $? -eq 0 ]] && echo "Autostart disabled" || echo "Autostart nothing changed"
    mount -o remount, rw /boot
else
    echo "Autoremove failed!"
    echo "Sorry!"
    exit 1
fi

echo "Try to disable UART"
if grep -q "^[ ]*enable_uart=1" "$BOOTFILE"; then
    sed -i -e "s|^\senable_uart=1|#enable_uart=1|" "$BOOTFILE" &> /dev/null
    [[ $? -eq 0 ]] && echo "UART disabled" || echo "Can't disable UART"
else
    echo "UART seems to be disabled now!"
    echo "'$BOOTFILE':Please check manually!"
fi

echo "Try to disable overlay file"
if grep -q "^[ ]*dtoverlay=gpio-poweroff,gpiopin=4,active_low=1,input=1" "$BOOTFILE"; then
    sed -i -e "s|^\s*dtoverlay=gpio-poweroff,gpiopin=4,active_low=1,input=1|#dtoverlay=gpio-poweroff,gpiopin=4,active_low=1,input=1|" "$BOOTFILE" &> /dev/null
    [[ $? -eq 0 ]] && echo "overlay disabled" || echo "Can't find overlay file"
elif grep -q "^[ ]*dtoverlay=RetroFlag_pw_io.dtbo" $BOOTFILE; then
    sed -i -e "s|^\s*dtoverlay=RetroFlag_pw_io.dtbo|#dtoverlay=RetroFlag_pw_io.dtbo|" "$BOOTFILE" &> /dev/null
    [[ $? -eq 0 ]] && echo "overlay disabled" || echo "Can't find overlay file"
else
    echo "Overlay file not found"
    echo "'$BOOTFILE':Please check manually!"
fi
