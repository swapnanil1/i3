# Arch Linux + i3wm

# Usage

| Function          | Shortcut     | Using             |
| ----------------- | ------------ | ----------------- |
| App Launcher      | Meta+D       | Rofi              |
| Clipboard History | Meta+P       | Chiphist          |
| ScreenShot        | Meta+Shift+P | FlameShot         |
| Close Window      | Meta+Shift+Q | Sway              |
| Browser           | Meta + C     | Firefox           |
| FileManager       | Meta+X       | Nemo              |
| Terminal          | Meta+Return  | Alacritty         |
| Brighness ++      | Meta+Pageup  | ddcutil           |
| Brighness --      | Meta+Pagedown| ddcutil           |
| Toggle Pomodoro   | Meta+Shift+Z | i3-gnome-pomodoro |

## Sway Install + Dependencies

### Install i3 + loginmanager + Polkit + brightness control

```
sudo pacman -S i3 i3lock xorg-server xorg-xinit xorg-server-utils rofi alacritty dunst picom polybar clipmenu hsetroot xorg-xrandr lxsession-gtk3  
```
### Disable Mouse Acc
/etc/X11/xorg.conf.d/40-libinput.conf
```
 Section "InputClass"
  Identifier "libinput pointer catchall"
  MatchIsPointer "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
  Option "AccelProfile" "flat"
 EndSection
```
### Setup Brighness using ddcutil
```
sudo su
sudo pacman -S ddcutil
echo "i2c-dev" | sudo tee -a /etc/modules-load.d/i2c-dev.conf
sudo groupadd i2c
sudo usermod swapnanil -aG i2c
newgrp i2c
```
### Required For Icons, Screenshare & Authentication

```
sudo pacman -S ttf-font-awesome ttf-jetbrains-mono-nerd xdg-desktop-portal xdg-utils gvfs
```

### Install a GUI Filemanager , TextEditor & ImageViewer

Recommended

```
sudo pacman -S --needed nwg-look thunar gvfs gvfs-mtp xreader ristretto mousepad
```

Set Thunar's Default Terminal

```
xdg-mime default alacritty.desktop x-scheme-handler/terminal

```

Set Chromium as default browser
```
xdg-settings set default-web-browser chromium.desktop
```

Optional Extras

```
sudo pacman -S --needed catfish tumbler file-roller engrampa caja squashfs-tools libopenraw libgepub libgsf poppler-glib ffmpegthumbnailer
```

### Dynamic Autotiling for Sway, Notification deamon (AUR Stuff) , Pomodoro Gnome & Waybar

```
paru -S autotiling flameshot i3-gnome-pomodoro-git webapp-manager
```

#### For Bluetooth Support

```
paru -S bluetuith
```

### Set Theme for gtk and qt

#### GTK - Theme , Defaults to DarkMode
Use nwg-look for applying gtk theme
```
mkdir .themes
cd .themes
git clone https://github.com/EliverLara/Kripton
```

#### GTK - Icons

```
cd repos
git clone https://github.com/vinceliuice/Colloid-icon-theme.git
cd Colloid-icon-theme
./install.sh -s default -t all
```

#### QT

```
sudo pacman -S qt6ct kvantum
```
