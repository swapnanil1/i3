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
sudo pacman -S rofi alacritty dunst picom polybar clipmenu hsetroot xorg-xrandr lxsession-gtk3  
```
### Theme And Prompt
```
sudo pacman -S fish lxappearance papirus-icon-theme kvantum qt5ct
sudo chsh -s /usr/bin/fish swapnanil
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
sudo pacman -S ddcutil
sudo echo "i2c-dev" >> /etc/modules-load.d/i2c-dev.conf
sudo usermod swapnanil -aG i2c
```
### Required For Icons, Screenshare & Authentication

```
sudo pacman -S ttf-font-awesome ttf-jetbrains-mono-nerd xdg-desktop-portal xdg-utils gvfs
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
paru -S autotiling flameshot i3-gnome-pomodoro-git webapp-manager
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

#### QT

```
sudo pacman -S qt6ct kvantum
```
