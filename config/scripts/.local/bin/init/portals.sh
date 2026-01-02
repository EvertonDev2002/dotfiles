#!/bin/sh

# 
# portals.sh
# Inicialização de portais XDG para ambientes wlroots (River/Artix)
# 

set -e

# Carregar Configurações
# shellcheck disable=SC1091
. "${XDG_CONFIG_HOME:-$HOME/.config}/river/config.sh"

# Logging
mkdir -p "$DIR_LOG"
exec > "$DIR_LOG/portals.log" 2>&1

echo "--- Iniciando Portais: $(date) ---"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

PORTAL_GENERIC="/usr/lib/xdg-desktop-portal"
PORTAL_WLR="/usr/lib/xdg-desktop-portal-wlr"
PORTAL_GTK="/usr/lib/xdg-desktop-portal-gtk"

echo "Atualizando DBus activation environment..."
dbus-update-activation-environment --all

echo "Matando processos antigos..."
pkill -f xdg-desktop-portal-wlr 2>/dev/null || echo "Nenhum portal wlr rodando."
pkill -f xdg-desktop-portal-gtk 2>/dev/null || echo "Nenhum portal gtk rodando."
pkill -f "xdg-desktop-portal" 2>/dev/null || echo "Nenhum portal genérico rodando."

sleep 0.5

# Aguardar pipewire estar pronto (necessário para screencast)
echo "Aguardando PipeWire..."
for i in 1 2 3 4 5; do
    if pgrep -x pipewire >/dev/null; then
        echo "PipeWire detectado."
        break
    fi
    [ "$i" -eq 5 ] && echo "AVISO: PipeWire não detectado, continuando..."
    sleep 0.5
done

echo "Iniciando Backend (WLR)..."
if [ -x "$PORTAL_WLR" ]; then
    "$PORTAL_WLR" &
    PID_WLR=$!
    echo "Backend iniciado (PID: $PID_WLR). Aguardando..."
    sleep 1.5 
else
    echo "ERRO CRÍTICO: Backend $PORTAL_WLR não encontrado!" >&2
    exit 1
fi

echo "Iniciando Frontend (Genérico)..."
if [ -x "$PORTAL_GENERIC" ]; then
    "$PORTAL_GENERIC" &
    echo "Frontend iniciado."
else
    echo "ERRO: Frontend $PORTAL_GENERIC não encontrado!" >&2
fi

echo "Iniciando Frontend (GTK)..."
if [ -x "$PORTAL_GTK" ]; then
    "$PORTAL_GTK" &
    echo "Frontend GTK iniciado."
else
    echo "AVISO: Frontend $PORTAL_GTK não encontrado (opcional)" >&2
fi

echo "--- Inicialização de portais concluída ---"
exit 0
