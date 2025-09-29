#!/bin/bash

ram=(
    icon="􀫦 "
    padding_right=10
    update_freq=4
    script="$PLUGIN_DIR/ram.sh"
)

sketchybar --add item ram right \
           --set ram "${ram[@]}"
