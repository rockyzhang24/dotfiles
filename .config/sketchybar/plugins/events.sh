#!/bin/bash

TODAY_EVENTS_CNT=$(icalBuddy -n -ea -b "" -iep title eventsToday | wc -l | xargs)
UPCOMING_EVENT_START_TIME=$(icalBuddy -n -ea -li 1 -npn -b "" -iep datetime eventsToday | cut -d'-' -f1 | xargs)

EVENTS_CNT_ICONS=("􁻧 " "􃌦 " "􃌧 " "􃌨 " "􃌩 " "􃌪 " "􃌫 " "􃌬 " "􃌭 " "􃌮 " "􃌯 " "􃌰 " "􃌱 " "􃌲 " "􃌳 " "􃌴 ")
EVENTS_CNT_ICON="${EVENTS_CNT_ICONS[$TODAY_EVENTS_CNT]}"

sketchybar --set "$NAME" icon="$EVENTS_CNT_ICON" label="$UPCOMING_EVENT_START_TIME"
