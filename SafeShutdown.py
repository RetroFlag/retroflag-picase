#!/usr/bin/env python3
# Safe Shutdown script for Retropie and Retroflag NesPi+ case
from gpiozero import Button, LED
import signal
import subprocess
import time
import os.path

powerPin = 3
resetPin = 2
ledPin = 14
powerenPin = 4
hold = 1
led = LED(ledPin)
led.on()
power = LED(powerenPin)
power.on()


def get_es_pid():
    try:
        output = int(subprocess.check_output(
            'pgrep -f "^/opt/retropie/supplementary/.*/emulationstation([^.]|$)"',
            shell=True))
    except subprocess.CalledProcessError:
        output = 0
    return output


def get_rc_pid():
    try:
        output = int(subprocess.check_output('pgrep -f "^bash .*/runcommand.sh"', shell=True))
    except subprocess.CalledProcessError:
        output = 0
    return output


def wait_for_close(process_pid):
    loop = True
    while loop:
        if os.path.exists('/proc/{}'.format(process_pid)):
            time.sleep(0.1)
        else:
            loop = False


def close_emulators(process_pid):
    try:
        subprocess.call('pkill -TERM -P {}'.format(process_pid), shell=True, timeout=5)
        wait_for_close(process_pid)
    except subprocess.TimeoutExpired:
        subprocess.call('pkill -KILL -P {}'.format(process_pid), shell=True)  # Force close if timeout expires
        wait_for_close(process_pid)


def exit_es(exit_command, es_pid):
    subprocess.call('touch /tmp/{}'.format(exit_command), shell=True)
    subprocess.call('chown pi:pi /tmp/{}'.format(exit_command), shell=True)
    subprocess.call('kill {}'.format(es_pid), shell=True)
    wait_for_close(es_pid)


# functions that handle button events
def power_switch_off():
    led.blink(.2, .2)
    es_pid = get_es_pid()

    if es_pid:
        rc_pid = get_rc_pid()
        if rc_pid:
            close_emulators(rc_pid)
        exit_es('es-shutdown', es_pid)
    else:
        subprocess.call('sudo shutdown -h now', shell=True)


def power_switch_on():
    led.on()


def reset_pressed():
    es_pid = get_es_pid()

    if es_pid:
        rc_pid = get_rc_pid()
        if rc_pid:
            close_emulators(rc_pid)
        exit_es('es-restart', es_pid)
    else:
        subprocess.call('sudo reboot', shell=True)


# Setup button handlers
btn = Button(powerPin, hold_time=hold)
rebootBtn = Button(resetPin)
rebootBtn.when_pressed = reset_pressed
btn.when_pressed = power_switch_off
btn.when_released = power_switch_on
signal.pause()
