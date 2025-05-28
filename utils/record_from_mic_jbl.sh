#!/bin/bash

TIME="$1"

ffmpeg -f pulse -i alsa_input.usb-JBL_Quantum_800-00.mono-fallback -t $TIME -acodec libmp3lame -ab 192k voice.mp3

