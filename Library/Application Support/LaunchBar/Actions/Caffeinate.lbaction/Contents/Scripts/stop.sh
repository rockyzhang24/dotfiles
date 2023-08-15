#!/bin/bash
STP="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"
killall caffeinate 2>/dev/null
echo "[{\"title\":\"Caffeinating stopped\",\"icon\":\"$STP\"}]"
exit 0