#!/bin/bash

TIME="$1"

echo "Recording from Jack output for $TIME seconds"

ffmpeg -f pulse -i alsa_output.pci-0000_00_1f.3.analog-stereo.monitor -t $TIME -acodec libmp3lame -ab 192k output-jack-$(date '+%Y-%m-%d-%H%M%S').mp3

echo "Done"
