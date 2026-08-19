#!/bin/bash

# GNOME Wayland Window Tiling Script
# Alternative approach without Shell.Eval

# Function to get current monitor info using various methods
get_monitor_info() {
    # Method 1: Try wlr-randr (works with some Wayland compositors)
    if command -v wlr-randr &> /dev/null; then
        WLR_OUTPUT=$(wlr-randr 2>/dev/null | grep -E "^[A-Za-z]" | head -n1)
        if [[ $WLR_OUTPUT =~ ([0-9]+)x([0-9]+) ]]; then
            WIDTH=${BASH_REMATCH[1]}
            HEIGHT=${BASH_REMATCH[2]}
            echo "{\"width\":$WIDTH,\"height\":$HEIGHT,\"x\":0,\"y\":0,\"index\":0,\"scale\":1}"
            return 0
        fi
    fi
    
    # Method 2: Try GNOME's mutter settings
    if command -v gsettings &> /dev/null; then
        # Get the current mode from mutter
        CURRENT_MODE=$(gsettings get org.gnome.desktop.interface scaling-factor 2>/dev/null)
        # Try to get resolution from display settings
        MONITORS_XML="$HOME/.config/monitors.xml"
        if [ -f "$MONITORS_XML" ]; then
            # Parse monitors.xml for resolution
            WIDTH=$(grep -o '<width>[0-9]*</width>' "$MONITORS_XML" | head -n1 | grep -o '[0-9]*')
            HEIGHT=$(grep -o '<height>[0-9]*</height>' "$MONITORS_XML" | head -n1 | grep -o '[0-9]*')
            if [ -n "$WIDTH" ] && [ -n "$HEIGHT" ]; then
                echo "{\"width\":$WIDTH,\"height\":$HEIGHT,\"x\":0,\"y\":0,\"index\":0,\"scale\":1}"
                return 0
            fi
        fi
    fi
    
    # Method 3: Check /sys/class/drm for display info
    for card_dir in /sys/class/drm/card*-*; do
        if [ -d "$card_dir" ]; then
            STATUS_FILE="$card_dir/status"
            if [ -f "$STATUS_FILE" ] && grep -q "connected" "$STATUS_FILE" 2>/dev/null; then
                # This is connected, try to find mode info
                MODES_FILE="$card_dir/modes"
                if [ -f "$MODES_FILE" ]; then
                    MODE=$(head -n1 "$MODES_FILE" 2>/dev/null)
                    if [[ $MODE =~ ([0-9]+)x([0-9]+) ]]; then
                        WIDTH=${BASH_REMATCH[1]}
                        HEIGHT=${BASH_REMATCH[2]}
                        echo "{\"width\":$WIDTH,\"height\":$HEIGHT,\"x\":0,\"y\":0,\"index\":0,\"scale\":1}"
                        return 0
                    fi
                fi
            fi
        fi
    done
    
    # Method 4: Try xrandr through XWayland (if available)
    if command -v xrandr &> /dev/null && [ -n "$DISPLAY" ]; then
        XRANDR_OUTPUT=$(xrandr 2>/dev/null | grep -E "connected primary|connected.*[0-9]+x[0-9]+" | head -n1)
        if [[ $XRANDR_OUTPUT =~ ([0-9]+)x([0-9]+) ]]; then
            WIDTH=${BASH_REMATCH[1]}
            HEIGHT=${BASH_REMATCH[2]}
            echo "{\"width\":$WIDTH,\"height\":$HEIGHT,\"x\":0,\"y\":0,\"index\":0,\"scale\":1}"
            return 0
        fi
    fi
    
    # Method 5: Parse GNOME Shell extensions that might provide info
    if [ -d "$HOME/.local/share/gnome-shell/extensions" ]; then
        # Look for any extension that might have cached display info
        for ext_dir in "$HOME/.local/share/gnome-shell/extensions"/*; do
            if [ -f "$ext_dir/stylesheet.css" ]; then
                # Some extensions store display dimensions in their CSS
                DIMS=$(grep -o '[0-9]\+px' "$ext_dir/stylesheet.css" 2>/dev/null | head -n2)
                if [ -n "$DIMS" ]; then
                    # This is a bit of a long shot, but worth trying
                    break
                fi
            fi
        done
    fi
    
    # Method 6: Fallback - assume common resolution
    echo "Warning: Using fallback resolution 1920x1080" >&2
    echo "{\"width\":1920,\"height\":1080,\"x\":0,\"y\":0,\"index\":0,\"scale\":1}"
    return 0
}

# Function to manipulate windows using keyboard shortcuts
tile_window_with_shortcuts() {
    local position=$1
    
    # Check if ydotool is available for input simulation
    if command -v ydotool &> /dev/null; then
        case $position in
            "left")
                ydotool key 125:1 65:1 65:0 125:0  # Super+Left
                ;;
            "right")
                ydotool key 125:1 67:1 67:0 125:0  # Super+Right
                ;;
            "top")
                ydotool key 125:1 65:1 65:0 125:0  # Super+Up (maximize)
                ;;
            *)
                echo "Position $position not supported with keyboard shortcuts"
                return 1
                ;;
        esac
        return 0
    fi
    
    # If ydotool not available, try using GNOME's built-in shortcuts via gsettings
    echo "Warning: ydotool not available, using basic tiling" >&2
    return 1
}

# Function to use GNOME's built-in tiling when possible
use_gnome_tiling() {
    local position=$1
    
    case $position in
        "left"|"right")
            tile_window_with_shortcuts "$position"
            return $?
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to calculate and apply window geometry manually
manual_window_positioning() {
    local position=$1
    
    # Get monitor info
    MONITOR_JSON=$(get_monitor_info)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Parse monitor info
    SCREEN_WIDTH=$(echo "$MONITOR_JSON" | grep -o '"width":[0-9]*' | cut -d: -f2)
    SCREEN_HEIGHT=$(echo "$MONITOR_JSON" | grep -o '"height":[0-9]*' | cut -d: -f2)
    SCREEN_X=$(echo "$MONITOR_JSON" | grep -o '"x":[0-9]*' | cut -d: -f2)
    SCREEN_Y=$(echo "$MONITOR_JSON" | grep -o '"y":[0-9]*' | cut -d: -f2)
    
    # Default values if parsing fails
    SCREEN_WIDTH=${SCREEN_WIDTH:-1920}
    SCREEN_HEIGHT=${SCREEN_HEIGHT:-1080}
    SCREEN_X=${SCREEN_X:-0}
    SCREEN_Y=${SCREEN_Y:-0}
    
    # Configuration
    MARGIN=10
    PANEL_HEIGHT=40
    BOTTOM_EXTRA=10
    
    # Calculate available space (assume panel exists)
    AVAILABLE_HEIGHT=$((SCREEN_HEIGHT - PANEL_HEIGHT - BOTTOM_EXTRA))
    TOP_OFFSET=$((SCREEN_Y + PANEL_HEIGHT + MARGIN))
    
    # Calculate dimensions
    HALF_WIDTH=$(( (SCREEN_WIDTH - (3 * MARGIN)) / 2 ))
    HALF_HEIGHT=$(( (AVAILABLE_HEIGHT - (3 * MARGIN)) / 2 ))
    
    # Calculate positions
    LEFT_X=$((SCREEN_X + MARGIN))
    RIGHT_X=$((SCREEN_X + MARGIN + HALF_WIDTH + MARGIN))
    
    # For manual positioning, we'll create a small helper script that uses available tools
    echo "Monitor: ${SCREEN_WIDTH}x${SCREEN_HEIGHT} at ${SCREEN_X},${SCREEN_Y}"
    echo "Would tile to position: $position"
    echo "Note: Manual window positioning requires additional tools or extensions"
    
    case $position in
        "left")
            echo "Position: ${LEFT_X},${TOP_OFFSET} Size: ${HALF_WIDTH}x$((AVAILABLE_HEIGHT - (2 * MARGIN)))"
            ;;
        "right")
            echo "Position: ${RIGHT_X},${TOP_OFFSET} Size: ${HALF_WIDTH}x$((AVAILABLE_HEIGHT - (2 * MARGIN)))"
            ;;
        "top")
            echo "Position: ${LEFT_X},${TOP_OFFSET} Size: $((SCREEN_WIDTH - (2 * MARGIN)))x${HALF_HEIGHT}"
            ;;
        "bottom")
            echo "Position: ${LEFT_X},$((TOP_OFFSET + HALF_HEIGHT + MARGIN)) Size: $((SCREEN_WIDTH - (2 * MARGIN)))x${HALF_HEIGHT}"
            ;;
        *)
            echo "Position calculations available for: $position"
            ;;
    esac
    
    return 0
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 {left|right|top|bottom|topleft|topright|bottomleft|bottomright|fullscreen}"
    exit 1
fi

POSITION=$1

# Check available methods and try them in order of preference
echo "Attempting to tile window to: $POSITION"

# Method 1: Try GNOME's native tiling (works for left/right)
if use_gnome_tiling "$POSITION"; then
    echo "Used GNOME native tiling"
    exit 0
fi

# Method 2: Manual positioning (currently just shows calculations)
if manual_window_positioning "$POSITION"; then
    echo "Manual positioning mode - see output above"
    exit 0
fi

echo "Error: Could not tile window"
exit 1
