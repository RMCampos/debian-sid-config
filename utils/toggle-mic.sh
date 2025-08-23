#!/bin/bash
current=$(amixer -c 0 cget name='Capture Source' | grep ': values=' | cut -d= -f2)

if [ "$current" = "0" ]; then
    amixer -c 0 cset name='Capture Source' 'Headset Mic'
    echo "Switched to headset microphone"
else
    amixer -c 0 cset name='Capture Source' 'Internal Mic'
    echo "Switched to internal microphone"
fi

