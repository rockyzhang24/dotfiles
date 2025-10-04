#!/bin/bash

update() {
    IP="$(ipconfig getifaddr en0)"
    ICON="􀙈 "
    if [[ -n "$IP" ]]; then
        ICON="􀙇 "
        HOTSPOT=$(ipconfig getsummary en0 | grep sname | awk '{print $3}')
        if [[ $HOTSPOT != "" ]]; then
            ICON=" "
        fi
    fi
    sketchybar --set "$NAME" icon="$ICON"
}

mouse_clicked() {
    IP="$(ipconfig getifaddr en0)"
    if [[ -z "$IP" ]]; then
        return
    fi

    SSID="$(sudo "$HOME"/.config/bin/ssid)"

    popup_properties=(
        popup.height=20
        popup.align=center
        popup.background.border_width=1
        popup.background.corner_radius=10
        popup.background.shadow.drawing=off
    )

    sketchybar --set "$NAME" "${popup_properties[@]}"
    sketchybar --set "$NAME" popup.drawing=toggle

    # Add item showing SSID in popup
    sketchybar --add item wifi.ssid popup.wifi
    sketchybar --set wifi.ssid label="SSID: $SSID"

    # Add item showing IP address in popup
    sketchybar --add item wifi.ip popup.wifi
    sketchybar --set wifi.ip label="IP: $IP"
}

case "$SENDER" in
    "mouse.clicked") mouse_clicked
    ;;
    "wifi_change") update
    ;;
esac
