#!/bin/bash

# Open kitty window in the current display instead of the display where the
# first kitty window was created.
# Refer to https://github.com/koekeishiya/yabai/issues/413

index=$(yabai -m query --displays --display | jq .index)

yabai -m signal --add event=window_created action=" \
  yabai -m signal --remove 'move_to_current_display' &&
  yabai -m window \$YABAI_WINDOW_ID --display $index &&
  yabai -m window --focus \$YABAI_WINDOW_ID" \
app="kitty" label="move_to_current_display"

/Applications/kitty.app/Contents/MacOS/kitty --single-instance -d ~
