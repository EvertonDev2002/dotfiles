#!/bin/bash
# 
#  INIT AUTOSTART - UI & APPS
#  Inicia temas, wallpaper, barras e applets.
# 

# --- Carregar Configurações
# shellcheck disable=SC1091
. "${XDG_CONFIG_HOME:-$HOME/.config}/river/config.sh"

# --- Carregar Biblioteca de Logging
# shellcheck disable=SC1091
. "$SCRIPTS_LIB_DIR/logging.sh"

# --- Setup de Logs
setup_logging "$DIR_LOG/autostart.log" "Init Autostart"

log_header "TEMAS GTK"
log_info "Aplicando temas GTK..."
(
    gsettings set org.gnome.desktop.wm.preferences button-layout :
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
) &

log_header "INTERFACE GRÁFICA"

# Limpeza preventiva
pkill -x way-displays
pkill -x mako
pkill -x waybar

log_info "Iniciando Way-Displays..."
way-displays > /tmp/way-displays.log 2>&1 &

log_info "Iniciando Notificações (Mako)..."
mako &

log_info "Iniciando Barra (Waybar)..."
waybar &

log_info "Definindo Wallpaper..."
if [ -x "$SCRIPT_WALLPAPER" ]; then
    "$SCRIPT_WALLPAPER" "$WALLPAPER_DEFAULT" &
else
    log_error "Script de wallpaper não encontrado: $SCRIPT_WALLPAPER"
fi

finish_logging 0 "Init Autostart"
