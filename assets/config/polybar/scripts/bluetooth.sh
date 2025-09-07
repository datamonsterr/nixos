#!/usr/bin/env bash

# Function to show connected devices
show_connected_devices() {
    connected_devices=$(bluetoothctl devices Connected)
    
    if [ -z "$connected_devices" ]; then
        notify-send "Bluetooth" "No devices connected" -i bluetooth-active -t 3000
    else
        # Get device names and show them in notification
        device_list=""
        while IFS= read -r line; do
            if [ ! -z "$line" ]; then
                device_name=$(echo "$line" | cut -d' ' -f3-)
                device_list="$device_list• $device_name\n"
            fi
        done <<< "$connected_devices"
        
        notify-send "Connected Bluetooth Devices" "$device_list" -i bluetooth-active -t 5000
    fi
}

# Function to display bluetooth status
display_status() {
    if [ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ]; then
        echo "%{F#66ffffff}"
    else
        if [ $(echo info | bluetoothctl | grep 'Device' | wc -c) -eq 0 ]; then 
            echo ""
        else
            echo "%{F#ffffffff}"
        fi
    fi
}

# Handle different actions based on parameter
case "$1" in
    --show-devices)
        show_connected_devices
        ;;
    *)
        display_status
        ;;
esac
