#!/bin/bash

battery=(
    icon.font="$FONT:Regular:15.0"
    updates=on
    update_freq=120
    script="$PLUGIN_DIR/battery.sh"
)

sketchybar --add item battery right \
           --set battery "${battery[@]}" \
           --subscribe battery power_source_change system_woke
