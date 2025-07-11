#!/bin/bash

# Wait a moment to ensure displays are detected
#sleep 2

# Get list of connected displays
CONNECTED=$(xrandr | grep " connected" | cut -d' ' -f1)

# Set external and internal output names 
EXTERNAL="HDMI-1"
INTERNAL="eDP-1"

xrandr --output "$INTERNAL" --primary --auto

