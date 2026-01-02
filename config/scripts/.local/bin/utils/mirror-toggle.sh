#!/usr/bin/env bash
#
# mirror-toggle.sh - Toggle display mirroring (Niri compositor)
# Alterna entre modo espelhamento e layout padrão
#

set -e

# Importa biblioteca de logging
# shellcheck source=../lib/logging.sh
source "${HOME}/.local/bin/lib/logging.sh"

# PID file para rastrear estado
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri-mirror-state"

# Scripts auxiliares
SCRIPT_DIR="$(dirname "$0")"
MIRROR_SCRIPT="$SCRIPT_DIR/mirror-display.sh"
RESTORE_SCRIPT="$SCRIPT_DIR/restore-display.sh"

# Verifica se está em modo espelhamento
is_mirrored() {
    [[ -f "$STATE_FILE" ]]
}

# Toggle entre espelhamento e restauração
if is_mirrored; then
    log_info "Desativando modo espelhamento..."
    "$RESTORE_SCRIPT"
    rm -f "$STATE_FILE"
    notify-send -i video-display "Display" "Layout padrão restaurado"
else
    log_info "Ativando modo espelhamento..."
    "$MIRROR_SCRIPT"
    touch "$STATE_FILE"
    notify-send -i video-display "Display" "Modo apresentação ativado"
fi
