#!/bin/sh
# 
#  RIVER COMPOSITOR - CONFIGURAÇÕES CENTRALIZADAS
#  Sistema: Artix Linux (Runit)
# 

# --- DIRETÓRIOS


# XDG Base Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"


# River
# shellcheck disable=SC2034
RIVER_CONFIG_DIR="$XDG_CONFIG_HOME/river"
RIVER_LOG_DIR="$XDG_STATE_HOME/init-log"


# Scripts
SCRIPTS_BIN_DIR="$HOME/.local/bin"
SCRIPTS_INIT_DIR="$SCRIPTS_BIN_DIR/init"
SCRIPTS_UTILS_DIR="$SCRIPTS_BIN_DIR/utils"
# shellcheck disable=SC2034
SCRIPTS_LIB_DIR="$SCRIPTS_BIN_DIR/lib"


# Mídia
WALLPAPER_DIR="$HOME/Imagens/Wallapaper"
# shellcheck disable=SC2034
WALLPAPER_DEFAULT="$WALLPAPER_DIR/05.jpg"
# shellcheck disable=SC2034
SCREENSHOT_DIR="$HOME/Imagens/Screenshots"


# Logs
export DIR_LOG="$RIVER_LOG_DIR"

# --- APLICAÇÕES


# Principais
TERMINAL='kitty'
BROWSER='firefox'
# shellcheck disable=SC2034
LAUNCHER='fuzzel'
# shellcheck disable=SC2034
FILE_MANAGER='nautilus'
# shellcheck disable=SC2034
EDITOR_GUI='code'


# Exportar para ambiente
export EDITOR='nano'
export VISUAL='nano'
export TERMINAL="$TERMINAL"
export BROWSER="$BROWSER"


# --- SCRIPTS INIT
# shellcheck disable=SC2034
SCRIPT_SERVICES="$SCRIPTS_INIT_DIR/services.sh"
# shellcheck disable=SC2034
SCRIPT_AUTOSTART="$SCRIPTS_INIT_DIR/autostart.sh"
# shellcheck disable=SC2034
SCRIPT_PORTALS="$SCRIPTS_INIT_DIR/portals.sh"
# shellcheck disable=SC2034
SCRIPT_PIPEWIRE="$SCRIPTS_INIT_DIR/pipewire.sh"
# shellcheck disable=SC2034
SCRIPT_CLIPBOARD="$SCRIPTS_INIT_DIR/clipboard.sh"


# --- SCRIPTS UTILS
# shellcheck disable=SC2034
SCRIPT_WALLPAPER="$SCRIPTS_UTILS_DIR/set-wallpaper.sh"
# shellcheck disable=SC2034
SCRIPT_SCREENSHOT="$SCRIPTS_UTILS_DIR/screenshot.sh"
# shellcheck disable=SC2034
SCRIPT_POWERMENU="$SCRIPTS_UTILS_DIR/powermenu.sh"
# shellcheck disable=SC2034
SCRIPT_MIRROR="$SCRIPTS_UTILS_DIR/mirror-toggle.sh"


# --- HARDWARE
# Touchpad
# shellcheck disable=SC2034
TOUCHPAD_ID='pointer-1003-8552-ATML3000:00_03EB:2168_Touchpad'
# Keyboard 
# shellcheck disable=SC2034
KEYBOARD_ID=keyboard-1-1-AT_Translated_Set_2_keyboard


# --- TEMAS E APARÊNCIA
# shellcheck disable=SC2034
ICON_THEME='Tela-circle-blue-dark'
# Cores das Bordas (River)
# shellcheck disable=SC2034
BORDER_WIDTH=2
# shellcheck disable=SC2034
BORDER_FOCUSED='0xCDC2B2'
# shellcheck disable=SC2034
BORDER_UNFOCUSED='0x6e6e6e'
# shellcheck disable=SC2034
BORDER_URGENT='0xed8796'


# --- BINÁRIOS DO SISTEMA
# shellcheck disable=SC2034
BIN_POLKIT='/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1'
# shellcheck disable=SC2034
BIN_KEYRING='/usr/bin/gnome-keyring-daemon'


# --- RIVER LAYOUT
# shellcheck disable=SC2034
LAYOUT_PADDING_VIEW=4
# shellcheck disable=SC2034
LAYOUT_PADDING_OUTER=4
# shellcheck disable=SC2034
LAYOUT_MAIN_RATIO=0.3


# --- KEYBINDINGS
# shellcheck disable=SC2034
MOD_KEY='Super'
