#!/bin/bash
# Toggle laptop display on/off

LAPTOP="eDP-1"

# Check if laptop display is enabled
if swaymsg -t get_outputs | jq -e ".[] | select(.name == \"$LAPTOP\" and .active == true)" > /dev/null 2>&1; then
    swaymsg output "$LAPTOP" disable
else
    swaymsg output "$LAPTOP" enable
fi
