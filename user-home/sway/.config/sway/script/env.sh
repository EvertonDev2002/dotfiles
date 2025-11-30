#!/bin/bash

# Greetd
# Configure em: /etc/greetd/config.toml

# Ly
# configure em:  /usr/share/wayland-sessions/


# Sessão XDG
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_MENU_PREFIX=arch-

# Cursor
export XCURSOR_SIZE=20
export XCURSOR_THEME=Bibata-Modern-Ice
# export WLR_NO_HARDWARE_CURSORS=1

# GTK / GDK
#export GDK_SCALE=1.2
export GDK_BACKEND=wayland,x11,*

# Qt
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=qt6ct
# export QT_WAYLAND_FORCE_DPI=physical
export QT_AUTO_SCREEN_SCALE_FACTOR=0
#export QT_SCALE_FACTOR=1.2
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# Elementary/EFL
ECORE_EVAS_ENGINE=wayland
ELM_ENGINE=wayland

# Clutter / SDL
# export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
# export SDL_DYNAMIC_API=/usr/lib/libSDL2-2.0.so

# Electron / Chromium / Firefox
#export ELECTRON_FORCE_DEVICE_SCALE_FACTOR=1.2
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export OZONE_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1

# VA-API Intel
export LIBVA_DRIVER_NAME=iHD
export LIBVA_DRIVERS_PATH=/usr/lib/dri

# Java
export _JAVA_AWT_WM_NONREPARENTING=1


# Pipewire (runit)
/usr/bin/pipewire &
/usr/bin/pipewire-pulse &
/usr/bin/wireplumber &

# iniciar sway
exec dbus-run-session sway
