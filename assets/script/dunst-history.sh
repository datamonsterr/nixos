#!/bin/sh

# Dunst History Browser Script
# Shows notification history in a user-friendly format using rofi

# Get history and format it nicely
dunstctl history | jq -r '.data[0][] | "\(.appname.data): \(.summary.data)\n\(.body.data)\n---"' | rofi -dmenu -p "Notification History" -lines 10 -width 60
