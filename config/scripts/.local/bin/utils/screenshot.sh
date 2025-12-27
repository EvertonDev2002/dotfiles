#!/usr/bin/env bash

set -euo pipefail

# Carregar Configurações
# shellcheck disable=SC1091
. "${XDG_CONFIG_HOME:-$HOME/.config}/river/config.sh"

# --- LOGGING 
mkdir -p "$DIR_LOG"
LOG_FILE="$DIR_LOG/screenshot.log"

exec > "$LOG_FILE" 2>&1

echo "--- Screenshot: $(date) ---"

# --- CONFIGURAÇÕES
save_dir="$SCREENSHOT_DIR"
timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
filename="${timestamp}_screenshot.png"
filepath="${save_dir}/${filename}"

# Ícones (Nerd Fonts)
ICON_CAMERA=""
ICON_ERROR=""
ICON_SUCCESS=""

# --- VERIFICAÇÕES DE SEGURANÇA
for cmd in grim slurp; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "${ICON_ERROR} Erro Crítico: O comando '$cmd' não foi encontrado." >&2
        exit 1
    fi
done

if [ ! -d "$save_dir" ]; then
    mkdir -p "$save_dir"
fi

# --- EXECUÇÃO

geometry=$(slurp || true)

if [ -z "$geometry" ]; then
    echo "Ação cancelada pelo usuário."
    exit 0
fi

grim -g "$geometry" "$filepath"

if command -v notify-send &> /dev/null; then
    notify-send -a "Screenshot" "${ICON_CAMERA} Captura Salva" "Arquivo: $filename" -i "$filepath"
fi

echo "${ICON_SUCCESS} Sucesso: $filepath"