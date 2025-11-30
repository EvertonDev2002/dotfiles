#!/bin/bash

# Comandos de Energia
SHUTDOWN="⏻ Desligar"
REBOOT="󰑐 Reiniciar"
LOCK=" Bloquear"
LOGOUT="󰗽 Logout"

# O Rofi exibirá as opções em uma lista.
CHOICE=$(printf "%s\n%s\n%s\n%s\n" "$SHUTDOWN" "$REBOOT" "$LOCK" "$LOGOUT" | rofi -dmenu -i -p "Ação de Energia:")

case "$CHOICE" in
    "$SHUTDOWN")
        # Usa o loginctl (fornecido pelo elogind) para desligar, 
        # que é compatível com Runit.
        exec loginctl poweroff 
        ;;
    "$REBOOT")
        # Usa o loginctl (fornecido pelo elogind) para reiniciar.
        exec loginctl reboot
        ;;
    "$LOCK")
        # Usa o bloqueador de tela específico do Sway.
        exec swaylock 
        ;;
    "$LOGOUT")
        # Envia o comando de saída (exit) ao Sway.
        exec swaymsg exit
        ;;
esac
