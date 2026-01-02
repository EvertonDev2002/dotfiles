#!/usr/bin/env bash

TABS=$(brotab list)
a
if [ -z "$TABS" ]; then
    notify-send "Brotab" "Nenhuma aba encontrada ou erro no backend."
    exit 1
fi


# -d: modo dmenu (lê do stdin)
# -p: prompt visual
# -w: largura da janela
SELECTED=$(echo "$TABS" | fuzzel -d -p "  Abas: " -w 90 --lines 15)

if [ -n "$SELECTED" ]; then
    TAB_ID=$(echo "$SELECTED" | awk '{print $1}')
    
    brotab activate "$TAB_ID"
fi