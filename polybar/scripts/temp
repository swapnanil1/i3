#!/bin/bash

# This script only outputs a colored temperature string.
# The icon is handled by the Polybar module itself.

# Palette written by ~/.config/i3/scripts/theme
[ -f ~/.config/i3/theme.env ] && . ~/.config/i3/theme.env

# --- CONFIGURATION ---
COLOR_NORMAL="${FG:-#c8ccd4}"
COLOR_WARN="${YELLOW:-#e5c07b}"
COLOR_CRIT="${RED:-#e06c75}"

CPU_WARN_THRESHOLD=75
CPU_CRIT_THRESHOLD=90
GPU_WARN_THRESHOLD=70
GPU_CRIT_THRESHOLD=85

# --- HELPER FUNCTION ---
get_temp() {
    local sensor_output="$1"
    local label="$2"
    local temp_line=$(echo "$sensor_output" | grep "$label:")
    local temp_val=$(echo "$temp_line" | awk '{print $2}' | sed 's/+//; s/°C//')

    if [[ "$temp_val" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        printf "%.0f" "$temp_val"
    else
        echo "N/A"
    fi
}

# --- SENSOR DATA ---
sensors_data=$(sensors 2>/dev/null)

# --- LOGIC ---
if [[ "$1" == "cpu" ]]; then
    temp=$(get_temp "$sensors_data" "Tctl")
    [[ "$temp" == "N/A" ]] && temp=$(get_temp "$sensors_data" "Tdie")
    [[ "$temp" == "N/A" ]] && temp=$(get_temp "$sensors_data" "Package id 0")
    
    warn_thresh=$CPU_WARN_THRESHOLD
    crit_thresh=$CPU_CRIT_THRESHOLD

elif [[ "$1" == "gpu" ]]; then
    temp=$(get_temp "$sensors_data" "edge")
    [[ "$temp" == "N/A" ]] && temp=$(get_temp "$sensors_data" "junction")

    warn_thresh=$GPU_WARN_THRESHOLD
    crit_thresh=$GPU_CRIT_THRESHOLD
else
    echo "N/A"
    exit 1
fi

# No sensor found (driver not loaded, different hardware)
if [[ "$temp" == "N/A" ]]; then
    echo "%{F$COLOR_NORMAL}N/A%{F-}"
    exit 0
fi

# Determine color based on thresholds (get_temp already rounded to an integer)
color="$COLOR_NORMAL"
if (( temp >= crit_thresh )); then
    color="$COLOR_CRIT"
elif (( temp >= warn_thresh )); then
    color="$COLOR_WARN"
fi

# Output the final formatted string for Polybar
# It contains ONLY the colored text, no icon.
echo "%{F$color}${temp}°C%{F-}"

exit 0
