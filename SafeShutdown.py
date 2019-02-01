#!/usr/bin/env python3
from gpiozero import Button, LED
import os 
from signal import pause
from time import sleep

powerPin = 3 
#resetPin = 2 #not used for single power/reset button
ledPin = 14 
#powerenPin = 4 #not used for single power/reset button
led = LED(ledPin)
led.on() #turn led on upon boot
#comment out below line if you want to keep the led on solid rather than "pulse"
led.blink(on_time=300, off_time=150, background=True) #make led "pulse" 5 min on and 2.5 min off indefinitely allow script to continue with background=True
#power = LED(powerenPin) #not used for single power/reset button
#power.on() #not used for single power/reset button
btn = Button(powerPin, hold_time=2) #hold_time is how many seconds button must be "held" to trigger shutdown, must be equal to or less than sleep time in while loop below
#rebootBtn = Button(resetPin) #not used for single power/reset button

#functions that handle button events
def shutdown():
  led.blink(on_time=.5, off_time=.5, n=4, background=False) #"slow" blink indicating shutdown is about to happen, n=number of blinks, background=False means wait for blinking to quit before moving on
  led.on() #turn led back on solid after blinking if finished
  #print("shutdown") #was used for testing results
  os.system("sudo killall -w emulationstation ; sudo shutdown -h now") #added killall -w to wait for kill process to complete removed necessity of sleep 5s, removed && and replaced with ; to continue on with commands in sequence regardless of previous command end result

def reboot(): 
  led.blink(on_time=.2, off_time=.2, n=4, background=False) #"fast" blink indicating reboot is about to happen, n=number of blinks, background=False means wait for blinking to quit before moving on
  led.on() #turn led back on solid after blinking if finished
  #print("reboot") #was used for testing results
  os.system("sudo killall -w emulationstation ; sudo reboot") #added killall -w to wait for kill process to complete removed necessity of sleep 5s, removed && and replaced with ; to continue on with commands in sequence regardless of previous command end result
  
while True:
	btn.wait_for_press(timeout=None) #wait indefinitely for button to become active before continuing processing of while loop
	sleep(2) #must be equal to or greater than hold_time value in btn definition above to give the user enough time to "hold" the button and tigger the is_held value to become True
	if btn.is_held:
		shutdown() #button was held for at least the hold_time so shutdown
	else:
		reboot() #button was just pressed so reboot
  
#below states not used, handled by while loop
#btn.when_pressed = shutdown
#rebootBtn.when_pressed = reboot
pause()
