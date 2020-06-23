#!/usr/bin/env bash

# (I). Initialize the temp folder
# (II). Calculate the coordinates of the top left corner, the width and the height of
# a window and store them into a temp file which will be used when switching a window
# from tiling to floating.

# ======== Explanation for (II): ==========

# If a window is open and tiling initially, when I want to switch it to floating, I want
# to place it at the CENTER of the display where this window is at currently. The position
# of the window becoming floating is based on the coordinates of its top left corner, and
# the size of the window depends on its width and height. So we should calculate out the
# coordinates, the width and the height of this window.

# (1). Calculate the width and the height
# Based on the less one between the width and the height of the display (i.e., whether the
# monitor is horizontal or vertical), the width or the height of the window will be 10/12
# of the basis, and the width will be 1.5 larger than the height.
# For example, if the width is less (i.e., the monitor is horinzontal), we should first
# determine the width of the window. We divided the width of the display into 12 rows and
# let the width of the window occupy [1] to [10], totally 10 middle rows. Then dividing the
# width by 1.5 will get the height. Same for the situation where the height is less.

# (2). Calculate the coordinates of the top left corner
# We can calculate the coordinates (say x, y) of the top left corner of the window becoming
# floating based on the coordinates (say x0, y0) of the top left corner of the display. Let
# w0 and h0 are the width and height of the display, and w and h are the width and height of
# the window we have been calculated out above.
# x = x0 + (w0 - w) / 2
# y = y0 + (h0 - h) / 2

# Store x, y, w, h for each display into a temp file. When we switch a window from tiling to
# floating and it is tiling initially, yabai will place the window using x, y, w, h.

tempDir=/tmp/yabai-tiling-floating-toggle
[ -d $tempDir ] && rm -rf $tempDir
mkdir $tempDir

# JSON array
displays=$(yabai -m query --displays)

# How many displays I am using currently
cnt=$(echo $displays | jq '.|length')

# For each display
for ((i = 0 ; i < $cnt ; i++)); do
  display=$(echo $displays | jq ".[$i]")
  index=$(echo $display | jq ".index") # display index

  # Get the coordinates of top left cornor, the width and the height of the display
  read -r x0 y0 w0 h0 <<< $(echo $(echo $display | jq ".frame" | jq ".x, .y, .w, .h"))

  # Calcuate the width and the height of the window
  if [ $h0 -gt $w0 ]
  then
    w=$(($w0/12*10))
    h=$(echo "$w/1.5" | bc)
  else
    h=$(($h0/12*10))
    w=$(echo "$h*1.5/1" | bc)
  fi

  # Calculate the coordinates of the top left corner of the window
  x=$(($x0+($w0-$w)/2))
  y=$(($y0+($h0-h)/2))

  # Store these information in a temp file
  cat>/tmp/yabai-tiling-floating-toggle/display-$index<<EOF
  x=$x
  y=$y
  w=$w
  h=$h
EOF

done
