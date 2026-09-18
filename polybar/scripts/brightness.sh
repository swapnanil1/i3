#!/usr/bin/env bash
# Monitor brightness over DDC/CI (ddcutil), shared by the i3 keybinds and the
# polybar module. The value is cached so the bar never polls the I2C bus, and
# rapid key/scroll events collapse into a single hardware write.
#
#   brightness.sh get | up | down | set <0-100> | menu | toggle

STEP=5
NIGHT=30   # "toggle" flips between this and whatever was set before
DIR="${XDG_RUNTIME_DIR:-/tmp}/brightness"
mkdir -p "$DIR"

# The I2C bus number can change between boots; XDG_RUNTIME_DIR is per-boot.
bus_args() {
	if [[ ! -s $DIR/bus ]]; then
		ddcutil detect --brief 2>/dev/null |
			sed -n 's|.*I2C bus: */dev/i2c-\([0-9]\+\).*|\1|p' | head -n1 >"$DIR/bus"
	fi
	[[ -s $DIR/bus ]] && echo "--bus $(<"$DIR/bus")"
}

read_hw() {
	# terse output: "VCP 10 C <current> <max>"
	# shellcheck disable=SC2046
	ddcutil $(bus_args) --terse getvcp 10 2>/dev/null | awk '$1 == "VCP" { print $4 }'
}

current() {
	if [[ ! -s $DIR/value ]]; then
		read_hw >"$DIR/value"
	fi
	cat "$DIR/value"
}

refresh_bar() {
	# never let a wedged bar block a brightness change
	command -v polybar-msg >/dev/null && timeout 2 polybar-msg action "#brightness.hook.0" >/dev/null 2>&1
}

change() {
	local cur new
	exec 9>"$DIR/lock"
	flock 9
	cur=$(current)
	[[ $cur =~ ^[0-9]+$ ]] || exit 1
	case "$1" in
		up)   new=$((cur + STEP)) ;;
		down) new=$((cur - STEP)) ;;
		*)    new=$1 ;;
	esac
	((new > 100)) && new=100
	((new < 0)) && new=0
	echo "$new" >"$DIR/value"
	flock -u 9
	refresh_bar

	# Whoever gets the hardware lock writes the latest cached value; the
	# callers queued behind it find nothing left to do.
	exec 8>"$DIR/hwlock"
	flock 8
	local target
	target=$(<"$DIR/value")
	if [[ $target != "$(cat "$DIR/applied" 2>/dev/null)" ]]; then
		# shellcheck disable=SC2046
		ddcutil $(bus_args) --noverify setvcp 10 "$target" >/dev/null 2>&1 &&
			echo "$target" >"$DIR/applied"
	fi
}

case "$1" in
	get)
		value=$(current)
		if [[ $value =~ ^[0-9]+$ ]]; then echo "$value%"; else echo "N/A"; fi
		;;
	up | down) change "$1" ;;
	set) [[ $2 =~ ^[0-9]+$ ]] && change "$2" ;;
	menu)
		pick=$(printf '%s\n' 100 75 50 25 10 | rofi -dmenu -i -p "Brightness" -l 5)
		[[ $pick =~ ^[0-9]+$ ]] && change "$pick"
		;;
	toggle)
		cur=$(current)
		if [[ $cur == "$NIGHT" ]]; then
			change "$(cat "$DIR/day" 2>/dev/null || echo 100)"
		else
			echo "$cur" >"$DIR/day"
			change "$NIGHT"
		fi
		;;
	*) echo "usage: ${0##*/} get|up|down|set <0-100>|menu|toggle" >&2; exit 2 ;;
esac
