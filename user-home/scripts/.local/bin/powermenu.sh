#!/bin/bash

SHUTDOWN="⏻ Desligar"
REBOOT="󰑐 Reiniciar"
LOCK=" Bloquear"
LOGOUT="󰗽 Logout"

CHOICE=$(printf \
 "%s\n%s\n%s\n%s\n" \
 "$SHUTDOWN" \
 "$REBOOT" \
 "$LOCK" \
 "$LOGOUT" \
   | fuzzel -d -p "Sessão" --lines 4 --width 25
    )

case "$CHOICE" in
    "$SHUTDOWN")
        exec loginctl poweroff 
        ;;
    "$REBOOT")
        exec loginctl reboot
        ;;
    "$LOCK")
        exec swaylock 
        ;;
    "$LOGOUT")
        if [ -n "$RIVER_SOCKET" ]; then
            exec riverctl exit
        elif [ -n "$SWAYSOCK" ]; then
            exec swaymsg exit
        elif [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
            hyprctl dispatch exit
        else
            loginctl terminate-session "${XDG_SESSION_ID-}"
        fi
        ;;
esac
