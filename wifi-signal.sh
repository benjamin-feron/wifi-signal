#!/bin/bash

show_help () {
  echo "Usage: wifi-signal -i <iface>
  Options:
    -i <iface>,     Interface
    -p, --percent,  Show signal value in percent.
    --help          Show help"
}

PERCENT_MIN_SIGNAL=-90
PERCENT_MIDDLE_SIGNAL=-67
PERCENT_MAX_SIGNAL=-30

PERCENT=0

options=$(getopt -o i:p -l help,percent -- "$@")
eval set -- "$options"
while true; do
  case "$1" in
    -i)
      IFACE=$2
      shift 2
      ;;
    -p|--percent)
      PERCENT=1
      shift 1
      ;;
    --help)
      show_help
      exit
      ;;
    --)
      shift
      break
      ;;
  esac
done

throw_error () {
  MSG=$1
  EXIT=$2
  STD_MSG="Command stopped"
  printf "\033[0;31m$MSG\033[0m\n"
  echo "$STD_MSG"
  if $EXIT ; then
    exit 1
  fi
}

[ -z ${IFACE+x} ] && throw_error 'Please specify interface'

signal=$(iwconfig $IFACE | grep 'Signal level' | sed 's/.\+Signal level=\(-\?[0-9]\+\).\+/\1/')

[ "$PERCENT" -ne "1" ] && echo "$signal dBm" && exit 0

signal=$(($signal > $PERCENT_MAX_SIGNAL ? $PERCENT_MAX_SIGNAL : $signal))
if [ $signal -ge $PERCENT_MIDDLE_SIGNAL ]; then
  echo $((50+(-$PERCENT_MIDDLE_SIGNAL+$signal)*50/(-$PERCENT_MIDDLE_SIGNAL+$PERCENT_MAX_SIGNAL)))
else
  echo $((50-($PERCENT_MIDDLE_SIGNAL-$signal)*50/(-$PERCENT_MIDDLE_SIGNAL+$PERCENT_MIN_SIGNAL)))
fi

