# i3 desktop for Arch Linux

A complete i3 (X11) desktop that installs on top of a bare Arch Linux system
with one script: window manager, bar, launcher, notifications, compositor,
themes, sounds and a keyboard-driven workflow.

* **One command install**, safe to re-run, with a dry-run mode and a health check
* **Left-hand key layout**: everything within reach of the modifier and W A S D
* **15 colour themes** switched live across i3, polybar, rofi, alacritty, dunst,
  fastfetch and the shell prompt
* **Searchable key list** generated from the config, so it is never out of date
* **Game mode**, a **pomodoro timer** that enforces breaks, event sounds, a
  drop-down terminal and per-purpose workspaces
* Session daemons run as **systemd user units**: they restart on failure and
  log to the journal
* Only packages from the official repositories; nothing from the AUR

## Requirements

* Arch Linux or a derivative, with a normal user that can use `sudo`
* A network connection and `git`

Everything else is installed for you. Some features depend on hardware and
simply stay inactive without it:

| Feature | Needs |
| --- | --- |
| TearFree and FreeSync Xorg snippet | A GPU on the `amdgpu` driver. Skipped otherwise. |
| Monitor brightness keys and bar module | A monitor that speaks DDC/CI (`ddcutil`). Shows `N/A` otherwise. |
| CPU and GPU temperature in the bar | `lm_sensors` labels `Tctl`/`Tdie`/`Package id 0` (CPU) and `edge`/`junction` (GPU). Shows `N/A` otherwise. |
| Network speed in the bar | A wired interface; change `interface-type` in `polybar/modules.ini` for Wi-Fi. |

## Install

```
git clone <this repository> ~/i3-desktop
cd ~/i3-desktop
./install.sh --dry-run    # shows every action, changes nothing
./install.sh
reboot
```

Log in through `ly` and pick **i3**. After the first login run
`./install.sh --doctor` to check sensors, brightness, audio and the session
units.

| Flag | Effect |
| --- | --- |
| `--dry-run` | Print what would happen, touch nothing |
| `--yes` | Pass `--noconfirm` to pacman |
| `--optional` | Also install `packages/optional.txt` (gammastep, mousepad, catfish, CJK fonts, numlockx) |
| `--no-themes` | Leave GTK theming alone: no gsettings changes |
| `--kripton` | Also clone the Kripton GTK theme and Colloid icons (not packaged for Arch) |
| `--fish` | Make fish the login shell |
| `--doctor` | Only run the health checks |

The script is safe to re-run. Existing config directories are moved to
`<name>.bak-<timestamp>` before being replaced by symlinks into this
repository, so edits made under `~/.config/i3`, `~/.config/polybar`, … are
edits to your clone. A display manager that is already enabled is left alone.

## Keys

The layout is built for the left hand, and it fits a 60% keyboard: thumb on
**Mod**, fingers on W A S D. Mod is Super. `i3/scripts/keyboard` swaps left Alt
and left Super so that Mod is the key under the thumb; set `SWAP=0` in that
script to keep the keys as printed.

`Mod+Shift+Space` lists every binding with a description. It is searchable and
Enter runs the selected line. The list is read from the config: the `#:`
comment above each `bindsym` is its description, so add one when you add a key.

| Keys | Action |
| --- | --- |
| Mod + W A S D (+ Shift) | Focus (move window) |
| Mod + 1…5 (+ Shift) | Workspace: web, code, terminals, files, games (send window) |
| Mod + Esc / Tab | Previous workspace / window switcher |
| Mod + Space | App launcher |
| Mod + T / Q / E / B | Terminal, drop-down terminal, files, browser |
| Mod + V / C | Clipboard history / screenshot (capture) |
| Mod + F (+ Shift) | Fullscreen (float) |
| Mod + R / G | Resize mode / adjust mode, both driven by W A S D |
| Mod + Z / X | Toggle split layout / tabbed |
| Mod + Ctrl + W S / A D / X | Volume / brightness / mute, one step |
| Mod + Shift + Q | Close window |
| Mod + Shift + Z X E G T | Pomodoro, lock, session menu, game mode, theme |
| Mod + Shift + C / R | Reload / restart i3 |

Adjust mode (Mod+G, nothing held): W S volume, A D brightness, X mute,
Q E previous/next track, Space play/pause, Z event sounds, Esc leaves. It
covers every key a compact keyboard lacks.

Workspaces 6…0, Return for a terminal, J K L ; for focus, and the media and
Print keys also work, for full-size keyboards.

On the bar: scroll on brightness and volume, right click volume or the
microphone for the mixer, click CPU, temperatures or memory for `btop`, right
click the clock for a calendar, right click the logo for the session menu.
The pomodoro module takes left (start, pause), middle (break now) and right
(stop) click, and scrolling shows the last seven days.

## Features

### Workspaces

New windows go to a workspace by purpose: 1 web, 2 code, 5 games, 6 Steam,
7 chat and media, 8 settings. Rules match the window class with
case-insensitive patterns (`i3/config.d/02_rules.conf`), so native, Flatpak
and renamed builds of an app all match. `Mod+Shift+I` shows the class of the
focused window when you want to add one.

### Colour themes

`Mod+Shift+T` opens a picker; `~/.config/i3/scripts/theme <name>` applies a
theme directly. It recolours i3, polybar, rofi, alacritty, dunst, fastfetch,
the lock screen and the bar scripts. The fish prompt and syntax colours follow
the terminal. GTK and Qt applications are not recoloured.

