#!/bin/sh

WM_NAME="$1"

if [ -z "$WM_NAME" ]; then
    WM_NAME="wayland"
fi

# --- 1. Sessão e Identidade ---
export XDG_CURRENT_DESKTOP="$WM_NAME"
export XDG_SESSION_DESKTOP="$WM_NAME"
export XDG_SESSION_TYPE="wayland"
export XDG_MENU_PREFIX="arch-"


# --- 2. Aparência (Cursor e Temas) ---
export XCURSOR_SIZE=20
export XCURSOR_THEME=Bibata-Modern-Ice

# --- 3. Toolkits (GTK, Qt, Java, GDK, SDL) ---
export GDK_BACKEND=wayland,x11,*
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export ECORE_EVAS_ENGINE=wayland
export ELM_ENGINE=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# --- 4. Navegadores e Electron ---
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export OZONE_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1

# --- 5. Aceleração de Hardware (Intel) ---
export LIBVA_DRIVER_NAME=iHD
export LIBVA_DRIVERS_PATH=/usr/lib/dri
