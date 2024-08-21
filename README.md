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
| Toggle Pomodoro   | Meta+Shift+Z | i3-gnome-pomodoro |

## Sway Install + Dependencies

### Install Sway + ly + Polkit

```
sudo pacman -S --needed  i3-wm brightnessctl pavucontrol alacritty feh polybar rofi
```

### Required For Icons, Screenshare & Authentication

```
sudo pacman -S ttf-font-awesome ttf-jetbrains-mono-nerd xdg-desktop-portal gvfs lxqt-policykit
```

### Config ly-greeter

```
sudo dpkg-reconfigure ly && systemctl daemon-reload
systemctl enable ly.service
```

### Install a GUI Filemanager , TextEditor & ImageViewer

Recommended

```
sudo pacman -S --needed nemo nemo-audio-tab nemo-emblems nemo-fileroller nemo-image-converter nemo-preview nemo-python gvfs gvfs-mtp xed xreader ristretto
```

Set Nemo's Default Terminal

```
gsettings set org.cinnamon.desktop.default-applications.terminal exec alacritty

```

Optional Extras

```
sudo pacman -S --needed catfish tumbler file-roller engrampa caja squashfs-tools libopenraw libgepub libgsf poppler-glib ffmpegthumbnailer
```

### Dynamic Autotiling for Sway, Notification deamon (AUR Stuff) , Pomodoro Gnome & Waybar

```
paru -S autotiling swaync flameshot-git i3-gnome-pomodoro-git  webapp-manager
```

#### For Brightness Control & Clipboard

```
sudo pacman -S --needed cliphist ddcutil
```

#### For Bluetooth Support

```
paru -S bluetuith
```

### Set Theme for gtk and qt

#### GTK - Theme , Defaults to DarkMode

```
mkdir .themes
cd .themes
git clone https://github.com/EliverLara/Kripton
gsettings set org.gnome.desktop.interface gtk-theme "Kripton"
gsettings set org.gnome.desktop.wm.preferences theme "Kripton"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

#### GTK - Icons

```
cd repos
git clone https://github.com/vinceliuice/Colloid-icon-theme.git
cd Colloid-icon-theme
./install.sh -s default -t teal
gsettings set org.gnome.desktop.interface icon-theme "Colloid-Teal-Dark"
```

#### Set GTK Theme with lxappearance

```
sudo pacman -S --needed lxappearance
```

#### QT

```
sudo pacman -S qt6ct kvantum
```

Setup Environment variables (useful setting force wayland flags globally)

`sudo nvim /etc/environment`

```
QT_QPA_PLATFORMTHEME=qt6ct
ELECTRON_OZONE_PLATFORM_HINT=auto
```
