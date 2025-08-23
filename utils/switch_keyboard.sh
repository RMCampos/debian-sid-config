#!/bin/bash

# Keyboard Layout Switcher
# Usage: ./switch_keyboard.sh [us|br]

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (use sudo)" 
   exit 1
fi

# Check if parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [us|br]"
    echo "  us - Switch to US layout"
    echo "  br - Switch to Brazilian ABNT2 layout"
    exit 1
fi

LAYOUT=$1

# File paths
KEYBOARD_FILE="/etc/default/keyboard"
XORG_FILE="/etc/X11/xorg.conf.d/00-keyboard.conf"

# Create backup of current files
echo "Creating backups..."
cp "$KEYBOARD_FILE" "${KEYBOARD_FILE}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$XORG_FILE" "${XORG_FILE}.bak.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true

# Ensure X11 directory exists
mkdir -p /etc/X11/xorg.conf.d

case $LAYOUT in
    "us")
        echo "Switching to US keyboard layout..."
        
        # Update /etc/default/keyboard for US
        cat > "$KEYBOARD_FILE" << 'EOF'
XKBMODEL="pc104"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS="compose:rctrl"
BACKSPACE="guess"
EOF
        
        # Update /etc/X11/xorg.conf.d/00-keyboard.conf for US
        cat > "$XORG_FILE" << 'EOF'
Section "InputClass"
	Identifier "system-keyboard"
	MatchIsKeyboard "on"
	Option "XkbModel" "pc104"
	Option "XkbLayout" "us"
	Option "XkbVariant" ""
	Option "XkbOptions" "compose:rctrl"
EndSection
EOF
        echo "Successfully switched to US layout"
        ;;
        
    "br")
        echo "Switching to Brazilian ABNT2 keyboard layout..."
        
        # Update /etc/default/keyboard for BR
        cat > "$KEYBOARD_FILE" << 'EOF'
XKBMODEL="pc104"
XKBLAYOUT="br"
XKBVARIANT="abnt2"
XKBOPTIONS="compose:rctrl"
BACKSPACE="guess"
EOF
        
        # Update /etc/X11/xorg.conf.d/00-keyboard.conf for BR
        cat > "$XORG_FILE" << 'EOF'
Section "InputClass"
	Identifier "system-keyboard"
	MatchIsKeyboard "on"
	Option "XkbModel" "abnt2"
	Option "XkbLayout" "br"
	Option "XkbVariant" ""
	Option "XkbOptions" ""
EndSection
EOF
        echo "Successfully switched to Brazilian ABNT2 layout"
        ;;
        
    *)
        echo "Error: Invalid layout '$LAYOUT'. Use 'us' or 'br'"
        exit 1
        ;;
esac

echo ""
echo "Configuration files updated successfully!"
echo "To apply the changes:"
echo "1. For immediate effect in current session: setxkbmap $LAYOUT"
echo "2. For permanent effect: restart your system or X server"
echo ""
echo "Backup files created with timestamp suffix in case you need to revert."

