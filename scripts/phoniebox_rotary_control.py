#!/usr/bin/python3
# -*- coding: iso-8859-15 -*-
# 1.0.24

import RPi.GPIO as GPIO
from pyky040 import pyky040
import os, time
 
 
def readVolume():
    value = int(os.popen("sudo /home/pi/RPi-Jukebox-RFID/scripts/playout_controls.sh -c=getvolume").read())
    return int(value)
def rotaryChange(direction):
    volume_step = 5
    volume = readVolume()
    if direction == 1:
        os.system("sudo /home/pi/RPi-Jukebox-RFID/scripts/playout_controls.sh -c=setvolume -v="+str(min(100,max(0,volume + volume_step))))
    else:
        os.system("sudo /home/pi/RPi-Jukebox-RFID/scripts/playout_controls.sh -c=setvolume -v="+str(min(100,max(0,volume - volume_step))))
def switchPressed():
    os.system("sudo /home/pi/RPi-Jukebox-RFID/scripts/playout_controls.sh -c=mute")
 
 
if __name__ == "__main__":
 
    CLOCKPIN = 5
    DATAPIN = 6
    SWITCHPIN = 13
  
    
    GPIO.setmode(GPIO.BCM)
    
    pyky040 = pyky040(CLOCKPIN, DATAPIN, SWITCHPIN, rotaryChange, switchPressed)
 
    pyky040.start()
 
    try:
        while True:
            time.sleep(0.05)
    finally:
        pyky040.stop()
        GPIO.cleanup()