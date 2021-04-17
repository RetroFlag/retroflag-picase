import RPi.GPIO as GPIO
import os
import time
from multiprocessing import Process

#initialize pins
powerPin = 3 #pin 5
ledPin = 14 #TXD
resetPin = 2 #pin 13
powerenPin = 4 #pin 5

#initialize GPIO settings
def init():
	GPIO.setwarnings(False)
	GPIO.setmode(GPIO.BCM)
	GPIO.setup(powerPin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
	GPIO.setup(resetPin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
	GPIO.setup(ledPin, GPIO.OUT)
	GPIO.output(ledPin, GPIO.HIGH)
	GPIO.setup(powerenPin, GPIO.OUT)
	GPIO.output(powerenPin, GPIO.HIGH)

#waits for user to hold button up to 1 second before issuing poweroff command
def poweroff():
	while True:
		#self.assertEqual(GPIO.input(powerPin), GPIO.LOW)
		GPIO.wait_for_edge(powerPin, GPIO.FALLING)
		os.system("sleep 1s")
		os.system("poweroff")

#blinks the LED to signal button being pushed
def powerLedBlink():
	while True:
		GPIO.output(ledPin, GPIO.HIGH)
		#self.assertEqual(GPIO.input(powerPin), GPIO.LOW)
		GPIO.wait_for_edge(powerPin, GPIO.FALLING)
		start = time.time()
		while GPIO.input(powerPin) == GPIO.LOW:
			GPIO.output(ledPin, GPIO.LOW)
			time.sleep(0.2)
			GPIO.output(ledPin, GPIO.HIGH)
			time.sleep(0.2)

def resetLedBlink():
	while True:
		GPIO.output(ledPin, GPIO.HIGH)
		#self.assertEqual(GPIO.input(powerPin), GPIO.LOW)
		GPIO.wait_for_edge(resetPin, GPIO.FALLING)
		start = time.time()
		while GPIO.input(resetPin) == GPIO.LOW:
			GPIO.output(ledPin, GPIO.LOW)
			time.sleep(0.2)
			GPIO.output(ledPin, GPIO.HIGH)
			time.sleep(0.2)

#resets the pi
def reset():
	while True:
		#self.assertEqual(GPIO.input(resetPin), GPIO.LOW)
		GPIO.wait_for_edge(resetPin, GPIO.FALLING)
		os.system("sleep 1s")
		os.system("reboot")


if __name__ == "__main__":
	#initialize GPIO settings
	init()
	#create a multiprocessing.Process instance for each function to enable parallelism 
	powerProcess = Process(target = poweroff)
	powerProcess.start()
	resetProcess = Process(target = reset)
	resetProcess.start()
	powerLedProcess = Process(target = powerLedBlink)
	powerLedProcess.start()
	resetLedProcess = Process(target = resetLedBlink)
	resetLedProcess.start()

	powerProcess.join()
	resetProcess.join()
	powerLedProcess.join()
	resetLedProcess.join()
	
	GPIO.cleanup()
