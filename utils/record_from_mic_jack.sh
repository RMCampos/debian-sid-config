#!/bin/bash

TIME="$1"

ffmpeg -f pulse -i alsa_input.pci-0000_00_1f.3.capture.0.0 -t $TIME -acodec libmp3lame -ab 192k voice-jack-$(date '+%Y-%m-%d-%H%M%S').mp3

