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
setup_logging "$DIR_LOG/autostart.log" 'Init Autostart'

wait_for_pulseaudio() {
    # Aguarda até 5 segundos pelo socket do PulseAudio
    local count=0
    while ! pactl info >/dev/null 2>&1; do
        sleep 0.5
        count=$((count + 1))
        [ "$count" -ge 10 ] && return 1
    done
    return 0
}
run_bg() {
    local NAME="$1"
    shift

    # Limpeza preventiva
    log_debug "Serviço já rodando: $NAME"
    pkill -x "$@"

    # Iniciando sem conflito
    log_info "Iniciando serviço: $NAME"
    "$@" &
    sleep 0.2
}

log_header 'TEMAS GTK'
log_info 'Aplicando temas GTK...'
(
    gsettings set org.gnome.desktop.wm.preferences button-layout :
    gsettings set org.gnome.desktop.interface cursor-theme "$XCURSOR_THEME"
    gsettings set org.gnome.desktop.interface cursor-size "$XCURSOR_SIZE"
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
) &

log_header 'INTERFACE GRÁFICA'

log_info 'Aguardando Pipewire-Pulse para Waybar...'
wait_for_pulseaudio

# log_info 'Iniciando Way-Displays...'
# run_bg "way-displays" "way-displays"
# way-displays > /tmp/way-displays.log 2>&1 &

log_info 'Iniciando Notificações (Mako)...'
run_bg 'mako' mako

log_info 'Iniciando Barra (Waybar)...'
run_bg 'waybar' waybar

log_info 'Definindo Wallpaper...'
if [ -x "$SCRIPT_WALLPAPER" ]; then
    "$SCRIPT_WALLPAPER" "$WALLPAPER_DEFAULT" &
else
    log_error "Script de wallpaper não encontrado: $SCRIPT_WALLPAPER"
fi

finish_logging 0 'Init Autostart'
