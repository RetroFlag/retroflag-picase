#!/usr/bin/env python3
import sys

# Point out to the library location
sys.path.append('/storage/.kodi/addons/virtual.rpi-tools/lib/')
from gpiozero import Button, LED
import os
from signal import pause

# GPIO Settings
powerPin = 3
resetPin = 2
ledPin = 14
powerenPin = 4
hold = 1

# Main LED on
led = LED(ledPin)
led.on()

# Power LED on
powerLED = LED(powerenPin)
powerLED.on()

# Functions that handle button events
def pressed():
  led.blink(.2,.2)
  os.system("systemctl stop kodi && sleep 5s && shutdown -h now")
def released():
  led.on()
def reboot():
  os.system("systemctl stop kodi && sleep 5s && reboot")

# Define buttons
powerButton = Button(powerPin, hold_time=hold)
rebootButton = Button(resetPin)

# Map actions
rebootButton.when_pressed = reboot
powerButton.when_pressed = pressed
powerButton.when_released = released

# Keep waiting for a button signal
pause()

