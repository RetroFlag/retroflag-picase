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
# v0.42 Added NESPi+ fan control shutoff // thx cloudlink & gollumer
# v0.50 Added support for generic Button connected to any GPIO
# v0.51 NESPi+ fan control is 100% working - place a script to systemd service like Pimoroni OnOffShim
# v0.70 Parameter control, added extended help pages
# v0.75 Parameter --CLOSEEMU is called --ES-CLOSEEMU (both can be used for backward compatibility!)
# v0.80 Introduced --ES-SYSTEMD parameter, now the ES gracefully shutdown service by @meleu can be used
# v0.85 Code cleanup, added watchdog to kill only persistent emulators with sig -9, added more helppages

# Up to now 5 devices are supported!
#
# NESPIcase! Install raspi-gpio via "sudo apt install raspi-gpio", no sudo needed, reset, poweroff
# NESPIplus! Install raspi-gpio via "sudo apt install raspi-gpio", no sudo needed, reset, poweroff
# GenericBt! Install raspi-gpio via "sudo apt install raspi-gpio", no sudo needed, poweroff
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
# I added watchdog to kill emu-processes with sig 9 level after 2.0s
# If emulator PID ist active after 5.0s, return to call
# I will prevent ES from being termed with level 9 for sake of safe shutdown
function wait_forpid() {
    local PID=$1
    [[ -z $PID ]] && return 1

    local RC_PID=$(check_emurun)
    local watchdog=0

    while [[ -e /proc/$PID ]]; do
        sleep 0.10
        watchdog=$((watchdog+1))
        [[ $watchdog -eq 30 ]] && [[ $RC_PID -gt 0 ]] && kill -9 $PID
        [[ $watchdog -eq 50 ]] && [[ $RC_PID -gt 0 ]] && return
    done
}

# This will reverse ${pidarray} and close all emulators
# This function needs a valid pidarray
function close_emulators() {
    for ((z=${#pidarray[*]}-1; z>-1; z--)); do
        kill ${pidarray[z]}
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

# Helppage

function help--ES-SYSTEMCALLS () {

    echo -e "Multi Switch ES-Commands: Detailed Help\n"
    echo "--ES-PID:      This parameter obtains the Process ID of the running ES binary."
    echo "               If running ES instance isn't found, then 0 is returned."
    echo "               You may directly use this ID to quit ES's running instance!"
    echo "--RC-PID:      This parameter obtains the PID of runcommand.sh only!"
    echo "               You may find this usefull to detect if emulators are running."
    echo
    echo "--ES-CLOSEEMU: This parameter tries to close all running emulators. The code"
    echo "               is trying to determinine all child PIDs of runcommand.sh"
    echo "--ES-SYSTEMD:  This is special. It will just terminate ES binary and ES will not"
    echo "               initiate any further system actions like shutdown or reboots!"
    echo "               This is a hook to use with ES-gracfully-shutdown service by meleu"
    echo
    echo "--ES-RESTART:  This just restarts ES-binary and keeps Multi Switch active in BG"
    echo "--ES-REBOOT:   This reboots the whole system, this is initiated by ES itself!"
    echo "--ES-POWEROFF: This shutdowns the system, also initiated by ES itself!"
    echo
    echo "All this commands can be used to control the behaviour of EmulationStation with"
    echo "external written programms. Multi Switch just provides a kind of interface for"
    echo "simple control. So you are not stick to bash, feel free to take python!"
    echo "I made a quick coding example to read PIDs of ES. Please respect my work!"
    echo "It can be found here: https://retropie.org.uk/forum/topic/17506"

}

# This function can be called with several parameters
# ES itself evaluates entries in /tmp directory
# es-shutdown, will close ES and force an poweroff
# es-sysrestart, will close ES and force an reboot
# es-restart, will close ES and restart it

function es_action() {

    local CASE_SEL="$1"
    case "$CASE_SEL" in

        "--ES-CLOSEEMU")
            # Closes running Emulators (if available)
            RC_PID=$(check_emurun)
            if [[ -n $RC_PID ]]; then
                get_childpids $RC_PID
                close_emulators
                wait_forpid $RC_PID
            fi
        ;;

        "--ES-REBOOT")
            # Initiate system reboot and give control back to ES
            ES_PID=$(check_esrun)
            if [[ -n $ES_PID ]]; then
                touch /tmp/es-sysrestart
                chown pi:pi /tmp/es-sysrestart
                kill $ES_PID
                wait_forpid $ES_PID
                exit
            fi
        ;;

        "--ES-POWEROFF")
            # Initiate system shutdown and give control back to ES
            ES_PID=$(check_esrun)
            if [[ -n $ES_PID ]]; then
                touch /tmp/es-shutdown
                chown pi:pi /tmp/es-shutdown
                kill $ES_PID
                wait_forpid $ES_PID
                exit
            fi
        ;;

        "--ES-RESTART")
            # Initiate restart of ES
            ES_PID=$(check_esrun)
            if [[ -n $ES_PID ]]; then
                touch /tmp/es-restart
                chown pi:pi /tmp/es-restart
                kill $ES_PID
                wait_forpid $ES_PID
            fi
        ;;

        "--ES-SYSTEMD")
            # Just terminate ES binary and let other services do their job
            ES_PID=$(check_esrun)
            if [[ -n $ES_PID ]]; then
                kill $ES_PID
                wait_forpid $ES_PID
                exit
            fi
        ;;

        *)
            echo "Please parse argument to function es_action() - Error!" >&2
        ;;

    esac

}

