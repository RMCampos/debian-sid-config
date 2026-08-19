#!/bin/bash

export QT_QPA_PLATFORM=wayland
export XDG_CURRENT_DESKTOP=GNOME
export XDG_SESSION_TYPE=wayland

sh -c '/usr/bin/flameshot gui'

