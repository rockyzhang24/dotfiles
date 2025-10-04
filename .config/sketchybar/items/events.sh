#!/bin/bash

events=(
    icon.font="$FONT:Regular:16.0"
    update_freq=30
    script="$PLUGIN_DIR/events.sh"
)

sketchybar --add item events right \
           --set events "${events[@]}" \
           --subscribe events mouse.clicked
