#!/usr/bin/env python3
from gpiozero import Button, LED
import os 
from signal import pause

powerPin = 3 
resetPin = 2 
ledPin = 14 
powerenPin = 4 
hold = 1
led = LED(ledPin)
led.on()
power = LED(powerenPin)
power.on()

#functions that handle button events
def when_pressed():
  led.blink(.2,.2)
  os.system("sudo killall emulationstation && sleep 5s && sudo shutdown -h now")
def when_released():
  led.on()
def reboot(): 
  os.system("sudo killall emulationstation && sleep 5s && sudo reboot")
  
btn = Button(powerPin, hold_time=hold)
rebootBtn = Button(resetPin)
rebootBtn.when_pressed = reboot 
btn.when_pressed = when_pressed
btn.when_released = when_released
pause()
