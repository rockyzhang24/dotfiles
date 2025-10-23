#!/bin/bash

if [[ -z $INFO ]]; then
    INFO=$(osascript -e "output volume of (get volume settings)")
fi

sketchybar --set "$NAME" label="$INFO%"
