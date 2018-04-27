#!/bin/bash
# Multi Switch Shutdown
# based on ES shutdown codes posted by @cyperghost and @meleu
# v0.05 Initial version here in this repo Jan.2018 // cyperghost
# v0.07 added kill -9 switch to get rid off all emulators // julenvitoria
# v0.10 version for NESPi case // Yahmez, Semper-5
# v0.20 Added possibilty for regular shutoff (commented now!)
# v0.30 Added commandline parameters uncommented device shutdowns
# v0.32 Added privileges check and packages check
# v0.41 Added NESPi+ safe shutdown, corrected GPIO numbering

# NESPI+ is WIP CURRENTLY!

# Up to now 4 devices are supported!
#
# NESPIcase! Install raspi-gpio via "sudo apt install raspi-gpio", no sudo needed, reset, poweroff
# NESPIplus! Install raspi-gpio via "sudo apt install raspi-gpio", no sudo needed, reset, poweroff
# Mausberry! Script needs to be called with sudo, poweroff supported
# SHIMOnOff! Script needs to be called with sudo, poweroff supported

# ---------------------------------------------------------------------------------------------
# --------------------------------- P I D   D E T E C T I O N ---------------------------------
# ---------------------------------------------------------------------------------------------

# This function is called still all childPIDs are found
function get_childpids() {
    local CPIDS="$(pgrep -P $1)"
    for cpid in $CPIDS; do
        pidarray+=($cpid)
        get_childpids $CPIDS
    done
}

# Abolish sleep timer! This one is much better!
function wait_forpid() {
    local PID=$1
    [[ -z $PID ]] && return 1
    while [[ -e /proc/$PID ]]; do
        sleep 0.10
    done
}

