#!/bin/bash

#This script toggles the Screen on/off via SCREEN_KILL GPIO
#When script is called, state of Screen will be changed to opposite of current state
#Make sure the GPIOInit script is executed first to release the GPIO's
#Make sure you are in root before executing script

y=$(cat /sys/class/gpio/gpio218/value)

if [ $y == 1 ]
then
  echo 0 > /sys/class/gpio/gpio218/value
  echo "Enabling Screen"
  y=$(cat /sys/class/gpio/gpio218/value)
else
  echo 1 > /sys/class/gpio/gpio218/value
  echo "Disabling Screen"
  y=$(cat /sys/class/gpio/gpio218/value)
fi
