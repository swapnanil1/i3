#!/usr/bin/env bash
# Bootstrap an i3/X11 desktop on top of a bare Arch Linux (server) install.
# Safe to re-run. Nothing is touched with --dry-run.
#
#   ./install.sh [--dry-run] [--yes] [--optional] [--no-themes] [--kripton] [--fish] [--doctor]

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0 YES=0 OPTIONAL=0 THEMES=1 KRIPTON=0 FISH=0 DOCTOR_ONLY=0
for arg in "$@"; do
	case "$arg" in
		--dry-run)   DRY_RUN=1 ;;
		--yes)       YES=1 ;;
		--optional)  OPTIONAL=1 ;;
		--no-themes) THEMES=0 ;;
		--kripton)   KRIPTON=1 ;;
		--fish)      FISH=1 ;;
		--doctor)    DOCTOR_ONLY=1 ;;
		-h | --help) sed -n '2,5p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
		*) echo "unknown option: $arg" >&2; exit 2 ;;
	esac
done

step() { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33m    warning:\033[0m %s\n' "$*"; }
run() {
	if ((DRY_RUN)); then
		printf '    [dry-run] %s\n' "$*"
	else
		"$@"
	fi
}

# --- helpers ---------------------------------------------------------------

packages_from() { grep -hvE '^\s*(#|$)' "$@"; }

has_amdgpu() { lspci -k 2>/dev/null | grep -A3 -E 'VGA|3D|Display' | grep -q 'in use: amdgpu' ||
	ls /sys/bus/pci/drivers/amdgpu/0000:* >/dev/null 2>&1; }

# link <repo path> <destination>; an existing real file/dir is moved aside
link() {
	local src="$REPO/$1" dst="$2"
	if [[ -L $dst && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
		info "ok      $dst"
		return
	fi
	if [[ -e $dst || -L $dst ]]; then
		info "backup  $dst -> $dst.bak-$STAMP"
		run mv "$dst" "$dst.bak-$STAMP"
	fi
	info "link    $dst -> $src"
	run mkdir -p "$(dirname "$dst")"
	run ln -s "$src" "$dst"
}

# seed <repo path> <destination>; copied once, never overwritten, because the
# owning tool (nwg-look, qt6ct, kvantum) rewrites these files
seed() {
	local src="$REPO/$1" dst="$2"
	if [[ -e $dst ]]; then
		info "keep    $dst"
		return
	fi
	info "seed    $dst"
	run install -Dm644 "$src" "$dst"
}

# seeddir <repo dir> <destination dir>; like seed, for a whole directory. Used
# for apps that rewrite their own config (Thunar, fish): a symlink would make
# every such rewrite show up as a modification in this repo.
seeddir() {
	local src="$REPO/$1" dst="$2"
	if [[ -L $dst ]]; then
		info "unlink  $dst (was a symlink into the repo)"
		run rm "$dst"
	fi
	info "seed    $dst (existing files are kept)"
	run mkdir -p "$dst"
	run cp -rn "$src/." "$dst/"
}

# sysfile <repo path> <destination>; root-owned file, replaced only if different
sysfile() {
	local src="$REPO/$1" dst="$2"
	if [[ -f $dst ]] && cmp -s "$src" "$dst"; then
		info "ok      $dst"
		return
	fi
	[[ -f $dst ]] && run sudo cp -a "$dst" "$dst.bak-$STAMP"
	info "install $dst"
	run sudo install -Dm644 "$src" "$dst"
}

# --- doctor ----------------------------------------------------------------

doctor() {
	step "Doctor"
	local fails=0
	check() { # description, command...
		local desc="$1"; shift
		if "$@" >/dev/null 2>&1; then
			printf '    \033[32mok\033[0m    %s\n' "$desc"
		else
			printf '    \033[31mFAIL\033[0m  %s\n' "$desc"
			fails=$((fails + 1))
		fi
	}
	check "amdgpu kernel driver bound"            has_amdgpu
	check "amdgpu firmware installed"             test -d /usr/lib/firmware/amdgpu
	check "Xorg amdgpu snippet in place"          test -f /etc/X11/xorg.conf.d/20-amdgpu.conf
	check "i3 config parses"                      i3 -C -c "$CONFIG/i3/config"
	check "JetBrainsMono Nerd Font resolves"      sh -c "fc-match 'JetBrainsMono Nerd Font' family | grep -q JetBrainsMono"
	check "CPU temperature sensor (Tctl)"         sh -c "sensors 2>/dev/null | grep -q Tctl"
	check "GPU temperature sensor (edge)"         sh -c "sensors 2>/dev/null | grep -q edge"
	check "monitor answers over DDC/CI"           sh -c "ddcutil detect --brief 2>/dev/null | grep -q 'I2C bus'"
	check "PipeWire PulseAudio server reachable"  sh -c "pactl info | grep -q PipeWire"
	check "i3-session.target installed"           test -e "$CONFIG/systemd/user/i3-session.target"
	check "login unlocks the keyring (PAM)"        sh -c "test -e /usr/lib/security/pam_gnome_keyring.so && grep -qs pam_gnome_keyring /etc/pam.d/ly"
	check "polkit agent binary present"           test -x /usr/lib/mate-polkit/polkit-mate-authentication-agent-1
	check "a login manager is enabled"            sh -c "systemctl is-enabled display-manager.service || systemctl is-enabled ly@tty2.service"
	check "~/.xprofile loads the session env"     grep -q 'i3/xprofile' "$HOME/.xprofile"
	if ((fails)); then
		warn "$fails check(s) failed. Audio and DDC checks need a logged-in session; re-run './install.sh --doctor' after the first login."
	else
		info "all checks passed"
	fi
}

# --- preflight -------------------------------------------------------------

if ((EUID == 0)); then
	echo "Run this as your normal user; it calls sudo where it needs root." >&2
	exit 1
fi
for cmd in pacman sudo; do
	command -v "$cmd" >/dev/null || { echo "$cmd not found; this script targets Arch Linux." >&2; exit 1; }
done

if ((DOCTOR_ONLY)); then
	doctor
	exit 0
fi

AMD=1
if ! has_amdgpu; then
	AMD=0
	warn "no GPU bound to amdgpu: skipping xf86-video-amdgpu, AMD firmware and the Xorg amdgpu snippet"
fi

# --- packages --------------------------------------------------------------

step "Packages"
lists=("$REPO/packages/base.txt" "$REPO/packages/desktop.txt" "$REPO/packages/apps.txt")
((OPTIONAL)) && lists+=("$REPO/packages/optional.txt")
mapfile -t pkgs < <(packages_from "${lists[@]}")

if ((!AMD)); then
	filtered=()
	for p in "${pkgs[@]}"; do
		case "$p" in xf86-video-amdgpu | vulkan-radeon | linux-firmware-amdgpu | amd-ucode) ;; *) filtered+=("$p") ;; esac
	done
	pkgs=("${filtered[@]}")
fi

# The bar's network click opens nm-connection-editor; only meaningful with NetworkManager.
# The network stack itself is deliberately left alone.
if systemctl is-active --quiet NetworkManager.service; then
	pkgs+=(network-manager-applet)
else
	info "NetworkManager not active: skipping network-manager-applet"
fi

# -Syu, not -S: installing without upgrading the rest is a partial upgrade
pacman_args=(-Syu --needed)
((YES)) && pacman_args+=(--noconfirm)
info "${#pkgs[@]} packages from ${#lists[@]} lists"
run sudo pacman "${pacman_args[@]}" "${pkgs[@]}"

# --- user configuration ----------------------------------------------------

step "Config symlinks"
for dir in i3 polybar picom rofi dunst alacritty gsimplecal fastfetch; do
	link "$dir" "$CONFIG/$dir"
done
link autostart/picom.desktop "$CONFIG/autostart/picom.desktop"
for unit in "$REPO"/systemd/user/*; do
	link "systemd/user/$(basename "$unit")" "$CONFIG/systemd/user/$(basename "$unit")"
done

step "Colour theme"
if [[ -f $REPO/i3/theme.env ]]; then
	info "ok      $(grep -m1 ^THEME= "$REPO/i3/theme.env")"
else
	run "$REPO/i3/scripts/theme" --no-reload onedark
fi

step "Seed files (copied once, then owned by their tools)"
seeddir Thunar "$CONFIG/Thunar"
seeddir fish   "$CONFIG/fish"
seed seeds/gtk-3.0/settings.ini               "$CONFIG/gtk-3.0/settings.ini"
seed seeds/gtk-4.0/settings.ini               "$CONFIG/gtk-4.0/settings.ini"
seed seeds/xdg-desktop-portal/portals.conf    "$CONFIG/xdg-desktop-portal/portals.conf"
seed seeds/qt6ct/qt6ct.conf                   "$CONFIG/qt6ct/qt6ct.conf"
seed seeds/Kvantum/kvantum.kvconfig           "$CONFIG/Kvantum/kvantum.kvconfig"
seed seeds/flameshot/flameshot.ini            "$CONFIG/flameshot/flameshot.ini"
seed seeds/icons-default/index.theme          "$HOME/.icons/default/index.theme"

# Chromium-family browsers pick their password/cookie encryption backend from
# XDG_CURRENT_DESKTOP and do not know "i3", so the choice can differ between
# versions. Pin it to the keyring (unlocked at login by ly's PAM hooks): no
# password prompts, and no "logged out of everything" after a backend switch.
# Skipped where another Secret Service already holds the browser's keys.
if ! pacman -Qq kwallet >/dev/null 2>&1; then
	# browsers, then Electron: Arch's electron launcher (Vesktop and other
	# system-electron apps), code-oss / VS Code, VSCodium
	for flags in chromium-flags.conf brave-flags.conf chrome-flags.conf \
		electron-flags.conf code-flags.conf codium-flags.conf; do
		seed seeds/browser/flags.conf "$CONFIG/$flags"
	done
	# VS Code family also reads the store from argv.json
	for dir in .vscode .vscode-oss; do
		seed seeds/browser/argv.json "$HOME/$dir/argv.json"
	done
fi

step "Launcher clean-up"
while read -r app; do
	[[ -z $app || $app == \#* ]] && continue
	override="$HOME/.local/share/applications/$app.desktop"
	[[ -e /usr/share/applications/$app.desktop && ! -e $override ]] || continue
	info "hide    $app"
	((DRY_RUN)) || { mkdir -p "$(dirname "$override")"; printf '[Desktop Entry]\nType=Application\nName=%s\nNoDisplay=true\n' "$app" >"$override"; }
done <"$REPO/rofi/hidden-apps.txt"

step "Session environment"
xprofile_line='[ -f "$HOME/.config/i3/xprofile" ] && . "$HOME/.config/i3/xprofile"'
if grep -qsF 'i3/xprofile' "$HOME/.xprofile"; then
	info "ok      ~/.xprofile"
else
	info "append  ~/.xprofile"
	((DRY_RUN)) || printf '%s\n' "$xprofile_line" >>"$HOME/.xprofile"
fi
bashrc_line='[ -f "$HOME/.config/i3/shellrc" ] && . "$HOME/.config/i3/shellrc"'
if grep -qsF 'i3/shellrc' "$HOME/.bashrc"; then
	info "ok      ~/.bashrc"
else
	info "append  ~/.bashrc"
	((DRY_RUN)) || printf '%s\n' "$bashrc_line" >>"$HOME/.bashrc"
fi
run xdg-user-dirs-update
run mkdir -p "$HOME/Pictures/Screenshots"

if ((DRY_RUN)) || systemctl --user daemon-reload 2>/dev/null; then
	run systemctl --user enable gnome-keyring-daemon.socket || warn "could not enable gnome-keyring-daemon.socket"
else
	warn "no systemd user session here; units are picked up at next login"
fi

# --- themes ----------------------------------------------------------------

if ((THEMES)); then
	step "GTK theme and icons"
	# adw-gtk-theme and papirus-icon-theme come from the package list; the seeded
	# settings.ini selects them for GTK3/4 apps on X11.
	# GTK4/libadwaita apps, Firefox and Electron read dark mode through the portal,
	# which reads gsettings. nwg-look keeps these in sync afterwards.
	run gsettings set org.gnome.desktop.interface color-scheme prefer-dark || warn "gsettings failed (no session bus?); set the theme once with nwg-look after login"
	run gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark || true
	run gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark || true
	run gsettings set org.gnome.desktop.interface cursor-theme Adwaita || true
fi

# Not packaged for Arch, so cloned from GitHub; pick them afterwards in nwg-look
if ((KRIPTON)); then
	step "Kripton GTK theme and Colloid icons (optional)"
	if [[ -d $HOME/.themes/Kripton ]]; then
		info "ok      ~/.themes/Kripton"
	else
		run git clone --depth 1 https://github.com/EliverLara/Kripton "$HOME/.themes/Kripton" ||
			warn "Kripton clone failed"
	fi
	if compgen -G "$HOME/.local/share/icons/Colloid*" >/dev/null || compgen -G "$HOME/.icons/Colloid*" >/dev/null; then
		info "ok      Colloid icons"
	else
		tmp="${TMPDIR:-/tmp}/colloid-$STAMP"
		if run git clone --depth 1 https://github.com/vinceliuice/Colloid-icon-theme.git "$tmp"; then
			run "$tmp/install.sh" -s default -t default || warn "Colloid install failed"
		else
			warn "Colloid clone failed"
		fi
		run rm -rf "$tmp"
	fi
fi

# --- system configuration --------------------------------------------------

step "Xorg snippets"
((AMD)) && sysfile xorg/20-amdgpu.conf /etc/X11/xorg.conf.d/20-amdgpu.conf
sysfile xorg/40-libinput.conf /etc/X11/xorg.conf.d/40-libinput.conf

step "Login manager"
if systemctl is-enabled --quiet display-manager.service 2>/dev/null; then
	info "a display manager is already enabled, leaving it alone"
elif systemctl is-enabled --quiet ly@tty2.service 2>/dev/null; then
	info "ok      ly@tty2.service"
else
	# enabled, not started: starting it would pull this terminal out from under you
	run sudo systemctl enable ly@tty2.service
fi

if ((FISH)); then
	step "Login shell"
	if [[ "$(getent passwd "$USER" | cut -d: -f7)" == /usr/bin/fish ]]; then
		info "ok      fish"
	else
		run chsh -s /usr/bin/fish
	fi
fi

((DRY_RUN)) || doctor

step "Done"
info "Reboot (or log out), pick the i3 session at the login screen and log in."
info "Wallpaper: drop an image at ~/.config/i3/wallpaper.png (or ~/Pictures/wallpaper.*)."
