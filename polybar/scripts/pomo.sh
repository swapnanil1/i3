#!/bin/bash

STATE_FILE="/tmp/polybar_pomo_state"
END_TIME_FILE="/tmp/polybar_pomo_end_time"
PAUSED_TIME_FILE="/tmp/polybar_pomo_paused_time"
LOOP_PID_FILE="/tmp/polybar_pomo_loop_pid"
POMO_DURATION_MIN=25
BREAK_DURATION_MIN=5
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SOUND_FILE_PATH="$SCRIPT_DIR/notify.mp3"

# Palette written by ~/.config/i3/scripts/theme
[ -f ~/.config/i3/theme.env ] && . ~/.config/i3/theme.env

COLOR_RUNNING="${GREEN:-#98c379}"
COLOR_PAUSED="${YELLOW:-#e5c07b}"
COLOR_BREAK="${BLUE:-#61afef}"
COLOR_STOPPED="${FG_DIM:-#727c91}"
ICON_RUNNING=""
ICON_PAUSED=""
ICON_BREAK="󰗊"
ICON_STOPPED=""

get_state() { if [[ -s $STATE_FILE ]]; then echo "$(<"$STATE_FILE")"; else echo "stopped"; fi; }
set_state() { echo "$1" > "$STATE_FILE"; }
format_time() { local s=$1; ((s<0)) && s=0; printf "%02d:%02d" $((s/60)) $((s%60)); }
play_sound() {
    [ -f "$SOUND_FILE_PATH" ] || return
    # pw-play ships with pipewire; mpv is only a fallback
    if command -v pw-play >/dev/null; then
        pw-play "$SOUND_FILE_PATH" &>/dev/null &
    elif command -v mpv >/dev/null; then
        mpv --no-video --really-quiet "$SOUND_FILE_PATH" &>/dev/null &
    fi
}
send_notification() { notify-send "$1" "$2" -i "$3" -u "$4" -t 5000; }

action_start_pomo() {
    echo $(( $EPOCHSECONDS + POMO_DURATION_MIN * 60 )) > "$END_TIME_FILE"
    rm -f "$PAUSED_TIME_FILE"
    set_state "running"
}
action_start_break() {
    echo $(( $EPOCHSECONDS + BREAK_DURATION_MIN * 60 )) > "$END_TIME_FILE"
    rm -f "$PAUSED_TIME_FILE"
    set_state "break_running"
}
action_stop() {
    set_state "stopped"
    rm -f "$END_TIME_FILE" "$PAUSED_TIME_FILE"
}

action_toggle_pause() {
    local state=$(get_state)
    local current_time=$EPOCHSECONDS
    
    case "$state" in
        running)
            local end_time=$(<"$END_TIME_FILE")
            echo $((end_time - current_time)) > "$PAUSED_TIME_FILE"
            set_state "paused"
            ;;
        paused)
            local remaining=$(<"$PAUSED_TIME_FILE")
            echo $((current_time + remaining)) > "$END_TIME_FILE"
            set_state "running"
            ;;
        break_running)
            local end_time=$(<"$END_TIME_FILE")
            echo $((end_time - current_time)) > "$PAUSED_TIME_FILE"
            set_state "break_paused"
            ;;
        break_paused)
            local remaining=$(<"$PAUSED_TIME_FILE")
            echo $((current_time + remaining)) > "$END_TIME_FILE"
            set_state "break_running"
            ;;
    esac
}

action_display() {
    local state=$(get_state)
    local current_time=$EPOCHSECONDS
    local icon_font="%{T1}"
    local text_font="%{T-}"
    local color=""
    local icon=""
    local text=""

    case "$state" in
        running)
            local end_time=$(<"$END_TIME_FILE"); local remaining=$((end_time - current_time))
            if (( remaining <= 0 )); then
                send_notification "Pomodoro Finished!" "Time for a ${BREAK_DURATION_MIN} min break." "clock-symbolic" "critical"
                play_sound; action_start_break;
            else
                color="$COLOR_RUNNING"; icon="$ICON_RUNNING"; text="$(format_time "$remaining")"
            fi;;
        paused)
            local remaining=$(<"$PAUSED_TIME_FILE")
            color="$COLOR_PAUSED"; icon="$ICON_PAUSED"; text="$(format_time "$remaining")";;
        break_running)
            local end_time=$(<"$END_TIME_FILE"); local remaining=$((end_time - current_time))
            if (( remaining <= 0 )); then
                send_notification "Break Over!" "Time for a ${POMO_DURATION_MIN} min work session." "appointment-soon-symbolic" "normal"
                play_sound; action_start_pomo;
            else
                color="$COLOR_BREAK"; icon="$ICON_BREAK"; text="$(format_time "$remaining")"
            fi;;
        break_paused)
            local remaining=$(<"$PAUSED_TIME_FILE")
            color="$COLOR_PAUSED"; icon="$ICON_BREAK"; text="$(format_time "$remaining")";;
        stopped|*)
            color="$COLOR_STOPPED"; icon="$ICON_STOPPED"; text=" Start";;
    esac
    
    echo "%{F$color}${icon_font}$icon${text_font}$text%{F-}"
}

if [[ -n "$1" ]]; then
    case "$1" in
        start)      action_start_pomo;;
        toggle)     if [[ "$(get_state)" == "stopped" ]]; then action_start_pomo; else action_toggle_pause; fi;;
        toggle_pause) action_toggle_pause;;
        stop)       action_stop;;
    esac
    # wake the bar loop so the change shows immediately
    [[ -s $LOOP_PID_FILE ]] && kill -USR1 "$(<"$LOOP_PID_FILE")" 2>/dev/null
    exit 0
fi

# Bar loop for the `tail = true` polybar module: one line per second, and
# immediately when a click/keybind (handled above) sends SIGUSR1.
echo $$ > "$LOOP_PID_FILE"
trap 'rm -f "$LOOP_PID_FILE"' EXIT
trap ':' USR1
while true; do
    action_display
    sleep 1 &
    wait $!
done