# ---------------------------------------------------------------------------------------------
# ----------------------------------- S W I T C H T Y P E S -----------------------------------
# ---------------------------------------------------------------------------------------------


# ------------------------------------- N E S P I C A S E -------------------------------------


# Help Page
# NESPi Case @YAHMEZ Shutdown Mod

function help--NESPICASE() {

    echo -e "NESPi case: Detailed help\n"
    echo "For building advicefor SAFE SHUTDOWN MOD by @YAHMEZ visit:" 
    echo "   https://retropie.org.uk/forum/topic/12424"
    echo
    echo "We need a binary (raspi-gpio) to set internal pullup resistor!"
    echo "   raspi-gpio set PIN# ip pu will do this job"
    echo
    echo "This works with any user, no root rights needed"
    echo "Install raspi-gpio with: sudo apt install raspi-gpio"
    echo
    echo "Default Settings:"
    echo "    ResetSwitch GPIO 23, input, set pullup resistor!"
    echo "    PowerSwitch GPIO 24, input, set pullup resistor!"
    echo "    PowerOnControl GPIO 25, output, high, power on control!"
    echo
    echo "Commandline Parameters:"
    echo "    ./multi_switch.sh --NESPICASE powerbtn= resetbtn= powerctrl="
    echo "    ./multi_switch.sh --NESPICASE powerctrl=17 sets Power On Ctrl to GPIO17"
    echo
    echo "For questions regarding the hardware modding please use the link above"
    echo "Attention: You need a power device: POLOLU PO2811 or PO2810 to make this work!"
    echo "For questions to this script visit retropie forum! -- cyperghost"

}

# NESPI CASE @Yahmez Mod
# https://retropie.org.uk/forum/topic/12424
# Button script by cyperghost

function NESPiCase() {

    #Set GPIOs
    [[ -z $1 || $1 == "-1" ]] && GPIO_resetswitch=23 || GPIO_resetswitch=$1
    [[ -z $2 || $2 == "-1" ]] && GPIO_powerswitch=24 || GPIO_powerswitch=$2
    [[ -z $3 || $3 == "-1" ]] && GPIO_poweronctrl=25 || GPIO_poweronctrl=$3


    # Init: Use raspi-gpio to set pullup resistors!
    raspi-gpio set $GPIO_resetswitch ip pu
    raspi-gpio set $GPIO_powerswitch ip pu
    raspi-gpio set $GPIO_poweronctrl op dh

    until [[ $power == 0 ]]; do
        power=$(raspi-gpio get $GPIO_powerswitch | grep -c "level=1 fsel=0 func=INPUT")
        reset=$(raspi-gpio get $GPIO_resetswitch | grep -c "level=1 fsel=0 func=INPUT")

        if [[ $reset == 0 ]]; then
            RC_PID=$(check_emurun)
            [[ -z $RC_PID ]] && es_action --ES-RESTART
            [[ -n $RC_PID ]] && es_action --ES-CLOSEEMU
        fi

        sleep 1
    done

    # Initiate Shutdown per ES
    es_action --ES-CLOSEEMU
    es_action --ES-POWEROFF

    # If ES isn't running use regular shutoff
    sudo poweroff

}

