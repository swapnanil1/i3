#!/bin/bash

get_brightness() {
    local output=$(ddcutil getvcp 10 2>/dev/null)
    if [[ $output =~ current\ value\ =\ *([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "ERR"
    fi
}

while true; do
    get_brightness
    sleep 2
done
