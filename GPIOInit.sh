#!/bin/bash

echo tca9539 0x77 > /sys/bus/i2c/devices/i2c-1/new_device

echo 216 > /sys/class/gpio/export
echo 218 > /sys/class/gpio/export
echo 222 > /sys/class/gpio/export
echo 224 > /sys/class/gpio/export
echo 226 > /sys/class/gpio/export
echo 228 > /sys/class/gpio/export
echo 230 > /sys/class/gpio/export
echo 229 > /sys/class/gpio/export
echo 227 > /sys/class/gpio/export

echo out > /sys/class/gpio/gpio218/direction
echo out > /sys/class/gpio/gpio222/direction
echo out > /sys/class/gpio/gpio224/direction
echo out > /sys/class/gpio/gpio230/direction
echo out > /sys/class/gpio/gpio229/direction

cat /sys/kernel/debug/gpio
