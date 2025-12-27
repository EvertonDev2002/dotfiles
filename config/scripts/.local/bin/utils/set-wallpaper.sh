#!/bin/sh

set -e

# Carregar Configurações
# shellcheck disable=SC1091
. "${XDG_CONFIG_HOME:-$HOME/.config}/river/config.sh"

# Logging
mkdir -p "$DIR_LOG"
LOG_FILE="$DIR_LOG/wallpaper.log"

exec > "$LOG_FILE" 2>&1

echo "--- Wallpaper: $(date) ---"
CACHE_IMG="/tmp/current_wallpaper.jpg"

if [ -n "$1" ]; then
    WALLPAPER="$1"
else
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" \) | shuf -n 1)
fi

[ -f "$WALLPAPER" ] || { echo "Erro: Wallpaper não encontrado"; exit 1; }

if ! pidof -q swww-daemon; then
    swww-daemon &
    sleep 0.5
fi

swww img "$WALLPAPER" \
    --transition-type grow \
    --transition-pos 0.854,0.977 \
    --transition-step 90 \
    --transition-fps 60

mime_type=$(file --mime-type -b "$WALLPAPER")

if [ "$mime_type" != "image/gif" ]; then
    ffmpeg -y -i "$WALLPAPER" -qscale:v 2 "$CACHE_IMG" >/dev/null 2>&1
fi
