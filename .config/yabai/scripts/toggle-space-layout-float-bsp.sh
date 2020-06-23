#!/usr/bin/env bash

# Toggle the workspace (desktop) layout between float and bsp

read -r curType index <<< $(echo $(yabai -m query --spaces --space | jq '.type, .index'))
if [ $curType = '"bsp"' ]; then
  yabai -m space --layout float
  osascript -e "display notification \"Change the layout of workspace $index to float\" with title \"yabai\""
else
  yabai -m space --layout bsp
  osascript -e "display notification \"Change the layout of workspace $index to bsp\" with title \"yabai\""
fi
