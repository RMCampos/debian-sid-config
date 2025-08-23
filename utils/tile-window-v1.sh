#!/bin/bash

# Get screen dimensions
SCREEN_WIDTH=$(xwininfo -root | grep 'Width:' | awk '{print $2}')
SCREEN_HEIGHT=$(xwininfo -root | grep 'Height:' | awk '{print $2}')

# Account for fbpanel and margins
PANEL_HEIGHT=40
MARGIN=10
BOTTOM_EXTRA=10  # Additional space to remove from bottom

# Calculate available space (fbpanel is at top)
AVAILABLE_HEIGHT=$((SCREEN_HEIGHT - PANEL_HEIGHT - BOTTOM_EXTRA))
TOP_OFFSET=$((PANEL_HEIGHT + MARGIN))

# Calculate half dimensions of available space - with explicit parentheses
HALF_WIDTH=$(( (SCREEN_WIDTH - (3 * MARGIN)) / 2 ))
HALF_HEIGHT=$(( (AVAILABLE_HEIGHT - (3 * MARGIN)) / 2 ))

case $1 in
    "left")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$MARGIN,$TOP_OFFSET,$HALF_WIDTH,$((AVAILABLE_HEIGHT - (2 * MARGIN)))
        ;;
    "right")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$((MARGIN + HALF_WIDTH + MARGIN)),$TOP_OFFSET,$HALF_WIDTH,$((AVAILABLE_HEIGHT - (2 * MARGIN)))
        ;;
    "top")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$MARGIN,$TOP_OFFSET,$((SCREEN_WIDTH - (2 * MARGIN))),$HALF_HEIGHT
        ;;
    "bottom")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$MARGIN,$((TOP_OFFSET + HALF_HEIGHT + MARGIN)),$((SCREEN_WIDTH - (2 * MARGIN))),$HALF_HEIGHT
        ;;
    "topleft")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$MARGIN,$TOP_OFFSET,$HALF_WIDTH,$HALF_HEIGHT
        ;;
    "topright")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$((MARGIN + HALF_WIDTH + MARGIN)),$TOP_OFFSET,$HALF_WIDTH,$HALF_HEIGHT
        ;;
    "bottomleft")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$MARGIN,$((TOP_OFFSET + HALF_HEIGHT + MARGIN)),$HALF_WIDTH,$HALF_HEIGHT
        ;;
    "bottomright")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$((MARGIN + HALF_WIDTH + MARGIN)),$((TOP_OFFSET + HALF_HEIGHT + MARGIN)),$HALF_WIDTH,$HALF_HEIGHT
        ;;
    "fullscreen")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$MARGIN,$TOP_OFFSET,$((SCREEN_WIDTH - (2 * MARGIN))),$((AVAILABLE_HEIGHT - (2 * MARGIN)))
        ;;
esac
