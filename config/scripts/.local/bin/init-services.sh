#!/bin/bash
# ============================================================================
#  INIT SERVICES - VERSÃO TURBO & MODULAR
#  Otimizado para velocidade e fácil manutenção.
# ============================================================================

# --- 1. CONFIGURAÇÃO E LOGS ---

# Logging
DIR_LOG="${DIR_LOG:-$HOME/.local/state/init-log}"
mkdir -p "$DIR_LOG"
exec > "$DIR_LOG/services.log" 2>&1

log() { echo "[$(date '+%H:%M:%S')] $1"; }

# --- VARIÁVEIS (MANUTENÇÃO)

# Caminhos dos scripts auxiliares
SCRIPT_PORTALS="$HOME/.local/bin/init-portals.sh"
SCRIPT_PIPEWIRE="$HOME/.local/bin/init-pipewire.sh"
SCRIPT_CLIPBOARD="$HOME/.local/bin/init-clipboard.sh"

# Binários do sistema
BIN_POLKIT="/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"

log "--- Iniciando Serviços ---"

# --- PREPARAÇÃO DO AMBIENTE

: "${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"
export XDG_RUNTIME_DIR

if pgrep -f gnome-keyring-daemon >/dev/null; then
    pkill -u "$USER" -f gnome-keyring-daemon
    sleep 0.3
    log "Processos antigos limpos."
fi

# Cria diretório do keyring se não existir
[ ! -d "$XDG_RUNTIME_DIR/keyring" ] && mkdir -m 0700 "$XDG_RUNTIME_DIR/keyring"

# --- KEYRING (CORE)

if [ -x "/usr/bin/gnome-keyring-daemon" ]; then
    if pgrep -x "gnome-keyring-d" >/dev/null; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
        log "Keyring já online."
    else
        eval "$(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh 2>/dev/null)"
        export SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID
        log "Keyring iniciado: $SSH_AUTH_SOCK"
    fi
fi

# --- ATUALIZAÇÃO DO DBUS

dbus-update-activation-environment \
    WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY \
    SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID \
    XDG_RUNTIME_DIR

# --- SERVIÇOS DE FUNDO

run_bg() {
    NAME="$1"
    CMD="$2"
    if ! pgrep -f "$NAME" >/dev/null; then
        log "Iniciando serviço: $NAME"
        "$CMD" &
    else
        log "Serviço já rodando: $NAME"
    fi
}

# Polkit
[ -x "$BIN_POLKIT" ] && run_bg "polkit-gnome" "$BIN_POLKIT"

# Serviços Customizados
run_bg "xdg-desktop-portal" "$SCRIPT_PORTALS"
run_bg "pipewire" "$SCRIPT_PIPEWIRE"
run_bg "wl-paste" "$SCRIPT_CLIPBOARD"

# Applets do Sistema
run_bg "swww-daemon" "swww-daemon"
run_bg "nm-applet" "nm-applet"
run_bg "blueman-applet" "blueman-applet"

log "--- Fim (Script liberado) ---"
