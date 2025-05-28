#!/bin/bash

TIME="$1"

ffmpeg -f pulse -i alsa_output.usb-3142_fifine_Headset-00.analog-stereo.monitor -t $TIME -ac 2 -ar 44100 output.mp3
