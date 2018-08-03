#!/bin/bash

#This script kills the system power to the LiDar, screen, and Spacely via the KILL_SIG_DELAY GPIO
#When script is called, all power, including Jetson TX2, will shutdown after 1 second delay
#Make sure the GPIOInit script is executed first to release the GPIO's
#Make sure you are in root before executing script

echo "Shutting Down.. Good-Bye"
echo 1 > /sys/class/gpio/gpio224/value


