#!/usr/bin/env python3
from gpiozero import Button, PWMLED
import os 
from signal import pause
from time import sleep

masterled = PWMLED(14, initial_value=1) #define led as pulse-width modultaion, use pin 14 as the positive power pin, and intial_value=1 means start at full power
#comment out below line if you want to keep the led on solid rather than "pulse"
masterled.blink(on_time=10, off_time=1, fade_in_time=5, fade_out_time=5, background=True) #make led "pulse" 10 sec solid on, 5 sec to fade out, 1 sec solid off, 5 sec to reach max brightness indefinitely, allow script to continue with background=True
#power = PWMLED(4) #not used for single power/reset button
#power.on() #not used for single power/reset button
masterBtn = Button(3, hold_time=2) #define button, use pin 3 as the positive pin, hold_time is how many seconds button must be "held" to trigger shutdown, must be equal to or less than sleep time in while loop below
#rebootBtn = Button(2) #not used for single power/reset button

#functions that handle button events
def shutdown():
  masterled.blink(on_time=.5, off_time=.5, fade_in_time=0, fade_out_time=0, n=4, background=False) #"slow" blink indicating shutdown is about to happen, n=number of blinks, background=False means wait for blinking to quit before moving on
  #print("shutdown") #was used for testing results
  os.system("sudo killall -w emulationstation ; sudo shutdown -h now") #added killall -w to wait for kill process to complete removed necessity of sleep 5s, removed && and replaced with ; to continue on with commands in sequence regardless of previous command end result

def reboot(): 
  masterled.blink(on_time=.2, off_time=.2, fade_in_time=0, fade_out_time=0, n=4, background=False) #"fast" blink indicating reboot is about to happen, n=number of blinks, background=False means wait for blinking to quit before moving on
  #print("reboot") #was used for testing results
  os.system("sudo killall -w emulationstation ; sudo reboot") #added killall -w to wait for kill process to complete removed necessity of sleep 5s, removed && and replaced with ; to continue on with commands in sequence regardless of previous command end result
  
while True:
	masterBtn.wait_for_press(timeout=None) #wait indefinitely for button to become active before continuing processing of while loop
	sleep(2) #must be equal to or greater than hold_time value in masterBtn definition above to give the user enough time to "hold" the button and tigger the is_held value to become True
	if masterBtn.is_held:
		shutdown() #button was held for at least the hold_time so shutdown
	else:
		reboot() #button was just pressed so reboot
  
#below states not used, handled by while loop
#rebootBtn.when_pressed = reboot
pause()
