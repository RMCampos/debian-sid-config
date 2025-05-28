#!/bin/bash

BRIGHTNESS_PATH="/sys/class/backlight/intel_backlight"
MAX=$(cat "$BRIGHTNESS_PATH/max_brightness")
CURRENT=$(cat "$BRIGHTNESS_PATH/brightness")

# Helper: clamp value between 0 and MAX
clamp() {
  local val=$1
  if [ "$val" -lt 0 ]; then
    echo 0
  elif [ "$val" -gt "$MAX" ]; then
    echo "$MAX"
  else
    echo "$val"
  fi
}

# Exit if no argument
if [ -z "$1" ]; then
  echo "Usage: $0 [+/-PERCENT | PERCENT]"
  exit 1
fi

INPUT="$1"

# Relative change (starts with + or -)
if [[ "$INPUT" == +* || "$INPUT" == -* ]]; then
  DELTA_PERCENT=${INPUT}
  STEP=$(( MAX * ${DELTA_PERCENT} / 100 ))
  NEW=$(( CURRENT + STEP ))
  NEW=$(clamp "$NEW")
else
  # Absolute set
  TARGET_PERCENT=${INPUT}
  NEW=$(( MAX * TARGET_PERCENT / 100 ))
  NEW=$(clamp "$NEW")
fi

# Apply brightness
echo "$NEW" | sudo tee "$BRIGHTNESS_PATH/brightness" > /dev/null
