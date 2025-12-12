#!/bin/sh

# ============================================================================
# init-portals.sh
# Inicialização de portais XDG para ambientes wlroots (River/Artix)
# ============================================================================

set -e

# Logging
DIR_LOG="${DIR_LOG:-$HOME/.local/state/init-log}"
mkdir -p "$DIR_LOG"
exec >"$DIR_LOG/portals.log" 2>&1

echo "--- Iniciando Portais: $(date) ---"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

PORTAL_GENERIC="/usr/lib/xdg-desktop-portal"
PORTAL_WLR="/usr/lib/xdg-desktop-portal-wlr"

echo "Atualizando DBus activation environment..."
dbus-update-activation-environment --all

echo "Matando processos antigos..."
pkill -x xdg-desktop-portal || echo "Nenhum portal genérico rodando."
pkill -x xdg-desktop-portal-wlr || echo "Nenhum portal wlr rodando."

echo "Iniciando Backend (WLR)..."
if command -v "$PORTAL_WLR" >/dev/null 2>&1; then
    "$PORTAL_WLR" &
    PID_WLR=$!
    echo "Backend iniciado (PID: $PID_WLR). Aguardando..."
    sleep 1 
else
    echo "ERRO CRÍTICO: Backend $PORTAL_WLR não encontrado!" >&2
    exit 1
fi

echo "Iniciando Frontend (Genérico)..."
if command -v "$PORTAL_GENERIC" >/dev/null 2>&1; then
    "$PORTAL_GENERIC" &
    echo "Frontend iniciado."
else
    echo "ERRO: Frontend $PORTAL_GENERIC não encontrado!" >&2
fi

echo "--- Inicialização de portais concluída ---"
exit 0
