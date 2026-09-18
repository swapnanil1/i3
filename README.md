# Arch Linux + i3wm

i3 on X11, set up for a Ryzen + Radeon desktop with one 1080p 144 Hz monitor.
`install.sh` takes a bare Arch Linux (server) install to a working desktop.

## Install

Start from a base Arch install with a normal user that has `sudo`, a working
network connection and `git`.

```
git clone https://github.com/swapnanil1/i3 ~/repos/i3
cd ~/repos/i3
./install.sh --dry-run    # shows every action, changes nothing
./install.sh
reboot
```

Log in through `ly` and pick **i3**. After the first login, run
`./install.sh --doctor` to check sensors, DDC brightness, audio and the session
units.

| Flag | Effect |
| --- | --- |
| `--dry-run` | Print what would happen, touch nothing |
| `--yes` | Pass `--noconfirm` to pacman |
| `--optional` | Also install `packages/optional.txt` (gammastep, mousepad, catfish, mpv, CJK fonts, numlockx) |
| `--no-themes` | Leave theming alone: no gsettings changes |
| `--kripton` | Also clone the Kripton GTK theme and Colloid icons (not packaged for Arch) |
| `--fish` | Make fish the login shell |
| `--doctor` | Only run the health checks |

The script is safe to re-run. Existing config directories are moved to
`<name>.bak-<timestamp>` before being replaced by symlinks into this repo, so
edits made under `~/.config/i3`, `polybar`, … are edits to the repo.

## Keys

`$mod` is **Alt**.

| Function | Shortcut | Using |
| --- | --- | --- |
| App launcher | Alt+D | rofi |
| Terminal / floating terminal | Alt+Return / Alt+Shift+Return | alacritty |
| Browser | Alt+C | firefox |
| File manager | Alt+E | thunar |
| Clipboard history | Alt+P | clipmenu + rofi |
| Screenshot (select, annotate) | Print or Alt+Shift+P | flameshot |
| Screenshot (full screen to `~/Pictures/Screenshots`) | Shift+Print | flameshot |
| Brightness up / down | Alt+PageUp / Alt+PageDown | ddcutil |
| Toggle pomodoro | Alt+Shift+Z | polybar `pomo.sh` |
| System monitor | Alt+Shift+Escape | btop |
| Lock | Alt+Shift+X | i3lock |
| Power menu | Alt+Shift+E | rofi |
| Close window | Alt+Shift+Q | |
| Reload config / restart i3 | Alt+Shift+C / Alt+Shift+R | |

The bar's brightness module also reacts to the scroll wheel; the pomodoro
module to left (start), middle (stop) and right (pause) click.

## What is where

| Path | Purpose |
| --- | --- |
| `i3/` | i3 config, theme, window rules, session scripts |
| `polybar/`, `picom/`, `rofi/`, `dunst/`, `alacritty/`, `gsimplecal/` | Symlinked into `~/.config` |
| `fish/`, `Thunar/` | Copied once into `~/.config`: these apps rewrite their own files |
| `systemd/user/` | `i3-session.target` and the daemons it starts |
| `xorg/` | Snippets installed to `/etc/X11/xorg.conf.d/` |
| `seeds/` | Files copied once and then left to their tool (nwg-look, qt6ct, kvantum, portals) |
| `packages/` | Package lists, one name per line |

### Session

i3 runs `i3/scripts/session-start` once per login. It imports the X environment
into systemd and starts `i3-session.target`, which owns picom, the polkit agent
(mate-polkit), xss-lock, clipmenud, autotiling, flameshot and dunst, plus XDG
autostart entries. Daemons restart if they crash and log to the journal:

```
systemctl --user status picom
journalctl --user -u picom -b
systemctl --user mask flameshot.service    # stop a daemon from starting
```

The screen locks after 10 minutes idle and the monitor powers down after 15;
both values are at the top of `session-start`.

### Hardware specifics

* **Refresh rate**: `i3/scripts/display` finds each connected output and sets
  its native mode at the highest rate, so no output name is hardcoded.
* **GPU**: `xorg/20-amdgpu.conf` enables TearFree and FreeSync
  (`VariableRefresh`) through `xf86-video-amdgpu`. picom runs the `glx` backend
  with vsync and unredirects fullscreen windows, which is what lets FreeSync
  engage in games. The snippet is skipped on machines without an amdgpu GPU.
* **Brightness**: DDC/CI through `ddcutil`. The current value is cached in
  `$XDG_RUNTIME_DIR/brightness`, so the bar never polls the monitor. Recent
  ddcutil grants access through udev; no `i2c` group setup is needed.
* **Temperatures**: `k10temp` (`Tctl`) and `amdgpu` (`edge`) through
  `lm_sensors`.
* **Mouse**: `xorg/40-libinput.conf` sets the flat acceleration profile.

### Theming

* GTK: `adw-gtk3-dark` with `Papirus-Dark` icons, both from the repos. To change them run `nwg-look`. It writes `~/.config/gtk-3.0/settings.ini` and gsettings;
  new windows pick the change up. Do not run an XSETTINGS daemon (xsettingsd,
  xfsettingsd) next to it, it would override that file.
* Qt: `qt6ct` with the Kvantum style (`QT_QPA_PLATFORMTHEME=qt6ct` is set in
  `i3/xprofile`). Pick the Kvantum theme in `kvantummanager`.
* Wallpaper: put an image at `~/.config/i3/wallpaper.png` (or `.jpg`, or
  `~/Pictures/wallpaper.*`). Without one the background is the theme colour.
* Colours live in `i3/config.d/01_theme.conf`, `polybar/colors.ini`,
  `rofi/shared/colors.rasi` and `dunst/dunstrc`.

### Defaults

```
xdg-mime default alacritty.desktop x-scheme-handler/terminal
xdg-settings set default-web-browser firefox.desktop
```

### Bluetooth (optional)

```
paru -S bluetuith
```
