#!/bin/bash

volume=(
    padding_left=10
    script="$PLUGIN_DIR/volume.sh"
)

status_bracket=(
    background.color="$BACKGROUND_1"
    background.border_color="$BACKGROUND_2"
)

sketchybar --add item volume right \
           --set volume "${volume[@]}" \
           --subscribe volume volume_change

sketchybar --add bracket status volume battery wifi \
           --set status "${status_bracket[@]}"
