#!/bin/bash
#This script toggles the Battery Charging on/off 
#Charging will immediately start once the AC adapater is plugged in UNLESS charging is disabled with this script
#Charging will be immediately disabled once the battery is full charge, however this script also gives the user software control over the charger
#When script is called, state of Charging will be changed to opposite of current state
#Make sure the GPIOInit script is executed first to release the GPIO's

x=$(cat /sys/class/gpio/gpio230/value)

if [ $x == 1 ]
then
  echo 0 > /sys/class/gpio/gpio230/value
  echo "Charging Disabled"
  x=$(cat /sys/class/gpio/gpio230/value)
else
  echo 1 > /sys/class/gpio/gpio230/value
  echo "Charging Enabled"
  x=$(cat /sys/class/gpio/gpio230/value)
fi
