from gpiozero import Button, LED
import os 
from signal import pause
import subprocess

#initialize pins
powerBtnPin = 3
resetBtnPin = 2
ledPin = 14

led = LED(ledPin)
led.on()

#functions that handle button events
def poweroff():
    led.blink(.2,.2)
    os.system("shutdown -h now")

def reboot():
    led.blink(.2,.2)
    os.system("reboot")
 
powerBtn = Button(powerBtnPin)
rebootBtn = Button(resetBtnPin)

powerBtn.when_pressed = poweroff
rebootBtn.when_pressed = reboot

pause()
