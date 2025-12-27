#!/bin/sh

# 
# init-clipboard.sh
# Inicia o monitoramento de clipboard (wl-clipboard + cliphist)
# 

set -e

# Carregar Configurações
# shellcheck disable=SC1091
. "${XDG_CONFIG_HOME:-$HOME/.config}/river/config.sh"

# Logging
mkdir -p "$DIR_LOG"
exec > "$DIR_LOG/clipboard.log" 2>&1

echo "--- Iniciando Clipboard Manager: $(date) ---"

if [ -z "$WAYLAND_DISPLAY" ]; then
    echo "Erro: WAYLAND_DISPLAY não definido. Esperando..."
    sleep 2
fi

pkill wl-paste || true

mkdir -p "$HOME/.cache/cliphist"

sleep 1

if command -v wl-paste >/dev/null && command -v cliphist >/dev/null; then
    wl-paste --type text --watch cliphist store &
    echo "Watcher de Texto iniciado."

    wl-paste --type image --watch cliphist store &
    echo "Watcher de Imagens iniciado."
else
    echo "ERRO: wl-clipboard ou cliphist não encontrados." >&2
    exit 1
fi

exit 0
