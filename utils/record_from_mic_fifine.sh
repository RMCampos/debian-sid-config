#!/bin/bash

TIME="$1"

ffmpeg -f pulse -i alsa_input.usb-3142_fifine_Headset-00.mono-fallback -t $TIME -acodec libmp3lame -ab 192k voice.mp3

