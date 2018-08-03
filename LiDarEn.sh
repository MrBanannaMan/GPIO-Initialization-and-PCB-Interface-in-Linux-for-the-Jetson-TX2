#!/bin/bash
#This script toggles the LiDar on/off 
#When script is called, state of LiDar will be changed to opposite of current state
#Make sure the GPIOInit script is executed first to release the GPIO's

x=$(cat /sys/class/gpio/gpio229/value)

if [ $x == 1 ]
then
  echo 0 > /sys/class/gpio/gpio229/value
  echo "Disabling LiDar"
  x=$(cat /sys/class/gpio/gpio229/value)
else
  echo 1 > /sys/class/gpio/gpio229/value
  echo "Enabling LiDar"
  x=$(cat /sys/class/gpio/gpio229/value)
fi