# This will reverse ${pidarray} and close all emulators
# This function needs a valid pidarray
function close_emulators() {
    for ((z=${#pidarray[*]}-1; z>-1; z--)); do
        kill -9 ${pidarray[z]}
        wait_forpid ${pidarray[z]}
    done
    unset pidarray
}

# Emulator currently running?
# If yes return PID from runcommand.sh
# due caller funtion
function check_emurun() {
    local RC_PID="$(pgrep -f -n runcommand.sh)"
    echo $RC_PID
}

# Emulationstation currently running?
# If yes return PID from ES binary
# due caller funtion
function check_esrun() {
    local ES_PID="$(pgrep -f "/opt/retropie/supplementary/.*/emulationstation([^.]|$)")"
    echo $ES_PID
}

# ---------------------------------------------------------------------------------------------
# ------------------------------------ E S - A C T I O N S ------------------------------------
# ---------------------------------------------------------------------------------------------

# This function can be called as several parameters
# if it is called empty then a poweroff will performed
# es-shutdown, will close ES and force an poweroff
# es-sysrestart, will close ES and force an reboot
# es-restart, will close ES and restart it
function es_action() {
    local ES_FILE="$1"
    [[ -z $ES_FILE ]] && ES_FILE="es-shutdown"
    ES_PID="$(check_esrun)"
    touch /tmp/$ES_FILE
    chown pi:pi /tmp/$ES_FILE
    kill $ES_PID
    wait_forpid $ES_PID
    [[ $ES_FILE == "es-restart" ]] || exit
}

# ---------------------------------------------------------------------------------------------
# ----------------------------------- S W I T C H T Y P E S -----------------------------------
# ---------------------------------------------------------------------------------------------


# ------------------------------------- N E S P I C A S E -------------------------------------

# NESPI CASE @Yahmez Mod
# https://retropie.org.uk/forum/topic/12424
# Defaults are:
# ResetSwitch GPIO 23, input, set pullup resistor!
# PowerSwitch GPIO 24, input, set pullup resistor!
# PowerOnControl GPIO 25, output, high

function NESPiCase() {
    #Set GPIOs
    [[ -n $1 ]] && GPIO_resetswitch=$1 || GPIO_resetswitch=23
    [[ -n $2 ]] && GPIO_powerswitch=$2 || GPIO_powerswitch=24
    [[ -n $3 ]] && GPIO_poweronctrl=$3 || GPIO_poweronctrl=25

    # Init: Use raspi-gpio to set pullup resistors!
    raspi-gpio set $GPIO_resetswitch ip pu
    raspi-gpio set $GPIO_powerswitch ip pu
    raspi-gpio set $GPIO_poweronctrl op dh

    until [[ $power == 0 ]]; do
        power=$(raspi-gpio get $GPIO_powerswitch | grep -c "level=1 fsel=0 func=INPUT")
        reset=$(raspi-gpio get $GPIO_resetswitch | grep -c "level=1 fsel=0 func=INPUT")

        if [[ $reset == 0 ]]; then
            RC_PID=$(check_emurun)
            [[ -z $RC_PID ]] && es_action es-restart
            [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
        fi

        sleep 1
    done

    # Initiate Shutdown per ES
    RC_PID=$(check_emurun)
    [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
    wait_forpid $RC_PID
    ES_PID=$(check_esrun)
    [[ -n $ES_PID ]] && es_action es-shutdown

    # If ES isn't running use regular shutoff
    sudo poweroff
}

# ------------------------------------- N E S P I P L U S -------------------------------------

# NESPI+ CASE
# http://www.retroflag.com
# Defaults are:
# ResetSwitch GPIO 2 (I2C, SDA), input, set pullup resistor!
# PowerSwitch GPIO 3 (I2C, SCL), input, set pullup resistor!
# PowerOnControl GPIO 4 (BCM 4), output, high
# LEDiodeControl GPIO 14 (BCM 14,TxD ), output, high, low (flash LED)

function NESPiPlus() {
    #Set GPIOs
    [[ -n $1 ]] && GPIO_resetswitch=$1 || GPIO_resetswitch=2
    [[ -n $2 ]] && GPIO_powerswitch=$2 || GPIO_powerswitch=3
    [[ -n $3 ]] && GPIO_poweronctrl=$3 || GPIO_poweronctrl=4
    [[ -n $4 ]] && GPIO_lediodectrl=$4 || GPIO_lediodectrl=14

    # Init: Use raspi-gpio to set pullup resistors!
    raspi-gpio set $GPIO_resetswitch ip pu
    raspi-gpio set $GPIO_powerswitch ip pu
    raspi-gpio set $GPIO_poweronctrl op dh
    raspi-gpio set $GPIO_lediodectrl op dh

    until [[ $power == 0 ]]; do
        power=$(raspi-gpio get $GPIO_powerswitch | grep -c "level=1 fsel=0 func=INPUT")
        reset=$(raspi-gpio get $GPIO_resetswitch | grep -c "level=1 fsel=0 func=INPUT")

        if [[ $reset == 0 ]]; then
            RC_PID=$(check_emurun)
            [[ -z $RC_PID ]] && es_action es-restart
            [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
        fi

        sleep 1
    done

    # Flashes LED 4 Times on PowerOff
    for iteration in 1 2 3 4; do
        raspi-gpio set $GPIO_lediodectrl op dl
        sleep 0.25
        raspi-gpio set $GPIO_lediodectrl op dh
        sleep 0.25
    done

    # PowerOff LED, Poweroff PowerCtrl
    raspi-gpio set $GPIO_lediodectrl op dl
#    raspi-gpio set $GPIO_poweronctrl op dl #Really have no clue what it does!

    # Initiate Shutdown per ES
    RC_PID=$(check_emurun)
    [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
    wait_forpid $RC_PID
    ES_PID=$(check_esrun)
    [[ -n $ES_PID ]] && es_action es-shutdown

    # If ES isn't running use regular shutoff
    sudo poweroff
}

# ------------------------------------- M A U S B E R R Y -------------------------------------

# Mausberry original script by mausershop
# Sudo command needed
# https://mausberry-circuits.myshopify.com/pages/setup
# Defaults are:
# PowerSwitch GPIO 23, input, export via bash
# PowerOnControl GPIO 24, output, export high via bash

function Mausberry() {

    #Set GPIOs
    #this is the GPIO pin connected to the lead on switch labeled OUT
    [[ -n $1 ]] && GPIO_powerswitch=$1 || GPIO_powerswitch=23
    #this is the GPIO pin connected to the lead on switch labeled IN
    [[ -n $2 ]] && GPIO_poweronctrl=$2 || GPIO_poweronctrl=24

    echo "$GPIO_powerswitch" > /sys/class/gpio/export
    echo "in" > /sys/class/gpio/gpio$GPIO_powerswitch/direction
    echo "$GPIO_poweronctrl" > /sys/class/gpio/export
    echo "out" > /sys/class/gpio/gpio$GPIO_poweronctrl/direction
    echo "1" > /sys/class/gpio/gpio$GPIO_poweronctrl/value

    while [ 1 = 1 ]; do
        power=$(cat /sys/class/gpio/gpio$GPIO_powerswitch/value)
            if [ $power = 0 ]; then
                sleep 1
            else
                RC_PID=$(check_emurun)
                [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
                wait_forpid $RC_PID
                ES_PID=$(check_esrun)
                [[ -n $ES_PID ]] && es_action es-shutdown

                # If ES isn't running use regular shutoff
                poweroff
            fi
    done
}

# ------------------------------------- O N O F F S H I M -------------------------------------

# Pimoroni SHIM ON OFF
# https://retropie.org.uk/forum/topic/15727
# Sudo command needed
# systemd shutoff needed! See forum post! This uses GPIO 4
# modified scripts by cyperghost
# Defaults are:
# PowerSwitch GPIO 17, input, export via bash
# PowerOnControl GPIO 4, ouput, high, setted low for shutdown!

function OnOffShim() {

    #Set GPIO
    #This is the GPIO pin connected to the lead on switch labeled BCM17:Status
    #PowerOnControl will be shutoff by systemd - read forum post!!
    [[ -n $1 ]] && GPIO_powerswitch=$1 || GPIO_powerswitch=17

    echo $GPIO_powerswitch > /sys/class/gpio/export
    echo in > /sys/class/gpio/gpio$GPIO_powerswitch/direction

    power=$(cat /sys/class/gpio/gpio$GPIO_powerswitch/value)

    # Here we can use Momentary and Fixed Switches
    [ $power = 0 ] && switchtype=1
    [ $power = 1 ] && switchtype=0

    until [ $power = $switchtype ]; do
        power=$(cat /sys/class/gpio/gpio$GPIO_powerswitch/value)
        sleep 1
    done

    # Initiate Shutdown per ES
    RC_PID=$(check_emurun)
    [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
    wait_forpid $RC_PID
    ES_PID=$(check_esrun)
    [[ -n $ES_PID ]] && es_action es-shutdown

    # If ES isn't running use regular shutoff
    poweroff
}

# ---------------------------------------------------------------------------------------------
# ------------------------------------------ M A I N ------------------------------------------
# ---------------------------------------------------------------------------------------------

case "${1^^}" in

    "--NESPICASE")
        # NESPiCase with mod by Yahmez
        # https://retropie.org.uk/forum/topic/12424
        # Defaults are:
        # ResetSwitch GPIO 23, input, set pullup resistor!
        # PowerSwitch GPIO 24, input, set pullup resistor!
        # PowerOnControl GPIO 25, output, high
        # Enter other BCM connections to call
        PACK_CHECK="$(dpkg -s raspi-gpio|grep -c installed)"
        [[ $PACK_CHECK == 0 ]] && echo "raspi-gpio not found! Install!" && exit
        NESPiCase 23 24 25
    ;;

    "--NESPI+")
        # NESPI+ CASE
        # http://www.retroflag.com
        # Defaults are:
        # ResetSwitch GPIO 2 (I2C, SDA), input, set pullup resistor!
        # PowerSwitch GPIO 3 (I2C, SCL), input, set pullup resistor!
        # PowerOnControl GPIO 4 (BCM 4), output, high
        # LEDiodeControl GPIO 14 (BCM 14,TxD ), output, high, low (flash LED)
	# You will loose I2C function due connections using SDA und SCL
        # Enter other BCM-connections to change behaviour
        PACK_CHECK="$(dpkg -s raspi-gpio|grep -c installed)"
        [[ $PACK_CHECK == 0 ]] && echo "raspi-gpio not found! Install!" && exit
        NESPiPlus 2 3 4 14
    ;;
    
    "--MAUSBERRY")
        # Mausberry original script by mausershop
        # Sudo command needed
        # https://mausberry-circuits.myshopify.com/pages/setup
        # Defaults are:
        # PowerSwitch GPIO 23, input, export via bash
        # PowerOnControl GPIO 24, output, export high via bash
        [[ $USER != "root" ]] && echo "Need root privileges... use sudo" && exit
        Mausberry 23 24
    ;;

    "--ONOFFSHIM")
        # Pimoroni SHIM ON OFF
        # https://retropie.org.uk/forum/topic/15727
        # Sudo command needed
        # systemd shutoff needed
        # modified scripts by cyperghost
        # Defaults are:
        # PowerSwitch GPIO 17, input, export via bash 
        # PowerOnControl GPIO 4, ouput, high, setted low for shutdown!
        [[ $USER != "root" ]] && echo "Need root privileges... use sudo" && exit
        OnOffShim 17 4
    ;;

    "--ES-PID")
        # Display ES PID to stout
        ES_PID=$(check_esrun)
        [[ -n $ES_PID ]] && echo $ES_PID || echo 0
    ;;

    "--RC-PID")
        # Display runcommand.sh PID to stout
        # This helps to detect emulator is running or not
        RC_PID=$(check_emurun)
        [[ -n $RC_PID ]] && echo $RC_PID || echo 0
    ;;

    "--ES-POWEROFF")
        # Closes running Emulators (if available)
        # Shutdown ES
        # Perform poweroff
        RC_PID=$(check_emurun)
        [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
        wait_forpid $RC_PID
        ES_PID=$(check_esrun)
        [[ -n $ES_PID ]] && es_action es-shutdown
    ;;

    "--ES-RESTART")
        # Closes running Emulators (if available)
        # Shutdown ES
        # Perform restart of ES only
        RC_PID=$(check_emurun)
        [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
        wait_forpid $RC_PID
        ES_PID=$(check_esrun)
        [[ -n $ES_PID ]] && es_action es-restart
    ;;

    "--ES-REBOOT")
        # Closes running Emulators (if available)
        # Shutdown ES
        # Perform system reboot
        RC_PID=$(check_emurun)
        [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
        wait_forpid $RC_PID
        ES_PID=$(check_esrun)
        [[ -n $ES_PID ]] && es_action es-sysrestart
    ;;

    "--CLOSEEMU")
        # Only closes running emulators
	RC_PID=$(check_emurun)
        [[ -n $RC_PID ]] && get_childpids $RC_PID && close_emulators
        wait_forpid $RC_PID
    ;;

    "--HELP"|*)
        echo "Help Screen:"
        echo -e "\nSystemcommands:\n"
        echo "--es-pid        Shows PID of ES, if not it shows 0"
        echo "--rc-pid        Shows PID of runcommand.sh - shows 0 if not found"
        echo "--closeemu      Tries to shutdown emulators, with cyperghost method"
        echo "--es-poweroff   Shutdown emulators (if running), Closes ES, performs poweroff"
        echo "--es-reboot     Shutdown emulators, Cloese ES, performs system reboot"
        echo "--es-restart    Shutdown emulators (if running), Restart ES"
        echo -e "\nSwitchDevices:\n"
        echo "--mausberry     If you have a Mausberry device, GPIO 23 24 used!"
        echo "--onoffshim     If you have the Pimoroni OnOff SHIM GPIO 17 and 4 used!"
        echo "--nespicase     If you use the NESPICASE with yahmez-mod GPIO 23 24 25 used!"
        echo "--nespi+        If you own a  NESPi+ Case, turn switch in ON position"
        echo -e "\nHints:\n"
        echo "Read this script and the function sections to get better information"
        echo "Please visit: https://retropie.org.uk/forum/ for questions // cyperghost 2018"
    ;;

esac