# ------------------------------------- N E S P I P L U S -------------------------------------

# Help Page
# NESPi+ Case

function help--NESPI+() {

    echo "NESPi+ case: Detailed help"
    echo
    echo "For wiring shematics take a look at: http://www.retroflag.com"
    echo "With a small binary raspi-gpio we set internal pullup resistor!"
    echo "raspi-gpio set PIN# ip pu will do this job"
    echo "This works with any user, no root rights needed"
    echo "Install raspi-gpio with: sudo apt install raspi-gpio"
    echo
    echo "Default Settings:"
    echo "    ResetSwitch GPIO 2 (I2C, SDA), input, set pullup resistor!"
    echo "    PowerSwitch GPIO 3 (I2C, SCL), input, set pullup resistor!"
    echo "    PowerOnControl GPIO 4 (BCM 4), output, high, power on control!"
    echo "    LEDiodeControl GPIO 14 (BCM 14,TxD ), output, high, low (flash LED)"
    echo
    echo "Command line Parameters:"
    echo "    ./multi_switch.sh --nespi+ powerbtn= resetbtn= ledctrl= powerctrl="
    echo
    echo "For complete shutoff a systemd call must be added. Install service with:"
    echo "  1. cd /lib/systemd/system-shutdown"
    echo "  2. sudo wget https://raw.githubusercontent.com/crcerror/ES-generic-shutdown/master/shutdown_fan"
    echo "  3. sudo chmod +x shutdown_fan"
    echo
    echo "Additional Info: https://retropie.org.uk/forum/topic/17639"

}

# NesPI+ Case
# Get it from: http://www.retroflag.com
# Button Script by cyperghost

function NESPiPlus() {

    #Set GPIOs
    [[ -z $1 || $1 == "-1" ]] && GPIO_resetswitch=2 || GPIO_resetswitch=$1
    [[ -z $2 || $2 == "-1" ]] && GPIO_powerswitch=3 || GPIO_powerswitch=$2
    [[ -z $3 || $3 == "-1" ]] && GPIO_poweronctrl=4 || GPIO_poweronctrl=$3
    [[ -z $4 || $4 == "-1" ]] && GPIO_lediodectrl=14 || GPIO_lediodectrl=$4

    # Init: Use raspi-gpio to set pullup resistors!
    raspi-gpio set $GPIO_resetswitch ip pu
    raspi-gpio set $GPIO_powerswitch ip pu
    raspi-gpio set $GPIO_poweronctrl op pn dh
    raspi-gpio set $GPIO_lediodectrl op dh

    until [[ $power == 0 ]]; do
        power=$(raspi-gpio get $GPIO_powerswitch | grep -c "level=1 fsel=0 func=INPUT")
        reset=$(raspi-gpio get $GPIO_resetswitch | grep -c "level=1 fsel=0 func=INPUT")

        if [[ $reset == 0 ]]; then
            RC_PID=$(check_emurun)
            [[ -z $RC_PID ]] && es_action --ES-RESTART
            [[ -n $RC_PID ]] && es_action --ES-CLOSEEMU
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

    # PowerOff LED
    # Poweroff PowerCtrl needs script placed to /lib/systemd/system-shutdown/
    raspi-gpio set $GPIO_lediodectrl op dl

    # Initiate Shutdown per ES
    es_action --ES-CLOSEEMU
    es_action --ES-POWEROFF

    # If ES isn't running use regular shutoff
    sudo poweroff

}

# --------------------------------------- G E N E R I C ---------------------------------------

# Help Page
# Generic Button

