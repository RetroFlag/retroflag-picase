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

    --emukill)
        RC_PID=$(check_emurun)
        if [[ -n $RC_PID ]]; then
            getcpid $RC_PID
            for ((z=${#pidarray[*]}-1; z>-1; z--)); do
                kill ${pidarray[z]}
                smart_wait ${pidarray[z]}
            done
            unset pidarray
        fi
    ;;

    *)
        echo -e "Please parse parameters to this script! \n
                  --restart will RESTART EmulationStation only
                  --shutdown will SHUTDOWN whole system (not implented now!)
                  --emukill to exit any running EMULATORS
                  --espid to check if EmulationStation is currently active
                  --emupid to check if an Emulator is running"
    ;;

esac
