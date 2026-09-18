#!/usr/bin/env bash
# Microphone mute state for the bar. Event driven (pactl subscribe), no polling.
#   mic.sh            print state now and on every source change (tail module)
#   mic.sh toggle     mute/unmute the default source

# Palette written by ~/.config/i3/scripts/theme
[ -f ~/.config/i3/theme.env ] && . ~/.config/i3/theme.env

COLOR_MUTED="${RED:-#e06c75}"
COLOR_LIVE="${FG_DIM:-#727c91}"
ICON_LIVE=$''
ICON_MUTED=$''

show() {
	if [[ $(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null) == *yes ]]; then
		echo "%{F$COLOR_MUTED}$ICON_MUTED muted%{F-}"
	else
		echo "%{F$COLOR_LIVE}$ICON_LIVE%{F-}"
	fi
}

if [[ $1 == toggle ]]; then
	pactl set-source-mute @DEFAULT_SOURCE@ toggle
	exit 0
fi

# take the pactl/grep children down with us when the bar restarts
trap 'pkill -P $$' EXIT
trap 'exit 0' TERM INT HUP

show
pactl subscribe 2>/dev/null | grep --line-buffered -E "'change' on (source|server)" | while read -r _; do
	show
done
