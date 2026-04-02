#!/bin/bash

# Configuration
INTERVAL="20m" # 20 minutes in seconds
MESSAGE="Look at something 20 feet away for 20 seconds!"

while true; do
    sleep $INTERVAL
    # Sends a desktop notification
    notify-send "20-20-20 Rule" "$MESSAGE" \
        --icon=face-glasses \
        --urgency=normal \
        --app-name="Eye-Health Monitor"
done
