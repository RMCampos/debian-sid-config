#!/bin/bash

echo 2 | sudo tee cat /sys/class/leds/dell\:\:kbd_backlight/brightness
