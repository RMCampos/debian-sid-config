#!/bin/bash

# Function to get monitor info for the active window
get_monitor_info() {
    # Get active window ID
    ACTIVE_WINDOW=$(xdotool getactivewindow 2>/dev/null)
    
    if [ -z "$ACTIVE_WINDOW" ]; then
        echo "No active window found" >&2
        return 1
    fi
    
    # Get window position
    WINDOW_INFO=$(xwininfo -id "$ACTIVE_WINDOW" 2>/dev/null)
    if [ -z "$WINDOW_INFO" ]; then
        echo "Could not get window info" >&2
        return 1
    fi
    
    WINDOW_X=$(echo "$WINDOW_INFO" | grep 'Absolute upper-left X:' | awk '{print $4}')
    WINDOW_Y=$(echo "$WINDOW_INFO" | grep 'Absolute upper-left Y:' | awk '{print $4}')
    
    # Get monitor information using xrandr
    MONITOR_INFO=$(xrandr --listactivemonitors 2>/dev/null | grep -v "^Monitors:" | while read -r line; do
        # Parse monitor info: format is like "0: +*HDMI-1 1920/510x1080/287+0+0  HDMI-1"
        if [[ $line =~ ([0-9]+)/[0-9]+x([0-9]+)/[0-9]+\+([0-9]+)\+([0-9]+).*[[:space:]]([A-Za-z0-9-]+)$ ]]; then
            MON_WIDTH=${BASH_REMATCH[1]}
            MON_HEIGHT=${BASH_REMATCH[2]}
            MON_X=${BASH_REMATCH[3]}
            MON_Y=${BASH_REMATCH[4]}
            MON_NAME=${BASH_REMATCH[5]}
            
            # Check if window is within this monitor
            if [ "$WINDOW_X" -ge "$MON_X" ] && [ "$WINDOW_X" -lt $((MON_X + MON_WIDTH)) ] && \
               [ "$WINDOW_Y" -ge "$MON_Y" ] && [ "$WINDOW_Y" -lt $((MON_Y + MON_HEIGHT)) ]; then
                echo "$MON_WIDTH $MON_HEIGHT $MON_X $MON_Y $MON_NAME"
                return 0
            fi
        fi
    done)
    
    if [ -z "$MONITOR_INFO" ]; then
        # Fallback to primary monitor if detection fails
        PRIMARY_MONITOR=$(xrandr --listactivemonitors 2>/dev/null | grep -v "^Monitors:" | head -n1)
        if [[ $PRIMARY_MONITOR =~ ([0-9]+)/[0-9]+x([0-9]+)/[0-9]+\+([0-9]+)\+([0-9]+).*[[:space:]]([A-Za-z0-9-]+)$ ]]; then
            MON_WIDTH=${BASH_REMATCH[1]}
            MON_HEIGHT=${BASH_REMATCH[2]}
            MON_X=${BASH_REMATCH[3]}
            MON_Y=${BASH_REMATCH[4]}
            MON_NAME=${BASH_REMATCH[5]}
            echo "$MON_WIDTH $MON_HEIGHT $MON_X $MON_Y $MON_NAME"
            return 0
        fi
        
        # Final fallback to xwininfo root
        SCREEN_WIDTH=$(xwininfo -root | grep 'Width:' | awk '{print $2}')
        SCREEN_HEIGHT=$(xwininfo -root | grep 'Height:' | awk '{print $2}')
        echo "$SCREEN_WIDTH $SCREEN_HEIGHT 0 0 UNKNOWN"
        return 0
    fi
    
    echo "$MONITOR_INFO"
}

# Check if required tools are available
if ! command -v xdotool &> /dev/null; then
    echo "Error: xdotool is required but not installed" >&2
    echo "Install it with: sudo apt install xdotool" >&2
    exit 1
fi

if ! command -v xrandr &> /dev/null; then
    echo "Error: xrandr is required but not installed" >&2
    exit 1
fi

