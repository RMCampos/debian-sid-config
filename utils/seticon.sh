#!/bin/bash

xseticon -id $(xwininfo -name "general (Channel) - Accela - Slack" | grep 'Window id' | awk '{print $4}') /usr/share/pixmaps/slack.png

