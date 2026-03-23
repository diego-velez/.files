#!/bin/bash

FPS=120
WP_DIR="$HOME/Pictures/Wallpapers/"

while true; do
	# Change the wallpaper every 5 minutes
	sleep 5m
	awww img "$(find "$WP_DIR" -type f | shuf -n 1)" --transition-type any --transition-fps $FPS
done

