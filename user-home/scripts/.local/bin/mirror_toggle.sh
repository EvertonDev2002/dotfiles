#!/bin/bash
# Script para alternar o espelhamento em qualquer tela externa

INTERNAL="eDP-1"

if pgrep -x "wl-mirror" > /dev/null; then

    killall wl-mirror
    notify-send "Sway" "Modo Espelhado DESATIVADO."
    pkill shikane; shikane &
else
    EXTERNAL=$(swaymsg -t get_outputs | jq -r '.[] | select(.name != "'$INTERNAL'" and .active == true) | .name' | head -n 1)

    if [ -n "$EXTERNAL" ]; then
        notify-send "Sway" "Iniciando ESPELHAMENTO em: $EXTERNAL"
        wl-mirror --fullscreen-output "$EXTERNAL" "$INTERNAL" &
    else
        notify-send "Sway" "Nenhuma tela externa ativa encontrada para espelhar."
    fi
fi
