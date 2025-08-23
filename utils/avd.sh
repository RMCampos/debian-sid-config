#!/bin/bash

CONNECTED=$(xrandr | grep " connected" | wc -l)

if [ "$CONNECTED" -gt 1 ]; then
	echo "Connecting to AVD using external AOC screen"
	/opt/freerdp-nightly/bin/xfreerdp3 \
		~/Accela/avd.rdpw \
		/floatbar \
		/gateway:type:arm \
		/monitors:1 \
		/f \
		/u:rcampos@accela.com \
		/auto-reconnect \
		/auto-reconnect-max-retries:3
		#/log-level:debug
else
	echo "Connecting to AVD using internal laptop screen"
	/opt/freerdp-nightly/bin/xfreerdp3 \
		~/Accela/avd.rdpw \
		/floatbar \
		/gateway:type:arm \
		/f \
		/u:rcampos@accela.com \
		/auto-reconnect \
		/auto-reconnect-max-retries:3
		#/log-level:debug
fi

