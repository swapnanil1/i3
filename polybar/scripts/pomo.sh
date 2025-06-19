#!/bin/bash

STATE_FILE="/tmp/polybar_pomo_state"
END_TIME_FILE="/tmp/polybar_pomo_end_time"
PAUSED_TIME_FILE="/tmp/polybar_pomo_paused_time"
POMO_DURATION_MIN=25
BREAK_DURATION_MIN=5
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SOUND_FILE_PATH="$SCRIPT_DIR/notify.mp3"

COLOR_RUNNING="${GREEN:-#98c379}"
COLOR_PAUSED="${YELLOW:-#e5c07b}"
COLOR_BREAK="${BLUE:-#61afef}"
COLOR_STOPPED="${ALTFOREGROUND:-#727c91}"
ICON_RUNNING=""
ICON_PAUSED=""
ICON_BREAK="󰗊"
ICON_STOPPED=""

get_state() { cat "$STATE_FILE" 2>/dev/null || echo "stopped"; }
set_state() { echo "$1" > "$STATE_FILE"; }
format_time() { local s=$1; ((s<0)) && s=0; printf "%02d:%02d" $((s/60)) $((s%60)); }
play_sound() { [ -f "$SOUND_FILE_PATH" ] && mpv --no-video --really-quiet "$SOUND_FILE_PATH" &>/dev/null & }
send_notification() { notify-send "$1" "$2" -i "$3" -u "$4" -t 5000; }

action_start_pomo() {
    echo $(( $(date +%s) + POMO_DURATION_MIN * 60 )) > "$END_TIME_FILE"
    rm -f "$PAUSED_TIME_FILE"
    set_state "running"
}
action_start_break() {
    echo $(( $(date +%s) + BREAK_DURATION_MIN * 60 )) > "$END_TIME_FILE"
    rm -f "$PAUSED_TIME_FILE"
    set_state "break_running"
}
action_stop() {
    set_state "stopped"
    rm -f "$END_TIME_FILE" "$PAUSED_TIME_FILE"
}

action_toggle_pause() {
    local state=$(get_state)
    local current_time=$(date +%s)
    
    case "$state" in
        running)
            local end_time=$(cat "$END_TIME_FILE")
            echo $((end_time - current_time)) > "$PAUSED_TIME_FILE"
            set_state "paused"
            ;;
        paused)
            local remaining=$(cat "$PAUSED_TIME_FILE")
            echo $((current_time + remaining)) > "$END_TIME_FILE"
            set_state "running"
            ;;
        break_running)
            local end_time=$(cat "$END_TIME_FILE")
            echo $((end_time - current_time)) > "$PAUSED_TIME_FILE"
            set_state "break_paused"
            ;;
        break_paused)
            local remaining=$(cat "$PAUSED_TIME_FILE")
            echo $((current_time + remaining)) > "$END_TIME_FILE"
            set_state "break_running"
            ;;
    esac
}

action_display() {
    local state=$(get_state)
    local current_time=$(date +%s)
    local icon_font="%{T1}"
    local text_font="%{T-}"
    local color=""
    local icon=""
    local text=""

    case "$state" in
        running)
            local end_time=$(cat "$END_TIME_FILE"); local remaining=$((end_time - current_time))
            if (( remaining <= 0 )); then
                send_notification "Pomodoro Finished!" "Time for a ${BREAK_DURATION_MIN} min break." "clock-symbolic" "critical"
                play_sound; action_start_break;
            else
                color="$COLOR_RUNNING"; icon="$ICON_RUNNING"; text="$(format_time "$remaining")"
            fi;;
        paused)
            local remaining=$(cat "$PAUSED_TIME_FILE")
            color="$COLOR_PAUSED"; icon="$ICON_PAUSED"; text="$(format_time "$remaining")";;
        break_running)
            local end_time=$(cat "$END_TIME_FILE"); local remaining=$((end_time - current_time))
            if (( remaining <= 0 )); then
                send_notification "Break Over!" "Time for a ${POMO_DURATION_MIN} min work session." "appointment-soon-symbolic" "normal"
                play_sound; action_start_pomo;
            else
                color="$COLOR_BREAK"; icon="$ICON_BREAK"; text="$(format_time "$remaining")"
            fi;;
        break_paused)
            local remaining=$(cat "$PAUSED_TIME_FILE")
            color="$COLOR_PAUSED"; icon="$ICON_BREAK"; text="$(format_time "$remaining")";;
        stopped|*)
            color="$COLOR_STOPPED"; icon="$ICON_STOPPED"; text=" Start";;
    esac
    
    echo "%{F$color}${icon_font}$icon${text_font}$text%{F-}"
}

if [[ -n "$1" ]]; then
    case "$1" in
        start)      action_start_pomo;;
        toggle_pause) action_toggle_pause;;
        stop)       action_stop;;
    esac
    action_display
    exit 0
fi

# This loop is for the `tail` in the Polybar module.
# It is separate from the IPC hook system.
while true; do
    action_display
    read -t 1 -r line || continue
done &

# This is the IPC handler that listens for clicks
polybar-msg -p "$(pgrep -f "polybar.*main")" hook pomo 4
while true; do
    read -r line || break
    case "$line" in
        "hook:pomo:1") action_start_pomo ;;
        "hook:pomo:2") action_stop ;;
        "hook:pomo:3") action_toggle_pause ;;
    esac
done