function help--GENERIC() {

    echo "Generic button: Detailed help"
    echo
    echo "For wiring shematics take a look at:"
    echo "https://scribles.net/adding-power-switch-on-raspberry-pi/ and many others!"
    echo
    echo "Just connect any latching switch or momentary button to your desired GPIO"
    echo "and to common ground. This can be done by using GPIO3 and use neighbour-pin"
    echo "This is physical PIN 5 and 6 on Pie header"
    echo
    echo "With a small binary raspi-gpio we set internal pullup resistor!"
    echo "raspi-gpio set PIN# ip pu will do this job"
    echo
    echo "This works with any user, no root rights needed"
    echo "Install raspi-gpio with: sudo apt install raspi-gpio"
    echo
    echo "Default settings:"
    echo "     PowerSwitch GPIO 3 (I2C, SCL), input, set pullup resistor!"
    echo
    echo "GPIO3 provides shutdown and let the Raspberry be awakend from deepsleep"
    echo
    echo "Command line Parameters:"
    echo "    ./multi_switch.sh --generic powerbtn="
    echo "    ./multi_switch.sh --generic powerbtn=23 use GPIO 23 for powerswitch!"

}

# GENERIC Button
# This is the simplest way to integrate powerdown/repower ability to your Raspberry
# Button script by cyperghost
# For wiring shematics take a look at: https://scribles.net/adding-power-switch-on-raspberry-pi

function GenericButton() {

    # Set GPIO
    [[ -z $1 || $1 == "-1" ]] && GPIO_powerswitch=3 || GPIO_powerswitch=$1

    # Init: Use raspi-gpio to set pullup resistors!
    raspi-gpio set $GPIO_powerswitch ip pu

    #Precheck if you use momentary or latching switch
    power=$(raspi-gpio get $GPIO_powerswitch | grep -c "level=1 fsel=0 func=INPUT")
    [[ $power == "0" ]] && switchtype="1" # This is a latching switch
    [[ $power == "1" ]] && switchtype="0" # This is a momentary push button


    until [[ $power == $switchtype ]]; do
        power=$(raspi-gpio get $GPIO_powerswitch | grep -c "level=1 fsel=0 func=INPUT")
        sleep 1
    done

    # Initiate Shutdown per ES
    es_action --ES-CLOSEEMU
    es_action --ES-POWEROFF

    # If ES isn't running use regular shutoff
    sudo poweroff

}

# ------------------------------------- M A U S B E R R Y -------------------------------------

# Help page
# Mausberry Switch

function help--MAUSBERRY() {

    echo "Mausberry switch: Detailed help"
    echo
    echo "For wiring shematics and how to buy please visit:"
    echo "https://mausberry-circuits.myshopify.com/"
    echo
    echo "Defaults Settings:"
    echo "    Labeled OUT: PowerSwitch GPIO 23, input, export via bash"
    echo "    Labeled IN:  PowerOnControl GPIO 24, output, export high via bash"
    echo
    echo "This scrip must be called with ROOT right, so use sudo command to start script!"
    echo
    echo "Attention: This is needed only for momentary push buttons! Latching switches do"
    echo "           work. If you perform a software shutdown before, be sure to initiate"
    echo "           ouput signal to the button. Otherwise the mausberry switch will stuck"
    echo
    echo "I made a little hack with a diode to make this work! Connect the diode to a GPIO"
    echo "to Mausberry Button ground und set a script to /lib/systemd/system-shutdown"
    echo "I made description here: https://retropie.org.uk/forum/topic/13361 in 57th post"
    echo
    echo "Please respect the work of others - cyperghost"  

}

# Mausberry original script by mausershop
# Sudo command needed
# https://mausberry-circuits.myshopify.com/pages/setup

