#!/bin/sh

# ============================================================================
# init-pipewire.sh
# Inicialização da Stack de Áudio (PipeWire + WirePlumber)
# ============================================================================

LOG_FILE="$HOME/.local/state/init-log/audio.log"
exec >"$LOG_FILE" 2>&1

echo "--- Iniciando Stack de Áudio: $(date) ---"

PW_BIN="/usr/bin/pipewire"
WP_BIN="/usr/bin/wireplumber"
PULSE_BIN="/usr/bin/pipewire-pulse"

echo "Limpando processos antigos..."
# Redirecionamos o erro do pkill para /dev/null pois já estamos logando tudo
pkill -u "$USER" -x pipewire-pulse 2>/dev/null || true
pkill -u "$USER" -x wireplumber    2>/dev/null || true
pkill -u "$USER" -x pipewire       2>/dev/null || true

sleep 1

if [ -x "$PW_BIN" ]; then
    echo "Iniciando PipeWire..."
    "$PW_BIN" &
else
    echo "ERRO: Binário do PipeWire não encontrado em $PW_BIN" >&2
fi

sleep 0.5 

if [ -x "$WP_BIN" ]; then
    echo "Iniciando WirePlumber..."
    "$WP_BIN" &
else
    echo "AVISO: WirePlumber não encontrado." >&2
fi

if [ -x "$PULSE_BIN" ]; then
    echo "Iniciando PipeWire-Pulse..."
    "$PULSE_BIN" &
else
    echo "AVISO: PipeWire-Pulse não encontrado." >&2
fi

echo "--- Áudio iniciado com sucesso ---"
exit 0
