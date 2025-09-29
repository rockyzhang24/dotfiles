#!/bin/bash

SSID="$(sudo "$HOME"/.config/bin/ssid)"
IP="$(ipconfig getifaddr en0)"

SSID_LEN=${#SSID}
if (( SSID_LEN > 10 )); then
    SSID="${SSID:0:5}...${SSID: -5}"
fi

ICON="󰖪 "
if [[ -n "$IP" ]]; then
    ICON="󰖩 "
    HOTSPOT=$(ipconfig getsummary en0 | grep sname | awk '{print $3}')
    if [[ $HOTSPOT != "" ]]; then
        ICON=" "
    fi
fi

sketchybar --set "$NAME" icon="$ICON" label="$SSID"
