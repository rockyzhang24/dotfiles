#!/bin/bash
STP="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"
CLK="Coffee.icns"

# orig idea and some code from https://github.com/shawnrice/alfred-2-caffeinate-workflow
# Coffee.icns from http://www.everaldo.com

toSeconds() {
  arg=$1
  (( sec=60*60*2 ))
  if [[ $arg =~ ([0-9]+)$ ]]
  then
    (( sec=$arg*60*60 ))
  else
    [[ $arg =~ ([0-9]+)([hHmM])$ ]]
    time=${BASH_REMATCH[1]}
    unit=${BASH_REMATCH[2]}
    if [[ $unit =~ ([hH]) ]]
    then
      (( sec=$time*60*60 ))
    elif [[ $unit =~ ([mM]) ]]
    then
      (( sec=$time*60 ))
    fi
  fi
  echo $sec
}

toString() {
  sec=$1
  if [ $sec == 0 ]
  then
    echo "ever"
  else
    hour=$(($sec/3600))
    min=$((($sec/60)%60))
    printf " %02d:%02d" $hour $min
  fi
}

# if no argument then show status
if [ -z "$1" ]
then
  PROC=`ps -eo etime,args | grep caffeinate | grep -v grep | grep -v caffeinate.sh | head -n 1`
  if [ -z "$PROC" ]
  then
    echo "[{\"title\":\"Not caffeinated\",\"icon\":\"NotFound.icns\"}]"
  else
    # 03:26 caffeinate -u -t 1200
    # 01:03:26 caffeinate -u -t 1200
    [[ "$PROC" =~ ([0-9]+)$ ]]
    dur=${BASH_REMATCH[1]}

    if [[ "$PROC" =~ (-w [0-9]+) ]]
    then
      # if caffeinate running while another process is running
      str=" running PID ${dur}"
    elif [[ "$PROC" =~ ([0-9]+):([0-9]+):([0-9]+) ]]
    then
      (( elapsed=${BASH_REMATCH[1]}*60*60 + ${BASH_REMATCH[2]}*60 ))
    else
      [[ $PROC =~ ([0-9]+):([0-9]+) ]]
      (( elapsed=${BASH_REMATCH[1]}*60 ))
    fi
    if [ -z "${str}" ]
    then
      if [ -z "${dur}" -o "${dur}" == 0 ]
      then
        remain=0
      else
        (( remain=$dur - $elapsed ))
      fi
      str=`toString $remain`
    fi
    echo "[{\"title\":\"Caffeinated awake for${str}\",\"icon\":\"$CLK\"},\
           {\"title\":\"Stop caffeinating\",\"icon\":\"$STP\",\"action\":\"stop.sh\"}]"
  fi
else
  # if we have an argument then process it as a new caffeinate time
  secArg=
  sec=`toSeconds $1`
  if [ $sec > 0 ]
  then
    secArg="-t $sec"
  fi
  str=`toString $sec`
  killall caffeinate 2>/dev/null
  caffeinate -dimsu $secArg 1>/dev/null 2>&1 &
  echo "[{\"title\":\"Caffeinated awake for${str}\",\"icon\":\"$CLK\"}]"
fi
exit 0