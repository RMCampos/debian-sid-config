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

# Export required environment variables
export XDG_CURRENT_DESKTOP=openbox
export XDG_SESSION_TYPE=x11
export DESKTOP_SESSION=openbox

eval "$(ssh-agent -s)"
SSH_ASKPASS=/usr/bin/ssh-askpass ssh-add ~/.ssh/id_ed25519 < /dev/null

# Start the Openbox window manager. For XFCE4 use: startxfce4
exec dbus-run-session -- openbox-session
