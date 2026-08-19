#!/bin/bash

# Get list of connected displays
CONNECTED=$(xrandr | grep " connected" | cut -d' ' -f1)

# Set external and internal output names 
EXTERNAL_LEFT="HDMI-1"
EXTERNAL_RIGHT="DP-1"
INTERNAL="eDP-1"

if echo $CONNECTED | grep -q "$EXTERNAL_RIGHT"; then
    xrandr --output "$EXTERNAL_LEFT" --primary --mode 1920x1080 \
           --output "$EXTERNAL_RIGHT" --mode 1920x1080 --right-of "$EXTERNAL_LEFT" \
	   --output "$INTERNAL" --off
           #--output "$INTERNAL" --auto --below "$EXTERNAL_LEFT" --pos 960x1080
else
    xrandr --output "$INTERNAL" --primary --auto
fi