function Mausberry() {

    #Set GPIOs
    #this is the GPIO pin connected to the lead on switch labeled OUT
    [[ -z $1 || $1 == "-1" ]] && GPIO_powerswitch=23 || GPIO_powerswitch=$1
    #this is the GPIO pin connected to the lead on switch labeled IN
    [[ -z $2 || $2 == "-1" ]] && GPIO_poweronctrl=24 || GPIO_poweronctrl=$2

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
                es_action --ES-CLOSEEMU
                es_action --ES-POWEROFF

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
    [[ -z $1 || $1 == "-1" ]] && GPIO_powerswitch=17 || GPIO_powerswitch=$1

    echo $GPIO_powerswitch > /sys/class/gpio/export
    echo in > /sys/class/gpio/gpio$GPIO_powerswitch/direction

    power=$(cat /sys/class/gpio/gpio$GPIO_powerswitch/value)

    # Here we can use Momentary and Fixed Switches
    [[ $power == "0" ]] && switchtype="1"
    [[ $power == "1" ]] && switchtype="0"

    until [[ $power == $switchtype ]]; do
        power=$(cat /sys/class/gpio/gpio$GPIO_powerswitch/value)
        sleep 1
    done

    # Initiate Shutdown per ES
    es_action --ES-CLOSEEMU
    es_action --ES-POWEROFF

    # If ES isn't running use regular shutoff
    poweroff

}

# ---------------------------------------------------------------------------------------------
# ------------------------------------------ M A I N ------------------------------------------
# ---------------------------------------------------------------------------------------------

# -------------------------------- M A I N - F U N C T I O N ----------------------------------

# Parameter processing
# only integers from 0-99 are valid!
# Unvalid entries are assigned as -1
function cli_parameter() {
    unset call
    local PARAMETER=$@
    for i in ${PARAMETER[@]}; do
        value="${CLI#*$i}"
        [[ $value != $PARAMETER ]] && value="${value%% *}" || value="-1"
        [[ $value =~ ^[0-9]{1,2}$ ]] || value="-1"
        call+=("$value")
    done
}

# Check if raspi-gpio ist installed
function pack_check() {
    local PACK_CHECK="$(dpkg -s $1|grep -c installed)"
    if [[ $PACK_CHECK == 0 ]]; then
        echo "raspi-gpio not found! Install!"
        exit
    fi
}

# -------------------------------- M A I N - P R O G R A M M ----------------------------------

CASE_SEL="${1^^}"
[[ ${2^^} == "HELP" ]] && HELP_ITEM="$CASE_SEL" && CASE_SEL="help"
shift
CLI="${*,,}"

