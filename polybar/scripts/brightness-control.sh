#!/bin/bash
STEP=5
DDC_ARGS=""
action_inc() { ddcutil $DDC_ARGS setvcp 10 + $STEP > /dev/null; }
action_dec() { ddcutil $DDC_ARGS setvcp 10 - $STEP > /dev/null; }
case "$1" in inc) action_inc ;; dec) action_dec ;; esac
exit 0
