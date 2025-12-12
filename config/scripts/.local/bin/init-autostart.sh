#!/bin/bash
# ============================================================================
#  INIT AUTOSTART - UI & APPS
#  Inicia temas, wallpaper, barras e applets.
# ============================================================================

set -euo pipefail

# --- LOGGING
DIR_LOG="${DIR_LOG:-$HOME/.local/state/init-log}"
mkdir -p "$DIR_LOG"
exec > "$DIR_LOG/autostart.log" 2>&1

log() { echo "[$(date '+%H:%M:%S')] $1"; }

log "--- Iniciando Autostart UI ---"

# --- VARIÁVEIS VISUAIS
SCRIPT_WALL="$HOME/.local/bin/set-wallpaper.sh"
IMG_WALL="$HOME/Imagens/Wallapaper/05.jpg"

# --- TEMAS GTK (Background)
log "Aplicando temas GTK..."
(
    gsettings set org.gnome.desktop.wm.preferences button-layout :
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
    gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-blue-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Colloid-Dark'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
) &

# --- INTERFACE GRÁFICA

# Limpeza preventiva
pkill -x way-displays
pkill -x mako
pkill -x waybar

log "Iniciando Way-Displays..."
riverctl spawn "way-displays > /tmp/way-displays.log 2>&1"

log "Iniciando Notificações (Mako)..."
riverctl spawn "mako"

log "Iniciando Barra (Waybar)..."
riverctl spawn "waybar"

log "Definindo Wallpaper..."
if [ -x "$SCRIPT_WALL" ]; then
    riverctl spawn "$SCRIPT_WALL $IMG_WALL"
else
    log "ERRO: Script de wallpaper não encontrado em $SCRIPT_WALL"
fi

log "--- Autostart concluído ---"