case "$CASE_SEL" in

    "--NESPICASE")
        # NESPiCase with mod by Yahmez
        # https://retropie.org.uk/forum/topic/12424
        # Defaults are:
        # ResetSwitch GPIO 23, input, set pullup resistor!
        # PowerSwitch GPIO 24, input, set pullup resistor!
        # PowerOnControl GPIO 25, output, high
        # Enter other BCM connections to call
        #
        pack_check raspi-gpio
        cli_parameter resetbtn= powerbtn= powerctrl=
        NESPiCase ${call[@]}
    ;;

    "--NESPI+")
        # NESPI+ CASE
        # http://www.retroflag.com
        # Defaults are:
        # ResetSwitch GPIO 2 (I2C, SDA), input, set pullup resistor!
        # PowerSwitch GPIO 3 (I2C, SCL), input, set pullup resistor!
        # PowerOnControl GPIO 4 (BCM 4), output, high, fan control!
        # LEDiodeControl GPIO 14 (BCM 14,TxD ), output, high, low (flash LED)
	# You will loose I2C function due connections using SDA und SCL
        # Enter other BCM-connections to change behaviour
        #
        pack_check raspi-gpio
        cli_parameter resetbtn= powerbtn= powerctrl= ledctrl=
        NESPiPlus ${call[@]}
    ;;

    "--GENERIC")
        # Generic button
        # https://scribles.net/adding-power-switch-on-raspberry-pi/ and many others!
        # Just connect any button latching or momentary to your desired GPIO and to common ground
        # With raspi-gpio we set internal pullup resistor!
        # script by cyperghost
        # This works with any user, no sudo needed
        # Install raspi-gpio with: sudo apt install raspi-gpio
        # Defaults are:
        # PowerSwitch GPIO 3 (I2C, SCL), input, set pullup resistor!
        # GPIO3 provides shutdown and let the Raspberry be awakend from deepsleep
        #
        pack_check raspi-gpio
        cli_parameter powerbtn=
        GenericButton ${call[@]}
    ;;

    "--MAUSBERRY")
        # Mausberry original script by mausershop
        # Sudo command needed
        # https://mausberry-circuits.myshopify.com/pages/setup
        # Defaults are:
        # PowerSwitch GPIO 23, input, export via bash
        # PowerOnControl GPIO 24, output, export high via bash
        #
        [[ $USER != "root" ]] && echo "Need root privileges... use sudo" && exit
        cli_parameter powerbtn= powerctrl=
        Mausberry ${call[@]}
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
        #
        [[ $USER != "root" ]] && echo "Need root privileges... use sudo" && exit
        cli_parameter powerbtn= powerctrl=
        OnOffShim ${call[@]}
    ;;

    "--ES-PID")
        # Display ES PID to stdout
        ES_PID=$(check_esrun)
        [[ -n $ES_PID ]] && echo $ES_PID || echo 0
    ;;

    "--RC-PID")
        # Display runcommand.sh PID to stdout
        # This helps to detect emulator is running or not
        RC_PID=$(check_emurun)
        [[ -n $RC_PID ]] && echo $RC_PID || echo 0
    ;;

    "--ES-POWEROFF")
        # Closes running Emulators (if available)
        # Closes ES
        # Perform poweroff
        es_action --ES-CLOSEEMU
        es_action --ES-POWEROFF
    ;;

    "--ES-RESTART")
        # Closes running Emulators (if available)
        # Closes ES
        # Perform restart of ES only
        es_action --ES-CLOSEEMU
        es_action --ES-RESTART
    ;;

    "--ES-REBOOT")
        # Closes running Emulators (if available)
        # Closes ES
        # Perform system reboot
        es_action --ES-CLOSEEMU
        es_action --ES-REBOOT
    ;;

    "--SYSTEMD"|"--ES-SYSTEMD")
        # Closes running Emulators (if available)
        # Closes ES
        # Wait for service to finish
        es_action --ES-CLOSEEMU
        es_action --ES-SYSTEMD
    ;;

    "--CLOSEEMU"|"--ES-CLOSEEMU")
        # Only closes running emulators
        es_action --ES-CLOSEEMU
    ;;

    "help")
        # Callfunction with name help--DEVICE, help--MAUSBERRY for ex.
        # This call suspresses errors and redirects stderr to /dev/null
        [[ -z ${HELP_ITEM%--ES-*} || $HELP_ITEM == "--RC-PID" ]] && HELP_ITEM="--ES-SYSTEMCALLS"
        help$HELP_ITEM 2>/dev/null
        exit 1
    ;;

     "-H"|"--HELP")
        echo "Help Screen:"
        echo -e "\nSystemcommands:"
        echo "--es-pid        Shows PID of ES, if ES is not found it outputs 0"
        echo "--rc-pid        Shows PID of runcommand.sh, if not found it outputs 0"
        echo "--es-closeemu   Tries to shutdown emulators with cyperghosts method"
        echo "--es-systemd    This can invoke the shutdown service by meleu"
        echo "--es-poweroff   Shutdown emulators (if running), Closes ES, performs poweroff"
        echo "--es-reboot     Shutdown emulators, Closes ES, performs system reboot"
        echo "--es-restart    Shutdown emulators (if running), Restart ES"
        echo -e "\nSwitchDevices:"
        echo "--mausberry     If you have a Mausberry device, GPIO 23 24 used!"
        echo "--onoffshim     If you have the Pimoroni OnOff SHIM GPIO 17 and 4 used!"
        echo "--nespicase     If you use the NESPICASE with yahmez-mod GPIO 23 24 25 used!"
        echo "--nespi+        If you own a  NESPi+ Case, turn switch in ON position"
        echo "--generic       Connect latching or push button to GPIO and ground (def: GPIO3)"
        echo -e "\nHints:"
        echo "For detailed description of each command use: --command help"
        echo "Please visit: https://retropie.org.uk/forum/ for questions // cyperghost 2018"
    ;;

    *)
        echo "--COMMAND help for detailed help pages!"
        echo "--help or -h for overview of options available!"
    ;;

esac
