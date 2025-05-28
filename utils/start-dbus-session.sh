#!/bin/bash

# Only run if no DBUS session is active
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  eval "$(dbus-launch --sh-syntax --exit-with-session)" >> ~/.dbus-env
fi
