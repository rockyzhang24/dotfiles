#!/bin/bash

if [[ -z $INFO ]]; then
    INFO=$(osascript -e "output volume of (get volume settings)")
fi

OUTPUT_NAME=$(SwitchAudioSource -c)

case $OUTPUT_NAME in
    *'AirPods Pro'*)
        ICON="􀪷 "
        ;;
    *'AirPods Max'*)
        ICON="􀺹 "
        ;;
    *)
        ICON=" "
esac

sketchybar --set "$NAME" icon="$ICON" label="$INFO%"
