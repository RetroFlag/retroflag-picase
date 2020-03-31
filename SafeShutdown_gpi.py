#!/usr/bin/env python3

import time
import subprocess
from signal import pause
from gpiozero import Button, LED

powerPin = 26
powerenPin = 27
hold = 1
power = LED(powerenPin)
power.on()

# functions that handle button events
def when_pressed():
    subprocess.run("sudo killall emulationstatio", shell=True)
    time.sleep(5)
    subprocess.run("sudo shutdown -h now", shell=True)


btn = Button(powerPin, hold_time=hold)
btn.when_pressed = when_pressed
pause()
