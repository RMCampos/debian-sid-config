#!/bin/bash

#ffmpeg -f x11grab -s 1920x1080 -i :0.0+1920,0 output.mp4
ffmpeg -f x11grab -s 1920x1200 -i :0.0+0,1080 output.mp4