| Path | Purpose |
| --- | --- |
| `themes/palettes/*.conf` | One palette per file, 15 named colours as `KEY=#rrggbb` |
| `themes/templates/` | One colour file per tool with `${KEY}` placeholders |
| `themes/targets.conf` | Which template is written where, and how that tool reloads |

* New theme: copy a palette and change the colours.
* New tool: add a template, add a line to `targets.conf`, and make the tool's
  config import the generated file.

The generated files are git-ignored, so switching themes never changes the
repository, and they are recreated whenever one is missing.

### Game mode

`Mod+Shift+G` stops the compositor, pauses notifications and the idle lock,
and turns off every i3 key except workspace switching and the key that leaves
the mode. It only touches the user session; nothing system-wide changes.

### Pomodoro

25 minutes of work, 5 minutes of break. A notification warns one minute
before a break; the break then takes over the screen until it ends, and
`Mod+Ctrl+Shift+B` skips it. Finished work blocks and breaks are counted per
day in `~/.local/state/pomo/history` (plain text, one line per day) and shown
next to the timer. In game mode breaks are announced but never enforced.

### Event sounds

Notifications, screenshots, login and logout, game mode, theme changes and USB
plug events play a sound from a freedesktop sound theme. `Mod+G` then `Z`
toggles them; `~/.config/i3/scripts/sound volume-keys on` adds a blip to the
volume keys. They are silent in game mode.

### Shell

fish with a split `conf.d/` configuration and ten prompt styles, from a plain
one-liner to powerline segments; `prompt-style` opens a menu with a live
preview. `fastfetch` runs once per terminal, not in nested shells or editor
terminals.

## Layout

| Path | Purpose |
| --- | --- |
| `i3/` | i3 config (`config.d/` is loaded in name order), window rules, session scripts |
| `polybar/`, `picom/`, `rofi/`, `dunst/`, `alacritty/`, `gsimplecal/`, `fastfetch/` | Symlinked into `~/.config` |
| `fish/`, `Thunar/` | Copied once into `~/.config`: these applications rewrite their own files |
| `systemd/user/` | `i3-session.target` and the daemons it starts |
| `xorg/` | Snippets installed to `/etc/X11/xorg.conf.d/` |
| `seeds/` | Files copied once and then left to their tool (GTK, qt6ct, Kvantum, portals, browser flags) |
| `packages/` | Package lists, one name per line |
| `themes/` | Colour palettes and the templates they fill |

### Session

i3 runs `i3/scripts/session-start` once per login. It imports the X environment
into systemd and starts `i3-session.target`, which owns picom, the polkit
agent, xss-lock, clipmenud, autotiling, flameshot, dunst and the USB watcher,
plus XDG autostart entries.

```
systemctl --user status picom
journalctl --user -u picom -b
systemctl --user mask flameshot.service    # stop a daemon from starting
```

The screen locks after 10 minutes idle and the monitor powers down after 15;
both values are at the top of `i3/scripts/idle`.

### Hardware

* **Refresh rate**: `i3/scripts/display` finds each connected output and sets
  its native mode at the highest rate; no output name is hardcoded.
* **GPU**: on `amdgpu`, `xorg/20-amdgpu.conf` enables TearFree and FreeSync
  through `xf86-video-amdgpu`. FreeSync needs a fullscreen window that is not
  composited; it does not need a compositor. picom (`glx` backend, vsync)
  steps aside for fullscreen windows so it does not block FreeSync, and game
  mode stops it altogether.
* **Brightness**: DDC/CI through `ddcutil`. The value is cached in
  `$XDG_RUNTIME_DIR/brightness`, so the bar never polls the monitor.
* **Mouse**: `xorg/40-libinput.conf` sets the flat acceleration profile. Remove
  it from `install.sh` if you prefer acceleration.

### Theming of applications

* GTK: `adw-gtk3-dark` with `Papirus-Dark` icons, both packaged. `nwg-look`
  changes them; it writes `~/.config/gtk-3.0/settings.ini` and gsettings, and
  new windows pick the change up. Do not run an XSETTINGS daemon (xsettingsd,
  xfsettingsd) next to it: it would override that file.
* Qt: `qt6ct` with the Kvantum style. Pick the Kvantum theme in
  `kvantummanager`.
* Wallpaper: put an image at `~/.config/i3/wallpaper.png` (or `.jpg`, or
  `~/Pictures/wallpaper.*`). Without one the background is the theme colour.

### Secrets

`gnome-keyring` is unlocked at login through the PAM hooks that `ly` ships.
Chromium-based browsers, VS Code and applications on the system Electron are
pinned to it with `--password-store=gnome-libsecret`, because they do not
recognise `i3` as a desktop and would otherwise pick a store unpredictably.
This is skipped when KWallet is installed.

## Making it yours

* Default applications: `i3/config.d/03_apps.conf` (terminal, file manager),
  `i3/scripts/focus-or-launch` (browser, from `xdg-settings`).
* Packages: edit `packages/*.txt`. `make packages` checks that every name
  still exists in the repositories.
* Workspace purposes: `i3/config.d/02_rules.conf` and the icons in
  `polybar/modules.ini`.
* Launcher entries hidden by the installer: `rofi/hidden-apps.txt`.
* Machine-specific fish settings: `~/.config/fish/conf.d/99-local.fish`, which
  is not part of this repository.

## Checks

```
make check       # script syntax, shellcheck if installed, palettes and templates, systemd units, installer dry run
make packages    # every listed package exists in the repositories
```

## Defaults worth setting after install

```
xdg-mime default alacritty.desktop x-scheme-handler/terminal
xdg-settings set default-web-browser firefox.desktop
```

## License

[MIT](LICENSE)
