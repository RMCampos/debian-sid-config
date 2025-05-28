#!/bin/bash

TIME="$1"

ffmpeg -f pulse -i alsa_output.usb-JBL_Quantum_800-00.analog-stereo.monitor -t $TIME -ac 2 -ar 44100 output.mp3
