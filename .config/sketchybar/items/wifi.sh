#!/bin/bash

wifi=(
    label.font="$FONT:Bold:10.0"
    script="$PLUGIN_DIR/wifi.sh"
)

sketchybar --add item wifi right \
           --set wifi "${wifi[@]}" \
           --subscribe wifi wifi_change
