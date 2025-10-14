#!/bin/bash

TODAY_EVENTS_CNT=$(icalBuddy -n -ea -b "" -iep title eventsToday | wc -l | xargs)
UPCOMING_EVENT_START_TIME=$(icalBuddy -n -ea -li 1 -npn -b "" -iep datetime eventsToday | cut -d'-' -f1 | xargs)

EVENTS_CNT_ICONS=("􁻧 " "􃌦 " "􃌧 " "􃌨 " "􃌩 " "􃌪 " "􃌫 " "􃌬 " "􃌭 " "􃌮 " "􃌯 " "􃌰 " "􃌱 " "􃌲 " "􃌳 " "􃌴 ")
EVENTS_CNT_ICON="${EVENTS_CNT_ICONS[$TODAY_EVENTS_CNT]}"

sketchybar --set "$NAME" icon="$EVENTS_CNT_ICON" label="$UPCOMING_EVENT_START_TIME"

# click to show the details of today's events in a popup menu
mouse_clicked() {
    TODAY_EVENTS="$(icalBuddy -n -ea eventsToday)"

    if [[ -z "$TODAY_EVENTS" ]]; then
        return
    fi

    popup_properties=(
        popup.height=20
        popup.align=center
        popup.background.border_width=1
        popup.background.corner_radius=10
        popup.background.shadow.drawing=off
    )

    sketchybar --set "$NAME" "${popup_properties[@]}"

    i=1
    echo "$TODAY_EVENTS" | while IFS= read -r line; do
        line="$(sed -E 's/^[[:space:]]+/↳ /' <<< "$line")"
        sketchybar --add item events.today_events_line_$i popup.events
        sketchybar --set events.today_events_line_$i label="$line"
        ((i++))
    done

    sketchybar --set "$NAME" popup.drawing=toggle
}

if [[ $SENDER == "mouse.clicked" ]]; then
    mouse_clicked
fi
