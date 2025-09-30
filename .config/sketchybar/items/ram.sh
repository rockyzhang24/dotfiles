#!/bin/bash

ram=(
    icon="􀫦 "
    icon.font="$FONT:Regular:16.0"
    update_freq=4
    script="$PLUGIN_DIR/ram.sh"
)

sketchybar --add item ram right \
           --set ram "${ram[@]}"
