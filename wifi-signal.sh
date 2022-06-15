#!/bin/bash

show_help () {
  echo "Usage: wifi-signal -i <iface>
  Options:
    -i <iface>,          Interface
    --help               Show help"
}

MINIMUM_SIGNAL=-90
USABLE_SIGNAL=-67
MAXIMUM_SIGNAL=-30

options=$(getopt -o i: -l help -- "$@")
eval set -- "$options"
while true; do
  case "$1" in
    -i)
      IFACE=$2
      shift 2
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

signal=$(iwconfig $IFACE | grep 'Signal level' | sed 's/.\+Signal level=\(-\?[0-9]\+\) dBm/\1/')

if [ $signal -ge $USABLE_SIGNAL ]; then
  echo $((50+(-$USABLE_SIGNAL+$signal)*50/(-$USABLE_SIGNAL+$MAXIMUM_SIGNAL)))
else
  echo $((50-($USABLE_SIGNAL-$signal)*50/(-$MINIMUM_SIGNAL+$USABLE_SIGNAL)))
fi

