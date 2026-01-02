#!/bin/bash

# Greetd: configure em /etc/greetd/config.toml
# Ly: configure em /usr/share/wayland-sessions/

# --- Carregar Configurações e Logging
# shellcheck disable=SC1091
source "${XDG_CONFIG_HOME:-$HOME/.config}/river/config.sh"
source "$SCRIPTS_LIB_DIR/logging.sh"

setup_logging "$DIR_LOG/river-session.log" "River Session Init"

# --- Ativação de Hardware (NumLock)
log_info 'Ativando NumLock no terminal atual (tty2)...'

if /usr/bin/setleds -D +num < /dev/tty >/dev/null 2>&1; then
    log_success 'NumLock ativado com sucesso.'
else
    log_warn 'Falha ao ativar NumLock (verifique se o usuário pertence ao grupo tty).'
fi

# --- Carregar perfis do sistema
log_info 'Carregando /etc/profile...'
# shellcheck disable=SC1091
source '/etc/profile'
sleep 0.5

if [ -f /etc/environment ]; then
    log_info 'Carregando /etc/environment...'
    set -a
    # shellcheck disable=SC1091
    source '/etc/environment'
    sleep 0.5
    set +a
fi

# --- Carregar variaveis de ambiente do Wayland
WAYLAND_COMMON="$HOME/.local/bin/lib/wayland-common.sh"

if [ -f "$WAYLAND_COMMON" ]; then
    log_info "Carregando ambiente Wayland: $WAYLAND_COMMON"
    set -a
    # shellcheck source=$HOME/.local/bin/lib/wayland-common.sh
    # shellcheck disable=SC1090
    source "$WAYLAND_COMMON" river 2>&1
    set +a
    log_success 'Ambiente Wayland carregado'
else
    log_error "wayland-common.sh nao encontrado em: $WAYLAND_COMMON"
fi

# --- Idioma
log_info 'Configurando locale...'
export LANG="${LANG:-pt_BR.UTF-8}"
export LC_ALL="${LC_ALL:-pt_BR.UTF-8}"

# --- Debug: registrar variaveis exportadas
log_info '=== Variaveis de ambiente exportadas ==='
env | grep -E 'XDG_|QT_|GTK_|WAYLAND|MOZ_|XCURSOR|GDK_|SDL_|ELECTRON|OZONE|LIBVA|XKB_' | sort

log_success 'Ambiente configurado. Iniciando River...'
finish_logging 0 'River Session Init'

# --- Iniciar River
exec dbus-run-session river > '/dev/null' 2>&1