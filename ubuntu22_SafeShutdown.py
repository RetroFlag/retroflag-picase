from gpiozero import Button, LED
import os 
from signal import pause
import subprocess

#initialize pins
powerBtnPin = 3
resetBtnPin = 2
ledPin = 14
powerPin = 4

led = LED(ledPin)
led.on()

power = LED(powerPin)
power.on()

#functions that handle button events
def poweroff():
    led.blink(.2,.2)
    print("sudo shutdown -h now")
    #os.system("sudo shutdown -h now")

def reboot():
    led.blink(.2,.2)
    print("sudo reboot")
 
powerBtn = Button(powerBtnPin)
rebootBtn = Button(resetBtnPin)

powerBtn.when_pressed = poweroff
rebootBtn.when_pressed = reboot

pause()
