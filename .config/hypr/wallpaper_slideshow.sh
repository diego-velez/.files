#!/bin/bash

while true; do
	# Change the wallpaper every 5 minutes
	sleep 5m
	swww img "$(find "$HOME/Pictures/Super Ultrawide Wallpapers/" -type f | shuf -n 1)" --transition-type any --transition-fps 120
done