# Get monitor dimensions and position
MONITOR_INFO=$(get_monitor_info)
if [ $? -ne 0 ] || [ -z "$MONITOR_INFO" ]; then
    echo "Error: Could not determine monitor information" >&2
    exit 1
fi

# Parse monitor info
read -r SCREEN_WIDTH SCREEN_HEIGHT SCREEN_X SCREEN_Y MONITOR_NAME <<< "$MONITOR_INFO"

# Configure panel settings based on monitor name
# Add the monitor names that should have the panel here
#PANEL_MONITORS=("HDMI-1")  # Add your monitor names here
PANEL_MONITORS=("eDP-1") # Laptop by default
#TOTAL=$(find /sys/class/drm/card*/status -exec cat {} \; | grep -c "^connected$")
#if [ "$TOTAL" -gt 1 ]; then
#    PANEL_MONITORS=("HDMI-1")
#fi

PANEL_HEIGHT=40
MARGIN=10
BOTTOM_EXTRA=10  # Additional space to remove from bottom

# Check if current monitor should have panel height applied
APPLY_PANEL=false
for panel_monitor in "${PANEL_MONITORS[@]}"; do
    if [ "$MONITOR_NAME" = "$panel_monitor" ]; then
        APPLY_PANEL=true
        break
    fi
done

# Calculate available space
if [ "$APPLY_PANEL" = true ]; then
    AVAILABLE_HEIGHT=$((SCREEN_HEIGHT - PANEL_HEIGHT - BOTTOM_EXTRA))
    TOP_OFFSET=$((SCREEN_Y + PANEL_HEIGHT + MARGIN))
else
    AVAILABLE_HEIGHT=$((SCREEN_HEIGHT - BOTTOM_EXTRA))
    TOP_OFFSET=$((SCREEN_Y + MARGIN))
fi

# Calculate half dimensions of available space - with explicit parentheses
HALF_WIDTH=$(( (SCREEN_WIDTH - (3 * MARGIN)) / 2 ))
HALF_HEIGHT=$(( (AVAILABLE_HEIGHT - (3 * MARGIN)) / 2 ))

# Adjust positions to account for monitor offset
LEFT_X=$((SCREEN_X + MARGIN))
RIGHT_X=$((SCREEN_X + MARGIN + HALF_WIDTH + MARGIN))

case $1 in
    "left")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$LEFT_X,$TOP_OFFSET,$HALF_WIDTH,$((AVAILABLE_HEIGHT - (2 * MARGIN)))
        ;;
    "right")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$RIGHT_X,$TOP_OFFSET,$HALF_WIDTH,$((AVAILABLE_HEIGHT - (2 * MARGIN)))
        ;;
    "top")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$LEFT_X,$TOP_OFFSET,$((SCREEN_WIDTH - (2 * MARGIN))),$HALF_HEIGHT
        ;;
    "bottom")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$LEFT_X,$((TOP_OFFSET + HALF_HEIGHT + MARGIN)),$((SCREEN_WIDTH - (2 * MARGIN))),$HALF_HEIGHT
        ;;
    "topleft")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$LEFT_X,$TOP_OFFSET,$HALF_WIDTH,$HALF_HEIGHT
        ;;
    "topright")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$RIGHT_X,$TOP_OFFSET,$HALF_WIDTH,$HALF_HEIGHT
        ;;
    "bottomleft")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$LEFT_X,$((TOP_OFFSET + HALF_HEIGHT + MARGIN)),$HALF_WIDTH,$HALF_HEIGHT
        ;;
    "bottomright")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$RIGHT_X,$((TOP_OFFSET + HALF_HEIGHT + MARGIN)),$HALF_WIDTH,$HALF_HEIGHT
        ;;
    "fullscreen")
        wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
        wmctrl -r :ACTIVE: -e 0,$LEFT_X,$TOP_OFFSET,$((SCREEN_WIDTH - (2 * MARGIN))),$((AVAILABLE_HEIGHT - (2 * MARGIN)))
        ;;
    *)
        echo "Usage: $0 {left|right|top|bottom|topleft|topright|bottomleft|bottomright|fullscreen}"
        exit 1
        ;;
esac
