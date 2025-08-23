#!/bin/bash

random_range() {
    local min=$1
    local max=$2

    # Validate input
    if [ $# -ne 2 ]; then
        echo "Usage: random_range <min> <max>" >&2
        return 1
    fi

    if [ $min -gt $max ]; then
        echo "Error: min ($min) cannot be greater than max ($max)" >&2
        return 1
    fi

    # Calculate range and generate random number
    local range=$((max - min + 1))
    local random_num=$((RANDOM % range + min))

    echo $random_num
}

number=$(random_range 1 5)
echo "Selected random wallpaper: $number"

if [ $number -eq 1 ]; then
	# Red Debian Logo wallpaper
	feh --no-fehbg --bg-scale /home/ricardo/Pictures/Combined/red-debian-1920-1080.png /home/ricardo/Pictures/Combined/red-debian-1920-1200.png /home/ricardo/Pictures/Combined/red-debian-1920-1080.png
elif [ $number -eq 2 ]; then
	# Rocks, lake and mountains wallpaper
	feh --no-fehbg --bg-scale /home/ricardo/Pictures/Combined/wallhaven-21ew5x-1080.jpg /home/ricardo/Pictures/Combined/wallhaven-21ew5x-1200.jpg /home/ricardo/Pictures/Combined/wallhaven-21ew5x-1080.jpg
elif [ $number -eq 3 ]; then
	# Man clinbing with moon behing
	feh --no-fehbg --bg-scale /home/ricardo/Pictures/Combined/wallhaven-lymvrl-1080.jpg /home/ricardo/Pictures/Combined/wallhaven-lymvrl-1200.jpg /home/ricardo/Pictures/Combined/wallhaven-lymvrl-1080.jpg
elif [ $number -eq 4 ]; then
	# White snow lake
	feh --no-fehbg --bg-scale /home/ricardo/Pictures/Combined/wallhaven-mldor9-1080.jpg /home/ricardo/Pictures/Combined/wallhaven-mldor9-1200.jpg /home/ricardo/Pictures/Combined/wallhaven-mldor9-1080.jpg
elif [ $number -eq 5 ]; then
	# Red Japanese place
	feh --no-fehbg --bg-scale /home/ricardo/Pictures/Combined/wallhaven-qr6v8l-1080.jpg /home/ricardo/Pictures/Combined/wallhaven-qr6v8l-1200.jpg /home/ricardo/Pictures/Combined/wallhaven-qr6v8l-1080.jpg
fi

