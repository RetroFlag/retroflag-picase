#!/usr/bin/env python3

import time
import subprocess
from signal import pause
from gpiozero import Button, LED

powerPin = 3
resetPin = 2
ledPin = 14
powerenPin = 4
hold = 1
led = LED(ledPin)
led.on()
power = LED(powerenPin)
power.on()

# functions that handle button events
def when_pressed():
    led.blink(0.2, 0.2)
    subprocess.run("sudo killall emulationstation", shell=True)
    time.pause(5)
    subprocess.run("sudo shutdown -h now", shell=True)


def when_released():
    led.on()


def reboot():
    subprocess.run("sudo killall emulationstation", shell=True)
    time.pause(5)
    subprocess.run("sudo reboot", shell=True)


btn = Button(powerPin, hold_time=hold)
rebootBtn = Button(resetPin)
rebootBtn.when_pressed = reboot
btn.when_pressed = when_pressed
btn.when_released = when_released
pause()
