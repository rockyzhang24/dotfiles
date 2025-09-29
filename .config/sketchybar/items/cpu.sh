#!/bin/bash

# Ref:
# https://github.com/FelixKratz/dotfiles/blob/7cef83fc577bb8853c01d6aae66fdc6625feb761/.config/sketchybar/helper/cpu.h

cpu_top=(
    label.font="$FONT:SemiBold:7"
    label=CPU
    icon.drawing=off
    width=0
    padding_right=10
    y_offset=6
)

cpu_percent=(
    label.font="$FONT:Heavy:12"
    label=CPU
    y_offset=-4
    padding_right=10
    width=50
    icon.drawing=off
    update_freq=2
    mach_helper="$HELPER"
)

cpu_sys=(
    width=0
    graph.color="$RED"
    graph.fill_color="$RED"
    label.drawing=off
    icon.drawing=off
    background.height=30
    background.drawing=on
    background.color="$TRANSPARENT"
)

cpu_user=(
    graph.color="$BLUE"
    label.drawing=off
    icon.drawing=off
    background.height=30
    background.drawing=on
    background.color="$TRANSPARENT"
)

sketchybar --add item cpu.top right \
           --set cpu.top "${cpu_top[@]}" \
           \
           --add item cpu.percent right \
           --set cpu.percent "${cpu_percent[@]}" \
           \
           --add graph cpu.sys right 75 \
           --set cpu.sys "${cpu_sys[@]}" \
           \
           --add graph cpu.user right 75 \
           --set cpu.user "${cpu_user[@]}"
