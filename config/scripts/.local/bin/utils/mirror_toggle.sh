#!/bin/bash
#
#  MIRROR TOGGLE - Universal Wayland Display Mirroring
#  Alterna o espelhamento de tela usando wl-mirror (compatível com qualquer WM Wayland)
#

set -euo pipefail

# Carregar Configurações
# shellcheck disable=SC1091
. "${XDG_CONFIG_HOME:-$HOME/.config}/river/config.sh"

# Logging
mkdir -p "$DIR_LOG"
LOG_FILE="$DIR_LOG/mirror.log"

exec > "$LOG_FILE" 2>&1

log() { echo "[$(date '+%H:%M:%S')] $1"; }

# --- VERIFICAR DEPENDÊNCIAS
for cmd in wl-mirror jq; do
    if ! command -v "$cmd" >/dev/null; then
        notify-send -u critical "Erro Mirror" "$cmd não encontrado."
        log "ERRO: Dependência $cmd não encontrada."
        exit 1
    fi
done

# Detectar ferramenta de randr disponível
if command -v wlr-randr >/dev/null; then
    RANDR_CMD="wlr-randr"
elif command -v kanshi >/dev/null; then
    RANDR_CMD="wlr-randr"
else
    notify-send -u critical "Erro Mirror" "wlr-randr não encontrado."
    log "ERRO: Nenhuma ferramenta de randr disponível."
    exit 1
fi

# --- DETECTAR DISPLAYS
detect_displays() {
    if [ "$RANDR_CMD" = "wlr-randr" ]; then
        local all_displays
        all_displays=$(wlr-randr --json)
        
        # Tela interna (primeira tela do tipo eDP, LVDS ou DSI)
        INTERNAL=$(echo "$all_displays" | jq -r '.[] | select(.name | test("^(eDP|LVDS|DSI)")) | .name' | head -n 1)
        
        # Tela externa (qualquer tela ativa que não seja a interna)
        EXTERNAL=$(echo "$all_displays" | jq -r '.[] | select(.name != "'"$INTERNAL"'" and .enabled == true) | .name' | head -n 1)
    fi
    
    log "Display interno detectado: ${INTERNAL:-nenhum}"
    log "Display externo detectado: ${EXTERNAL:-nenhum}"
}

# --- TOGGLE MIRROR
if pgrep -x "wl-mirror" > /dev/null; then
    # --- DESATIVAR (Parar espelhamento)
    log "Desativando espelhamento..."
    
    killall wl-mirror
    
    # Restaurar gerenciador de display se disponível
    if command -v way-displays >/dev/null && pgrep -x way-displays >/dev/null; then
        log "Reiniciando way-displays..."
        pkill -x way-displays
        sleep 0.2
        way-displays > /tmp/way-displays.log 2>&1 &
    elif command -v kanshi >/dev/null && pgrep -x kanshi >/dev/null; then
        log "Reiniciando kanshi..."
        pkill -x kanshi
        sleep 0.2
        kanshi > /tmp/kanshi.log 2>&1 &
    fi
    
    notify-send -i video-display "Espelhamento" "Modo espelhado DESATIVADO."
    log "wl-mirror encerrado."

else
    # --- ATIVAR (Iniciar espelhamento)
    detect_displays
    
    if [ -z "$INTERNAL" ]; then
        log "ERRO: Display interno não detectado."
        notify-send -u critical "Erro Mirror" "Display interno não encontrado."
        exit 1
    fi
    
    if [ -n "$EXTERNAL" ]; then
        log "Iniciando espelhamento: $INTERNAL -> $EXTERNAL"
        wl-mirror --fullscreen-output "$EXTERNAL" "$INTERNAL" &
        notify-send -i video-display "Espelhamento" "Espelhando $INTERNAL em $EXTERNAL"
    else
        log "Nenhuma tela externa ativa encontrada."
        notify-send -u low -i dialog-error "Espelhamento" "Nenhuma tela externa detectada."
    fi
fi