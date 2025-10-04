#!/bin/bash

calendar=(
    padding_right=15 # Make room for the screen recording indicator
    update_freq=30
    script="$PLUGIN_DIR/calendar.sh"
)

sketchybar --add item calendar right \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
