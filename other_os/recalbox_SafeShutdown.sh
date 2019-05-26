#!/bin/bash
#
# Script for RecalBox to terminate every emulator instance
# Control script to give feedback about state of EmulationStation and
# active EMULATORS
# by cyperghost aka crcerror // 18.03.2019
# 

# Get all childpids from calling process
function getcpid() {
local cpids="$(pgrep -P $1)"
    for cpid in $cpids; do
        pidarray+=($cpid)
        getcpid $cpid
    done
}

# Get a sleep while process is active in background
function smart_wait() {
    local PID=$1
    [[ -z $PID ]] && return 1
    while [[ -e /proc/$PID ]]; do
        sleep 0.25
    done
}

# Emulator currently running?
function check_emurun() {
    local RC_PID="$(pgrep -f -n emulatorlauncher)"
    echo $RC_PID
}

# Emulationstation currently running?
function check_esrun() {
    local ES_PID="$(pgrep -f -n emulationstation)"
    echo $ES_PID
}

# ---- MAINS ----

case ${1,,} in
    --restart)
        echo "Restarting now ..."
        /etc/init.d/S31emulationstation restart 
    ;;

    --espid)
        # Display ES PID to stdout
        ES_PID=$(check_esrun)
        [[ -n $ES_PID ]] && echo $ES_PID || echo 0
    ;;

    --emupid)
        # This helps to detect emulator is running or not
        RC_PID=$(check_emurun)
        [[ -n $RC_PID ]] && echo $RC_PID || echo 0
    ;;

    --emukill|--shutdown)
        RC_PID=$(check_emurun)
        if [[ -n $RC_PID ]]; then
            getcpid $RC_PID
            for ((z=${#pidarray[*]}-1; z>-1; z--)); do
                kill ${pidarray[z]}
                smart_wait ${pidarray[z]}
            done
            unset pidarray
        fi
        
        ES_PID=$(check_esrun)
        if [[ "${1,,}" == "--shutdown" && -n $ES_PID ]]; then
            smart_wait $(pgrep -f emulatorlauncher)
            sleep 2
            kill $ES_PID         
            smart_wait $ES_PID
            shutdown -h now
        fi
    ;;

    --kodi)
        /etc/init.d/S31emulationstation stop
        /recalbox/scripts/kodilauncher.sh &
        wait $!
        exitcode=$?
        [[ $exitcode -eq 0 ]] && /etc/init.d/S31emulationstation start
        [[ $exitcode -eq 10 ]] && shutdown -r now
        [[ $exitcode -eq 11 ]] && shutdown -h now
    ;;

    *)
        echo -e "Please parse parameters to this script! \n
                  --restart will RESTART EmulationStation only
                  --kodi will startup KODI Media Center
                  --shutdown will SHUTDOWN whole system
                  --emukill to exit any running EMULATORS
                  --espid to check if EmulationStation is currently active
                  --emupid to check if an Emulator is running"
    ;;

esac
