#!/bin/bash
#
#  INIT SERVICES - VERSÃO TURBO & MODULAR
#  Otimizado para velocidade e fácil manutenção.
#

# --- Carregar Configurações
# shellcheck disable=SC1091
. "${XDG_CONFIG_HOME:-$HOME/.config}/river/config.sh"

# --- Carregar Biblioteca de Logging
# shellcheck disable=SC1091
. "$SCRIPTS_LIB_DIR/logging.sh"

# --- Logging
setup_logging "$DIR_LOG/services.log" "Init Services"

log_info "Iniciando serviços do sistema..."

# --- PREPARAÇÃO DO AMBIENTE

: "${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"
export XDG_RUNTIME_DIR

if pgrep -f gnome-keyring-daemon >/dev/null; then
    pkill -u "$USER" -f gnome-keyring-daemon
    sleep 0.3
    log_info "Processos antigos do keyring limpos"
fi

# Cria diretório do keyring se não existir
[ ! -d "$XDG_RUNTIME_DIR/keyring" ] && mkdir -m 0700 "$XDG_RUNTIME_DIR/keyring"

# --- KEYRING (CORE)

if [ -x "/usr/bin/gnome-keyring-daemon" ]; then
    if pgrep -x "gnome-keyring-d" >/dev/null; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
        log_info "Keyring já online"
    else
        eval "$(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh 2>/dev/null)"
        export SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID
        if [ -n "${SSH_AUTH_SOCK:-}" ]; then
            log_info "Keyring iniciado com sucesso"
        else
            log_warn "Keyring não retornou SSH_AUTH_SOCK"
        fi
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
        log_info "Iniciando serviço: $NAME"
        "$CMD" &
    else
        log_debug "Serviço já rodando: $NAME"
    fi
}

# Polkit
[ -x "$BIN_POLKIT" ] && run_bg "polkit-gnome" "$BIN_POLKIT"

# Serviços
log_info "Iniciando serviços..."
log_info "Iniciando stack de áudio (pipewire)..."
if ! pgrep -x pipewire >/dev/null; then
    "$SCRIPT_PIPEWIRE" &
else
    log_debug "Stack de áudio já rodando"
fi
sleep 1

run_bg "portais XDG" "$SCRIPT_PORTALS"
run_bg "clipboard" "$SCRIPT_CLIPBOARD"

# Applets do Sistema
log_info "Iniciando applets..."
run_bg "swww-daemon" "swww-daemon"
run_bg "nm-applet" "nm-applet"
run_bg "blueman-applet" "blueman-applet"

finish_logging 0 "Init Services"
