#!/bin/bash

# Greetd
# Configure em: /etc/greetd/config.toml

# Ly
# configure em:  /usr/share/wayland-sessions/


# Sessão XDG
export XDG_CURRENT_DESKTOP=river
export XDG_SESSION_TYPE=wayland
export XDG_MENU_PREFIX=arch-
export XDG_SESSION_DESKTOP=river

# Cursor
export XCURSOR_SIZE=20
export XCURSOR_THEME=Bibata-Modern-Ice

# GTK / GDK
export GDK_BACKEND=wayland,x11,*

# Qt
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# Elementary/EFL
ECORE_EVAS_ENGINE=wayland
ELM_ENGINE=wayland

# Clutter / SDL
export SDL_VIDEODRIVER=wayland

# Electron / Chromium / Firefox
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
exec dbus-run-session river